#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <IOBluetooth/IOBluetooth.h>

static NSString *const SoftverseBLEServiceUUID =
    @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
static NSString *const SoftverseBLEWriteUUID =
    @"49535343-8841-43F4-A8D4-ECBE34729BB3";

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
    : NSObject <IOBluetoothRFCOMMChannelDelegate, CBPeripheralManagerDelegate>
@property(nonatomic, strong) IOBluetoothSDPServiceRecord *serviceRecord;
@property(nonatomic, strong) IOBluetoothUserNotification *openNotification;
@property(nonatomic, strong) IOBluetoothRFCOMMChannel *activeChannel;
@property(nonatomic, strong) NSFileHandle *captureHandle;
@property(nonatomic, strong) NSURL *captureDirectory;
@property(nonatomic, strong) CBPeripheralManager *peripheralManager;
@property(nonatomic, strong) CBMutableCharacteristic *bleWriteCharacteristic;
@property(nonatomic, strong) NSFileHandle *bleCaptureHandle;
@property(nonatomic, strong) NSMutableData *livePreviewData;
@property(nonatomic, strong) NSTimer *livePreviewTimer;
@end

@implementation ThermalPrinterEmulator

- (instancetype)initWithCaptureDirectory:(NSURL *)captureDirectory {
  self = [super init];
  if (self) {
    _captureDirectory = captureDirectory;
    _livePreviewData = [[NSMutableData alloc] init];
  }
  return self;
}

- (BOOL)start:(NSError **)error {
  self.peripheralManager =
      [[CBPeripheralManager alloc] initWithDelegate:self
                                             queue:dispatch_get_main_queue()];

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

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
  if (peripheral.state != CBManagerStatePoweredOn) {
    NSLog(@"BLE printer is not ready (Bluetooth state: %ld).",
          (long)peripheral.state);
    return;
  }

  CBUUID *writeUUID = [CBUUID UUIDWithString:SoftverseBLEWriteUUID];
  self.bleWriteCharacteristic = [[CBMutableCharacteristic alloc]
      initWithType:writeUUID
        properties:(CBCharacteristicPropertyWrite |
                    CBCharacteristicPropertyWriteWithoutResponse)
             value:nil
       permissions:CBAttributePermissionsWriteable];
  CBMutableService *service = [[CBMutableService alloc]
      initWithType:[CBUUID UUIDWithString:SoftverseBLEServiceUUID]
           primary:YES];
  service.characteristics = @[ self.bleWriteCharacteristic ];
  [peripheral addService:service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
             didAddService:(CBService *)service
                     error:(NSError *)error {
  if (error != nil) {
    NSLog(@"Could not publish BLE printer service: %@", error.localizedDescription);
    return;
  }
  [peripheral startAdvertising:@{
    CBAdvertisementDataLocalNameKey : @"Softverse BLE Printer",
    CBAdvertisementDataServiceUUIDsKey :
        @[ [CBUUID UUIDWithString:SoftverseBLEServiceUUID] ],
  }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
  if (error != nil) {
    NSLog(@"Could not advertise BLE printer: %@", error.localizedDescription);
    return;
  }
  NSLog(@"Softverse BLE Printer is advertising and ready for Android.");
  NSLog(@"In Softverse choose Connection Type > BLE Printer; OS pairing is not required.");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
  didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
  for (CBATTRequest *request in requests) {
    if (![request.characteristic.UUID
            isEqual:[CBUUID UUIDWithString:SoftverseBLEWriteUUID]]) {
      [peripheral respondToRequest:request
                       withResult:CBATTErrorAttributeNotFound];
      continue;
    }
    if (request.value.length == 0) {
      [peripheral respondToRequest:request
                       withResult:CBATTErrorInvalidAttributeValueLength];
      continue;
    }
    if (self.bleCaptureHandle == nil) {
      [self.livePreviewData setLength:0];
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyyMMdd-HHmmss";
      NSString *stamp = [formatter stringFromDate:[NSDate date]];
      NSString *fileName =
          [NSString stringWithFormat:@"escpos-ble-%@.bin", stamp];
      NSURL *captureURL =
          [self.captureDirectory URLByAppendingPathComponent:fileName];
      [[NSFileManager defaultManager] createFileAtPath:captureURL.path
                                              contents:nil
                                            attributes:nil];
      self.bleCaptureHandle =
          [NSFileHandle fileHandleForWritingToURL:captureURL error:nil];
      NSLog(@"BLE client connected. Capturing to %@", captureURL.path);
    }
    [self.bleCaptureHandle writeData:request.value];
    [self.bleCaptureHandle synchronizeFile];
    [self scheduleLivePreviewWithData:request.value];
    NSLog(@"Received %lu BLE ESC/POS bytes (total offset: %llu).",
          (unsigned long)request.value.length,
          self.bleCaptureHandle.offsetInFile);
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
  }
}

- (void)scheduleLivePreviewWithData:(NSData *)data {
  [self.livePreviewData appendData:data];
  [self.livePreviewTimer invalidate];
  __weak ThermalPrinterEmulator *weakSelf = self;
  self.livePreviewTimer =
      [NSTimer scheduledTimerWithTimeInterval:0.35
                                      repeats:NO
                                        block:^(NSTimer *timer) {
    [weakSelf printLivePreview];
  }];
}

- (void)printLivePreview {
  const uint8_t *bytes = self.livePreviewData.bytes;
  NSUInteger length = self.livePreviewData.length;
  NSMutableArray<NSString *> *lines = [[NSMutableArray alloc] init];
  NSMutableString *run = [[NSMutableString alloc] init];

  void (^flushRun)(void) = ^{
    if (run.length < 4) {
      [run setString:@""];
      return;
    }
    while ([run hasPrefix:@"."]) {
      [run deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    if (run.length > 0) {
      [lines addObject:[run copy]];
    }
    [run setString:@""];
  };

  for (NSUInteger index = 0; index < length; index++) {
    uint8_t byte = bytes[index];
    if (byte >= 0x20 && byte <= 0x7e) {
      [run appendFormat:@"%c", byte];
    } else {
      flushRun();
    }
  }
  flushRun();

  NSString *page = [lines componentsJoinedByString:@"\n"];
  fprintf(stdout,
          "\n================ LIVE PRINT ================\n%s\n"
          "============== END LIVE PRINT ==============\n\n",
          page.UTF8String ?: "");
  fflush(stdout);
}

- (void)channelOpened:(IOBluetoothUserNotification *)notification
               channel:(IOBluetoothRFCOMMChannel *)channel {
  if (self.activeChannel != nil) {
    [self.activeChannel closeChannel];
  }
  self.activeChannel = channel;
  [channel setDelegate:self];
  [self.livePreviewData setLength:0];

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
  [self scheduleLivePreviewWithData:data];
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
  [self.livePreviewTimer invalidate];
  [self.bleCaptureHandle closeFile];
  self.bleCaptureHandle = nil;
  [self.peripheralManager stopAdvertising];
  [self.peripheralManager removeAllServices];
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
