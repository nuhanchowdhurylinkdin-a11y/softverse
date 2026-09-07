# Softverse macOS thermal printer emulator

This native macOS utility publishes the Bluetooth Classic Serial Port Profile
(SPP) service used by the Android `print_bluetooth_thermal` plugin. It accepts
incoming RFCOMM connections and stores each received ESC/POS print job as a
timestamped `.bin` file in `captures/`.

## Build and start

```bash
cd tools/macos-thermal-printer-emulator
./build.sh
./run.sh
```

Keep the terminal open. On first use, allow Bluetooth access for the emulator
or Terminal in macOS System Settings if prompted.

## Connect an Android device

1. Turn on Bluetooth on the Mac and Android device.
2. Open Bluetooth Settings on both devices and pair the Android device with the
   Mac. The Softverse Android plugin only lists already paired devices.
3. Keep `./run.sh` running.
4. In Softverse, open **More > Printer > Add Printer**.
5. Leave **Connection Type** set to **Bluetooth**.
6. Open **Printer Model**, rescan, and select the Mac's Bluetooth name.
7. Tap **PRINT TEST** or save it and print a receipt.
8. Confirm that a new `captures/escpos-*.bin` file appears.

## Important limitations

- This targets the Android app's Bluetooth Classic SPP transport, not BLE GATT.
- Current macOS versions and Bluetooth adapters may restrict discoverability,
  phone-to-Mac pairing, or third-party incoming RFCOMM services. The utility
  reports failure if macOS refuses to publish the service.
- Captured files contain the exact raw ESC/POS bytes. Successful capture proves
  pairing, discovery, RFCOMM connection, and byte transport, but it cannot prove
  a particular physical printer's paper cutting, code page, or image support.
- If Android cannot pair with the Mac or cannot open its SPP service, use a USB
  Bluetooth adapter with Linux/BlueZ peripheral support for hardware-level
  emulation; the in-app Virtual Printer remains the deterministic UI fallback.
