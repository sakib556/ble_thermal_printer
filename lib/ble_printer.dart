import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:convert';

class BLEPrinterApp extends StatefulWidget {
  @override
  _BLEPrinterAppState createState() => _BLEPrinterAppState();
}

class _BLEPrinterAppState extends State<BLEPrinterApp> {
  BluetoothDevice? connectedDevice;

  List<BluetoothDevice> devicesList = [];
  BluetoothCharacteristic? printerCharacteristic;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  void scanForDevices() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
          });
        }
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() {
      connectedDevice = device;
    });

    await device.connect();

    // Discover services
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            printerCharacteristic = characteristic;
          });
        }
      }
    }
  }

  Future<void> sendPrintData(String data) async {
    if (printerCharacteristic != null) {
      List<int> encodedData = utf8.encode(data);
      await printerCharacteristic!.write(encodedData);
    }
  }

  Widget buildDeviceList() {
    return ListView.builder(
      itemCount: devicesList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(devicesList[index].advName),
          subtitle: Text(devicesList[index].remoteId.toString()),
          onTap: () async {
            await connectToDevice(devicesList[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Printer'),
      ),
      body: connectedDevice == null
          ? buildDeviceList()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Connected to: ${connectedDevice!.name}"),
                  ElevatedButton(
                    onPressed: () async {
                      await sendPrintData(
                          "Hello from Flutter!\nI am kazi Shakib.\nPrint Successfully.\n\n\n\n\n\n\n\n\n");
                    },
                    child: Text('Print Text'),
                  ),
                ],
              ),
            ),
    );
  }
}
