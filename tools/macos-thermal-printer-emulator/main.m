#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

static NSData *UUID16(uint16_t value) {
  uint8_t bytes[] = {(uint8_t)(value >> 8), (uint8_t)(value & 0xff)};
  return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

static NSDictionary *UnsignedByte(uint8_t value) {
  return @{
    @"DataElementType" : @1,
    @"DataElementSize" : @1,
    @"DataElementValue" : @(value),
  };
}

@interface ThermalPrinterEmulator
    : NSObject <IOBluetoothRFCOMMChannelDelegate>
@property(nonatomic, strong) IOBluetoothSDPServiceRecord *serviceRecord;
@property(nonatomic, strong) IOBluetoothUserNotification *openNotification;
@property(nonatomic, strong) IOBluetoothRFCOMMChannel *activeChannel;
@property(nonatomic, strong) NSFileHandle *captureHandle;
@property(nonatomic, strong) NSURL *captureDirectory;
@end

@implementation ThermalPrinterEmulator

- (instancetype)initWithCaptureDirectory:(NSURL *)captureDirectory {
  self = [super init];
  if (self) {
    _captureDirectory = captureDirectory;
  }
  return self;
}

- (BOOL)start:(NSError **)error {
  NSDictionary *service = @{
    @"0001 - ServiceClassIDList" : @[ UUID16(0x1101) ],
    @"0004 - ProtocolDescriptorList" : @[
      @[ UUID16(0x0100) ],
      @[ UUID16(0x0003), UnsignedByte(1) ],
    ],
    @"0005 - BrowseGroupList" : @[ UUID16(0x1002) ],
    @"0100 - ServiceName" : @"Softverse Thermal Printer",
    @"0101 - ServiceDescription" : @"ESC/POS test printer",
    @"0102 - ProviderName" : @"Softverse",
  };

  self.serviceRecord =
      [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:service];
  if (self.serviceRecord == nil) {
    if (error != NULL) {
      *error = [NSError
          errorWithDomain:@"SoftverseThermalPrinter"
                     code:1
                 userInfo:@{
                   NSLocalizedDescriptionKey :
                       @"macOS could not publish the Bluetooth SPP service."
                 }];
    }
    return NO;
  }

  BluetoothRFCOMMChannelID channelID = 0;
  IOReturn channelResult =
      [self.serviceRecord getRFCOMMChannelID:&channelID];
  if (channelResult != kIOReturnSuccess || channelID == 0) {
    if (error != NULL) {
      *error = [NSError
          errorWithDomain:@"SoftverseThermalPrinter"
                     code:2
                 userInfo:@{
                   NSLocalizedDescriptionKey :
                       @"The published service did not receive an RFCOMM channel."
                 }];
    }
    [self.serviceRecord removeServiceRecord];
    self.serviceRecord = nil;
    return NO;
  }

  self.openNotification = [IOBluetoothRFCOMMChannel
      registerForChannelOpenNotifications:self
                                  selector:@selector(channelOpened:channel:)
                             withChannelID:channelID
                                 direction:
                                     kIOBluetoothUserNotificationChannelDirectionIncoming];
  if (self.openNotification == nil) {
    if (error != NULL) {
      *error = [NSError
          errorWithDomain:@"SoftverseThermalPrinter"
                     code:3
                 userInfo:@{
                   NSLocalizedDescriptionKey :
                       @"macOS could not register the incoming printer channel."
                 }];
    }
    [self.serviceRecord removeServiceRecord];
    self.serviceRecord = nil;
    return NO;
  }

  NSLog(@"Softverse Thermal Printer is ready on RFCOMM channel %u.", channelID);
  NSLog(@"Pair this Mac in Android Bluetooth settings, then select the Mac in Softverse.");
  NSLog(@"ESC/POS jobs will be saved in %@", self.captureDirectory.path);
  return YES;
}

- (void)channelOpened:(IOBluetoothUserNotification *)notification
               channel:(IOBluetoothRFCOMMChannel *)channel {
  if (self.activeChannel != nil) {
    [self.activeChannel closeChannel];
  }
  self.activeChannel = channel;
  [channel setDelegate:self];

  NSString *deviceName = [channel getDevice].name ?: @"Android device";
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyyMMdd-HHmmss";
  NSString *stamp = [formatter stringFromDate:[NSDate date]];
  NSString *fileName = [NSString stringWithFormat:@"escpos-%@.bin", stamp];
  NSURL *captureURL = [self.captureDirectory URLByAppendingPathComponent:fileName];
  [[NSFileManager defaultManager] createFileAtPath:captureURL.path
                                          contents:nil
                                        attributes:nil];
  self.captureHandle = [NSFileHandle fileHandleForWritingToURL:captureURL
                                                         error:nil];
  NSLog(@"Connected: %@. Capturing to %@", deviceName, captureURL.path);
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)channel
                      data:(void *)dataPointer
                    length:(size_t)dataLength {
  NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
  [self.captureHandle writeData:data];
  [self.captureHandle synchronizeFile];
  NSLog(@"Received %zu ESC/POS bytes (total offset: %llu).", dataLength,
        self.captureHandle.offsetInFile);
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)channel {
  [self.captureHandle closeFile];
  self.captureHandle = nil;
  self.activeChannel = nil;
  NSLog(@"Printer client disconnected. Waiting for another connection.");
}

- (void)stop {
  [self.captureHandle closeFile];
  [self.activeChannel closeChannel];
  [self.openNotification unregister];
  [self.serviceRecord removeServiceRecord];
}

@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSString *basePath = NSFileManager.defaultManager.currentDirectoryPath;
    if (argc == 3 && strcmp(argv[1], "--output") == 0) {
      basePath = [NSString stringWithUTF8String:argv[2]];
    } else if (argc != 1) {
      fprintf(stderr, "Usage: %s [--output CAPTURE_DIRECTORY]\n", argv[0]);
      return 64;
    }

    NSURL *captureDirectory = [NSURL fileURLWithPath:basePath isDirectory:YES];
    NSError *directoryError = nil;
    [NSFileManager.defaultManager createDirectoryAtURL:captureDirectory
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:&directoryError];
    if (directoryError != nil) {
      NSLog(@"Could not create capture directory: %@", directoryError);
      return 1;
    }

    ThermalPrinterEmulator *emulator =
        [[ThermalPrinterEmulator alloc] initWithCaptureDirectory:captureDirectory];
    NSError *startError = nil;
    if (![emulator start:&startError]) {
      NSLog(@"Could not start emulator: %@", startError.localizedDescription);
      return 1;
    }

    signal(SIGINT, SIG_IGN);
    dispatch_source_t signalSource = dispatch_source_create(
        DISPATCH_SOURCE_TYPE_SIGNAL, SIGINT, 0,
        dispatch_get_main_queue());
    dispatch_source_set_event_handler(signalSource, ^{
      NSLog(@"Stopping emulator.");
      [emulator stop];
      CFRunLoopStop(CFRunLoopGetMain());
    });
    dispatch_resume(signalSource);

    CFRunLoopRun();
  }
  return 0;
}
