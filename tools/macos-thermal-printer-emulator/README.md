# Softverse macOS thermal printer emulator

This native macOS utility publishes both a BLE GATT thermal-printer service and
a legacy Bluetooth Classic Serial Port Profile (SPP) service. It accepts raw
ESC/POS print jobs and stores them as timestamped `.bin` files in `captures/`.

## Build and start

```bash
cd tools/macos-thermal-printer-emulator
./build.sh
./run.sh
```

Keep the terminal open. On first use, allow Bluetooth access for the emulator
or Terminal in macOS System Settings if prompted.

## Connect an Android device (recommended BLE path)

1. Turn on Bluetooth on the Mac and Android device and keep `./run.sh` running.
2. In Softverse, open **More > Printer > Add Printer**.
3. Set **Connection Type** to **BLE Printer**.
4. Open **Printer Model**, rescan, and select **Softverse BLE Printer**.
5. Tap **PRINT TEST** or save it and print a receipt.
6. The printable receipt page appears live in the emulator Terminal between
   `LIVE PRINT` markers. A raw `captures/escpos-ble-*.bin` file is also saved.

BLE does not require pairing the phone and Mac in the operating-system
Bluetooth settings. The legacy **Bluetooth** option remains available for real
Classic SPP printers and writes captures named `escpos-*.bin` when macOS permits
an incoming RFCOMM connection.

## Important limitations

- Current macOS versions and Bluetooth adapters may restrict Classic discoverability,
  phone-to-Mac pairing, or third-party incoming RFCOMM services. The utility
  reports failure if macOS refuses to publish the service.
- Captured files contain the exact raw ESC/POS bytes. Successful capture proves
  pairing, discovery, RFCOMM connection, and byte transport, but it cannot prove
  a particular physical printer's paper cutting, code page, or image support.
- If Android cannot pair with the Mac or cannot open its SPP service, use a USB
  Bluetooth adapter with Linux/BlueZ peripheral support for hardware-level
  emulation; the in-app Virtual Printer remains the deterministic UI fallback.
