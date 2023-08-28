import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mocheffendi.hilux_sensor/notification.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:quick_blue_sensor/homeui.dart';
import 'package:mocheffendi.hilux_sensor/sensor_view.dart';
import 'package:badges/badges.dart' as badges;

// import 'logger.dart';
// import 'package:restart_app/restart_app.dart';

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
// final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
// final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const MyApp());
    });
  } else {
    runApp(const MyApp());
  }
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hilux Sensor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hilux Sensor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // FlutterBluePlus.setLogLevel(LogLevel.verbose, color:true);
  // late FlutterBluePlus flutterBlue;

  // final void Function(String message) _logMessage;
  // FlutterBluePlus flutterBlue = FlutterBluePlus();
  // late BluetoothDevice targetdevice;
  // String macAddress = "38D9D5EA-2A41-0D32-0AB6-43A1B4CF0806"; // MacOS //crash
  // String macAddress = "3F896082-AD65-2B7A-F629-9F9B6F03ED45"; //unit esp baru
  String macAddress = "24:0A:C4:09:B9:0A";
  // String macAddress = "84:0D:8E:23:7B:AA";
  String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  // ignore: non_constant_identifier_names
  String charaCteristic_uuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  late bool isReady;
  late Stream<List<int>> stream;
  late List _temphumidata;
  double _temp = 0;
  double _humidity = 0;
  List<String> _logMessages = [];
  DateFormat formatter = DateFormat('HH:mm:ss.SSS');

  @override
  void initState() {
    // controller = AnimationController(
    //   /// [AnimationController]s can be created with `vsync: this` because of
    //   /// [TickerProviderStateMixin].
    //   vsync: this,
    //   duration: const Duration(seconds: 5),
    // )..addListener(() {
    //     setState(() {});
    //   });
    // controller.repeat(reverse: true);
    super.initState();
    isReady = false;
    // connectToDevice();
    scanAndConnect();
  }

  @override
  void dispose() {
    // controller.dispose();
    // targetdevice.disconnect();
    // disconnectDevice(device);
    super.dispose();
  }

  // void _addLogMessage(String message) {
  //   setState(() {
  //     _logMessages.add(message);
  //   });
  // }

  void addToLog(String message) {
    final now = DateTime.now();
    _logMessages.add('${formatter.format(now)} | $message');
  }

  // Function to scan for nearby Bluetooth devices and connect to the desired device using its UUID.
  void scanAndConnect() async {
    // addToLog('Starting Scan Bluetooth Device');
    final snackBar = SnackBar(
      content: buildSnackbar('Starting Scan Bluetooth Devices'),
      // Text("Start scanning Bluetooth devices"),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 4),
    );
    snackBarKeyA.currentState?.showSnackBar(snackBar);
    try {
      // Start scanning for Bluetooth devices.
      var scanResults = await FlutterBluePlus.startScan(
        timeout: Duration(milliseconds: 100),
        // withDevices: [Guid(macAddress)],
      );

      scanResults = await FlutterBluePlus.startScan(
        timeout: Duration(milliseconds: 2000),
        // withDevices: [Guid(macAddress)],
      );

      // Find the desired device by its UUID.
      if (Platform.isAndroid) {
        // macAddress = "24:0A:C4:09:B9:0A";
        // macAddress = "80:7D:3A:C5:3B:F2";
        macAddress = "84:0D:8E:23:7B:AA";
      } else {
        // macAddress = "38D9D5EA-2A41-0D32-0AB6-43A1B4CF0806";
        // macAddress = "DA47CFB8-9592-6D47-B155-625BE7ED854E";
        macAddress = "3F896082-AD65-2B7A-F629-9F9B6F03ED45";
      }
      BluetoothDevice? desiredDevice; // Make the variable nullable with '?'
      for (ScanResult scanResult in scanResults) {
        addToLog("Scanning devices: ${scanResult.device.remoteId.toString()}");
        final snackBar = SnackBar(
          content: buildSnackbar(
              "Scanning devices: ${scanResult.device.remoteId.toString()}"),
          // Text("Scanning devices: ${scanResult.device.remoteId.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 1),
        );
        snackBarKeyA.currentState?.showSnackBar(snackBar);
        if (scanResult.device.remoteId.toString() == macAddress) {
          desiredDevice = scanResult.device;
          break;
        }
      }

      // If the desired device is found, connect to it.
      // ignore: unnecessary_null_comparison
      if (desiredDevice != null) {
        try {
          await desiredDevice.connect(
              autoConnect:
                  true); // Set autoConnect to true if you want auto-reconnect.
          // print('Connected to device: ${desiredDevice.localName}');
          addToLog("Connected to device: ${desiredDevice.localName}");
          final snackBar = SnackBar(
            content: buildSnackbar(
                "Connected to device: ${desiredDevice.localName}"),
            // Text("Connected to device: ${desiredDevice.localName}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 1),
          );
          snackBarKeyA.currentState?.showSnackBar(snackBar);

          // You can now discover services and characteristics to communicate with the device.
          // print('Start discovering services to device:');
          discoverServices(desiredDevice);
        } catch (e) {
          // print('Error connecting to device: $e');
          addToLog("Error connecting to device:");
          final snackBar = SnackBar(
            content: Text(prettyException("Error connecting to device:", e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 1),
          );
          snackBarKeyA.currentState?.showSnackBar(snackBar);
        }
      } else {
        // print('Desired device not found.');
        addToLog("Bluetooth Device not found.");
        final snackBar = SnackBar(
          content: buildSnackbar("Bluetooth Device not found."),
          // Text("Bluetooth Device not found."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 1),
        );
        snackBarKeyA.currentState?.showSnackBar(snackBar);
      }
    } catch (e) {
      // print('Error scanning for devices: $e');
      addToLog("Error scanning for devices.");
      final snackBar = SnackBar(
        content: buildSnackbar("Error scanning for devices."),
        // Text("Error scanning for devices."),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 1),
      );
      snackBarKeyA.currentState?.showSnackBar(snackBar);
    }
  }

// Function to discover services and characteristics on the connected device using the UUID.
  discoverServices(BluetoothDevice device) async {
    addToLog("Start Discovering Services.");
    final snackBar = SnackBar(
      content: buildSnackbar("Start Discovering Services."),
      // Text("Start Discovering Services."),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 1),
    );
    snackBarKeyA.currentState?.showSnackBar(snackBar);
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == charaCteristic_uuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.lastValueStream;

            setState(() {
              isReady = true;
            });
          }
        }
      }
    }
    // try {
    //   // Discover services on the connected device.
    //   List<BluetoothService> services = await device.discoverServices();
    //   for (BluetoothService service in services) {
    //     // Check if this is the service you want by comparing its UUID.
    //     if (service.uuid.toString() == serviceUuid) {
    //       // Now, you can work with characteristics within this service.
    //       // Access characteristics with service.characteristics.
    //       // For example, if you want to read a characteristic:
    //       BluetoothCharacteristic characteristic = service.characteristics
    //           .firstWhere((c) => c.uuid.toString() == charaCteristic_uuid);
    //       // ignore: unnecessary_null_comparison
    //       if (characteristic != null) {
    //         List<int> value = await characteristic.read();
    //         print('Characteristic value: $value');
    //       } else {
    //         print('Characteristic not found.');
    //       }
    //     }
    //   }
    // } catch (e) {
    //   print('Error discovering services: $e');
    // }
  }

  disconnectDevice(BluetoothDevice device) {
    device.disconnect();
  }

  // void scanAndConnect() async {
  //   try {
  //     // Start scanning for Bluetooth devices.
  //     var scanResults =
  //         await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

  //     // Find the desired device by its UUID.
  //     BluetoothDevice? desiredDevice; // Make the variable nullable with '?'
  //     for (ScanResult scanResult in scanResults) {
  //       print('device: ${scanResult.device.remoteId.toString()}');
  //       if (scanResult.device.remoteId.toString() == macAddress) {
  //         desiredDevice = scanResult.device;
  //         break;
  //       }
  //     }

  //     // // Start scanning for Bluetooth devices.
  //     scanResults =
  //         await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

  //     // Find the desired device by its UUID.
  //     // BluetoothDevice? desiredDevice; // Make the variable nullable with '?'
  //     for (ScanResult scanResult in scanResults) {
  //       if (scanResult.device.remoteId.toString() == macAddress) {
  //         desiredDevice = scanResult.device;
  //         break;
  //       }
  //     }

  //     // If the desired device is found, connect to it.
  //     if (desiredDevice != null) {
  //       try {
  //         await desiredDevice.connect(
  //             autoConnect:
  //                 false); // Set autoConnect to true if you want auto-reconnect.
  //         print('Connected to device: ${desiredDevice.localName}');

  //         // You can now discover services and characteristics to communicate with the device.
  //         await discoverServices(desiredDevice);
  //       } catch (e) {
  //         print('Error connecting to device: $e');
  //       }
  //     } else {
  //       print('Desired device not found.');
  //     }
  //   } catch (e) {
  //     print('Error scanning for devices: $e');
  //   }
  // }

  // Function to scan for nearby Bluetooth devices and connect to the desired device using its UUID.
  // void scanAndConnect() async {
  //   try {
  //     // Start scanning for Bluetooth devices.
  //     var scanResults =
  //         await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

  //     // Find the desired device by its UUID.
  //     BluetoothDevice? desiredDevice;
  //     for (ScanResult scanResult in scanResults) {
  //       print('device: ${scanResult.device.remoteId.toString()}');
  //       if (scanResult.device.remoteId.toString() == macAddress) {
  //         desiredDevice = scanResult.device;
  //         break;
  //       }
  //     }

  //     // If the desired device is found, connect to it.
  //     // ignore: unnecessary_null_comparison
  //     // if (targetdevice != null) {
  //     try {
  //       await desiredDevice!.connect(
  //           autoConnect: false,
  //           timeout: Duration(
  //               seconds:
  //                   5)); // Set autoConnect to true if you want auto-reconnect.
  //       print('Connected to device: ${desiredDevice.localName}');

  //       // You can now discover services and characteristics to communicate with the device.
  //       // discoverServices();
  //     } catch (e) {
  //       print('Error connecting to device: $e');
  //     }
  //     // } else {
  //     //   print('Desired device not found.');
  //     // }
  //   } catch (e) {
  //     print('Error scanning for devices: $e');
  //   }
  // }

  scanconnect() async {
    // try {
    // var scanResults = await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    // }
    // Setup Listener for scan results
    // var hasilscanning = FlutterBluePlus.scanResults.listen((results) async {
    //   Future<ScanResult> localDevice = (result) => result.device.remoteId.toString() == macAddress);
    //   // if (results.device.remoteId.toString() == macAddress)
    //   // print(subscription.toString());
    //   for (ScanResult r in results) {
    //     print('${r.device.localName} found! rssi: ${r.rssi}');
    //   }
    // });
    // try {
    //   // Start scanning for Bluetooth devices.
    //   FlutterBluePlus.scan(timeout: Duration(seconds: 5))
    //       .listen((scanResult) async {
    //     // Check if the desired device is found using its deviceId.
    //     if (scanResult.device.remoteId.toString() == macAddress) {
    //       targetdevice = scanResult.device;
    //       print(targetdevice.toString());

    //       try {
    //         // Connect to the desired device.
    //         await targetdevice.connect(
    //             autoConnect:
    //                 false); // Set autoConnect to true if you want auto-reconnect.
    //         print('Connected to device: ${targetdevice.localName}');

    //         // You can now discover services and characteristics to communicate with the device.
    //         // discoverServices();
    //       } catch (e) {
    //         print('Error connecting to device: $e');
    //       }
    //     }
    //   });
    // } catch (e) {
    //   print('Error scanning for devices: $e');
    // }
    // Setup Listener for scan results
    // var hasilscan = FlutterBluePlus.scanResults.listen((results) {

    //   // print(subscription.toString());
    //   for (ScanResult r in results) {
    //     print('${r.device.localName} found! rssi: ${r.rssi}');
    //   }
    // });

    // var hasilscanning = FlutterBluePlus.scan(timeout: Duration(seconds: 5));
    // Future<ScanResult> localDevice = hasilscanning.firstWhere(
    //     (result) => result.device.remoteId.toString() == macAddress);

    // // Start scanning
    // FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    // // Stop scanning
    // FlutterBluePlus.stopScan();

    // try {
    //   // Start scanning for Bluetooth devices.
    //   FlutterBluePlus.startScan(
    //           timeout: Duration(seconds: 5), androidUsesFineLocation: false)
    //       .then((scanResult) async {
    //     // Check if the desired device is found using its deviceId.
    //     if (scanResult.device.remoteId.toString() == macAddress) {
    //       targetdevice = scanResult.device;

    //       try {
    //         // Connect to the desired device.
    //         await targetdevice.connect(
    //             autoConnect:
    //                 false); // Set autoConnect to true if you want auto-reconnect.
    //         print('Connected to device: ${targetdevice.localName}');

    //         // You can now discover services and characteristics to communicate with the device.
    //         discoverServices();
    //       } catch (e) {
    //         print('Error connecting to device: $e');
    //       }
    //     }
    //   });
    // } catch (e) {
    //   print('Error scanning for devices: $e');
    // }

    // try {
    //   StreamBuilder<List<ScanResult>> scanResults =
    //       await flutterBlue.startScan(timeout: Duration(seconds: 5));
    //   ScanResult desiredResult = scanResults.(
    //       (result) => result.device.remoteId.toString() == macAddress);
    //   device = desiredResult.device;

    //   if (device != null) {
    //     await device.connect(
    //         autoConnect:
    //             false); // Set autoConnect to true if you want auto-reconnect.
    //     print('Connected to device: ${device.name}');

    //     // You can now discover services and characteristics to communicate with the device.
    //     discoverServices();
    //   } else {
    //     print('Desired device not found.');
    //   }
    // } catch (e) {
    //   print('Error scanning or connecting: $e');
    // }
  }

  disconnectFromDevice() {
    // ignore: unnecessary_null_comparison
    // if (targetdevice == null) {
    //   // _pop();

    //   return;
    // }

    // targetdevice.disconnect();
    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Container(
    //           padding: const EdgeInsets.all(16),
    //           height: 90,
    //           decoration: const BoxDecoration(
    //               color: Colors.red,
    //               borderRadius: BorderRadius.all(Radius.circular(20))),
    //           child: const Row(
    //             children: [
    //               SizedBox(width: 48),
    //               Expanded(
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(
    //                       'Bluetooth Devices',
    //                       style: TextStyle(fontSize: 18, color: Colors.white),
    //                     ),
    //                     Text(
    //                       'Bluetooth failed to connect',
    //                       style: TextStyle(fontSize: 12, color: Colors.white),
    //                       maxLines: 2,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           )),
    //       behavior: SnackBarBehavior.floating,
    //       backgroundColor: Colors.transparent,
    //       elevation: 0,
    //       duration: const Duration(seconds: 2),
    //     ),
    //   );
    //   // Navigator.pop(context);
    // }

    // connectToDevice();
  }

  // discoverServices(BluetoothDevice device) async {
  // if (context.mounted) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Container(
  //           padding: const EdgeInsets.all(16),
  //           height: 90,
  //           decoration: const BoxDecoration(
  //               color: Colors.red,
  //               borderRadius: BorderRadius.all(Radius.circular(20))),
  //           child: const Row(
  //             children: [
  //               SizedBox(width: 48),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Bluetooth Devices',
  //                       style: TextStyle(fontSize: 18, color: Colors.white),
  //                     ),
  //                     Text(
  //                       'Starting Discovering Services...',
  //                       style: TextStyle(fontSize: 12, color: Colors.white),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           )),
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  //   // Navigator.pop(context);
  // }
  // ignore: unnecessary_null_comparison
  // if (targetdevice == null) {
  //   // _pop();
  //   return;
  // }

  // List<BluetoothService> services = await targetdevice.discoverServices();
  // for (var service in services) {
  //   if (service.uuid.toString() == serviceUuid) {
  //     for (var characteristic in service.characteristics) {
  //       if (characteristic.uuid.toString() == charaCteristic_uuid) {
  //         characteristic.setNotifyValue(!characteristic.isNotifying);
  //         stream = characteristic.lastValueStream;

  //         setState(() {
  //           isReady = true;
  //         });
  //       }
  //     }
  //   }
  // }

  // if (!isReady) {
  // _pop();
  // }
  // else {
  //   if (context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Container(
  //             padding: const EdgeInsets.all(16),
  //             height: 90,
  //             decoration: const BoxDecoration(
  //                 color: Colors.red,
  //                 borderRadius: BorderRadius.all(Radius.circular(20))),
  //             child: const Row(
  //               children: [
  //                 SizedBox(width: 48),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Bluetooth Devices',
  //                         style: TextStyle(fontSize: 18, color: Colors.white),
  //                       ),
  //                       Text(
  //                         'Discovering Services Found',
  //                         style: TextStyle(fontSize: 12, color: Colors.white),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             )),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //     // Navigator.pop(context);
  //   }
  // }
  // }

  // connectToDevice() async {
  //   // if (context.mounted) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     SnackBar(
  //   //       content: Container(
  //   //           padding: const EdgeInsets.all(16),
  //   //           height: 90,
  //   //           decoration: const BoxDecoration(
  //   //               color: Colors.red,
  //   //               borderRadius: BorderRadius.all(Radius.circular(20))),
  //   //           child: const Row(
  //   //             children: [
  //   //               SizedBox(width: 48),
  //   //               Expanded(
  //   //                 child: Column(
  //   //                   crossAxisAlignment: CrossAxisAlignment.start,
  //   //                   children: [
  //   //                     Text(
  //   //                       'Bluetooth Devices',
  //   //                       style: TextStyle(fontSize: 18, color: Colors.white),
  //   //                     ),
  //   //                     Text(
  //   //                       'Trying to connect to a Bluetooth device',
  //   //                       style: TextStyle(fontSize: 12, color: Colors.white),
  //   //                       maxLines: 2,
  //   //                       overflow: TextOverflow.ellipsis,
  //   //                     ),
  //   //                   ],
  //   //                 ),
  //   //               ),
  //   //             ],
  //   //           )),
  //   //       behavior: SnackBarBehavior.floating,
  //   //       backgroundColor: Colors.transparent,
  //   //       elevation: 0,
  //   //       duration: const Duration(seconds: 2),
  //   //     ),
  //   //   );
  //   //   // Navigator.pop(context);
  //   // }
  //   // ignore: unnecessary_null_comparison

  //   targetdevice = BluetoothDevice.fromId(macAddress);

  //   // if (targetdevice == null) {
  //   //   // _pop();
  //   //   return;
  //   // }

  //   Timer(const Duration(seconds: 15), () {
  //     if (!isReady) {
  //       disconnectFromDevice();
  //       // _pop();
  //     }
  //   });

  //   await targetdevice!.connect();
  //   // if (context.mounted) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     SnackBar(
  //   //       content: Container(
  //   //           padding: const EdgeInsets.all(16),
  //   //           height: 90,
  //   //           decoration: const BoxDecoration(
  //   //               color: Colors.red,
  //   //               borderRadius: BorderRadius.all(Radius.circular(20))),
  //   //           child: const Row(
  //   //             children: [
  //   //               SizedBox(width: 48),
  //   //               Expanded(
  //   //                 child: Column(
  //   //                   crossAxisAlignment: CrossAxisAlignment.start,
  //   //                   children: [
  //   //                     Text(
  //   //                       'Bluetooth Devices',
  //   //                       style: TextStyle(fontSize: 18, color: Colors.white),
  //   //                     ),
  //   //                     Text(
  //   //                       'Bluetooth is connected',
  //   //                       style: TextStyle(fontSize: 12, color: Colors.white),
  //   //                       maxLines: 2,
  //   //                       overflow: TextOverflow.ellipsis,
  //   //                     ),
  //   //                   ],
  //   //                 ),
  //   //               ),
  //   //             ],
  //   //           )),
  //   //       behavior: SnackBarBehavior.floating,
  //   //       backgroundColor: Colors.transparent,
  //   //       elevation: 0,
  //   //       duration: const Duration(seconds: 2),
  //   //     ),
  //   //   );
  //   //   // Navigator.pop(context);
  //   // }

  //   discoverServices();
  // }

  buildSnackbar(String message) {
    return Container(
        padding: const EdgeInsets.all(16),
        height: 100,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.1,
                // 0.4,
                // 0.6,
                0.9,
              ],
              colors: [
                Color.fromARGB(255, 38, 17, 11),
                // Colors.red,
                // Colors.indigo,
                Color.fromARGB(255, 88, 119, 122),
              ],
            ),
            // color: Colors.deepOrange,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bluetooth Devices',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    '$message',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  String prettyException(String prefix, dynamic e) {
    if (e is FlutterBluePlusException) {
      return "$prefix ${e.errorString}";
    } else if (e is PlatformException) {
      return "$prefix ${e.message}";
    }
    return prefix + e.toString();
  }

  Future<bool> onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to disconnect device and go back?'),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () {
                disconnectFromDevice();
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  String dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  _appBar(height) => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 125),
        child: Stack(
          children: <Widget>[
            // AppBar(
            //   backgroundColor: Colors.black87,
            //   elevation: 0.0,
            //   centerTitle: true,
            //   title: const Text(
            //     'Hilux | Temperature Sensor',
            //     style: TextStyle(
            //         fontSize: 17, color: Colors.white, letterSpacing: 0.53),
            //   ),
            //   shape: const RoundedRectangleBorder(
            //       borderRadius:
            //           BorderRadius.vertical(bottom: Radius.circular(30))),
            //   leading: InkWell(
            //     onTap: () {},
            //     child: const Icon(
            //       Icons.subject,
            //       color: Colors.white,
            //     ),
            //   ),
            //   actions: [
            //     InkWell(
            //       onTap: () {},
            //       child: const Padding(
            //         padding: EdgeInsets.all(8.0),
            //         child: Icon(
            //           Icons.notifications,
            //           size: 20,
            //         ),
            //       ),
            //     )
            //   ],
            //   // bottom: PreferredSize(
            //   //   preferredSize: Size(MediaQuery.of(context).size.width, 110),
            //   //   child: Stack(
            //   //     children: [
            //   //       Container(
            //   //         padding: const EdgeInsets.only(left: 30, bottom: 20),
            //   //         child: const Text(
            //   //           "data",
            //   //           style: TextStyle(color: Colors.white),
            //   //         ),
            //   //       ),
            //   //     ],
            //   //   ),
            //   // )
            // ),
            Container(
              // Background

              height: height + 90,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
              ), // Background
              child: const Center(
                child: Text(
                  "Hilux Temperature Sensor",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 30,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage(
                                logMessages: _logMessages,
                              )));
                },
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: badges.Badge(
                      badgeAnimation: badges.BadgeAnimation.fade(),
                      badgeContent: Text(_logMessages.length.toString()),
                      child: Icon(Icons.notifications,
                          size: 28, color: Colors.white),
                    )),
              ),
            ),
            Container(), // Required some widget in between to float AppBar
            Positioned(
              top: 105,
              left: 20,
              right: 20,
              child:
                  // Container(
                  //   height: 50,
                  //   child:
                  //   Card(
                  //     elevation: 50.0,
                  //     child: Center(
                  //       child: Text('Dashboard'),
                  //     ),
                  //   ),
                  // ),
                  Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      stops: [
                        0.1,
                        // 0.4,
                        // 0.6,
                        0.9,
                      ],
                      colors: [
                        Color.fromARGB(255, 38, 17, 11),
                        // Colors.red,
                        // Colors.indigo,
                        Color.fromARGB(255, 88, 119, 122),
                      ],
                    ),
                    // color: Colors.deepOrange,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                height: 70,
                // color: Colors.deepOrange,
                child: const Center(
                    child: Text(
                  'Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                )),
              ),
            ),
            // Positioned(
            //   // To take AppBar Size only
            //   top: 130.0,
            //   left: 20.0,
            //   right: 20.0,
            //   child: AppBar(
            //     backgroundColor: Colors.orangeAccent,
            //     leading: Icon(
            //       Icons.menu,
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     primary: false,
            //     title: const TextField(
            //         decoration: InputDecoration(
            //             hintText: "Search",
            //             border: InputBorder.none,
            //             hintStyle: TextStyle(color: Colors.grey))),
            //     actions: <Widget>[
            //       IconButton(
            //         icon: Icon(Icons.search,
            //             color: Theme.of(context).primaryColor),
            //         onPressed: () {},
            //       ),
            //       IconButton(
            //         icon: Icon(Icons.notifications,
            //             color: Theme.of(context).primaryColor),
            //         onPressed: () {},
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: ScaffoldMessenger(
          key: snackBarKeyA,
          child: Scaffold(
            appBar: _appBar(AppBar().preferredSize.height),
            // appBar: AppBar(
            //     backgroundColor: Colors.black87,
            //     centerTitle: true,
            //     title: const Text(
            //       'Hilux | Temperature Sensor',
            //       style: TextStyle(
            //           fontSize: 17, color: Colors.white, letterSpacing: 0.53),
            //     ),
            //     shape: const RoundedRectangleBorder(
            //         borderRadius:
            //             BorderRadius.vertical(bottom: Radius.circular(30))),
            //     leading: InkWell(
            //       onTap: () {},
            //       child: const Icon(
            //         Icons.subject,
            //         color: Colors.white,
            //       ),
            //     ),
            //     actions: [
            //       InkWell(
            //         onTap: () {},
            //         child: const Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Icon(
            //             Icons.notifications,
            //             size: 20,
            //           ),
            //         ),
            //       )
            //     ],
            //     bottom: PreferredSize(
            //       preferredSize: Size(MediaQuery.of(context).size.width, 110),
            //       child: Stack(
            //         children: [
            //           Container(
            //             padding: const EdgeInsets.only(left: 30, bottom: 20),
            //             child: const Text(
            //               "data",
            //               style: TextStyle(color: Colors.white),
            //             ),
            //           ),
            //         ],
            //       ),
            //     )),
            body: Container(
                child: !isReady
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : StreamBuilder<List<int>>(
                        stream: stream,

                        // Stream.periodic(const Duration(milliseconds: 50)),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<int>> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            // geting data from bluetooth
                            var currentValue = dataParser(snapshot.requireData);
                            _temphumidata = currentValue.split(",");
                            if (_temphumidata[0] != "nan") {
                              if (_temphumidata[0].isNotEmpty &&
                                  _temphumidata[0] != null) {
                                _humidity = double.parse('${_temphumidata[1]}'
                                    // .replaceAll(RegExp(r'[^0-9.]'), '')
                                    );
                              }
                            }
                            if (_temphumidata[0] != "nan") {
                              if (_temphumidata[0].isNotEmpty &&
                                  _temphumidata[0] != null) {
                                _temp = double.parse('${_temphumidata[0]}'
                                    // .replaceAll(RegExp(r'[^0-9.]'), '')
                                    );
                              }
                            }
                            return SensorView(
                              humidity: _humidity,
                              temperature: _temp,
                            );
                          } else {
                            return const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  Text('Check the stream'),
                                ],
                              ),
                            );
                            // Text('Check the stream');
                          }
                        },
                      )),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // disconnectFromDevice();
                final snackBar = SnackBar(
                  content: buildSnackbar("Restarting..."),
                  // Text("Restarting..."),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  duration: const Duration(seconds: 1),
                );
                snackBarKeyA.currentState?.showSnackBar(snackBar);
                scanAndConnect();
                // Restart.restartApp();
              },
              backgroundColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              tooltip: 'Restart',
              child: const Icon(Icons.restart_alt, size: 36),
            ),
          ),
        ),
      ),
    );
  }
}
