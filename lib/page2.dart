// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:and_inv/database_helpler.dart'; // ★ ご自身のパスに合わせて修正

// class AccelerometerPage extends StatefulWidget {
//   @override
//   _AccelerometerPageState createState() => _AccelerometerPageState();
// }

// class _AccelerometerPageState extends State<AccelerometerPage> {
//   final List<Map<String, dynamic>> _buffer = []; // ★ バッファリング用リスト
//   DateTime? _lastTimestamp;
//   StreamSubscription<AccelerometerEvent>? _subscription;

//   @override
//   void initState() {
//     super.initState();
//     _startListening(); // ★ センサーデータの監視を開始
//   }

//   // ★ センサーイベントを10Hzで処理
//   void _startListening() {
//     _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
//       final now = DateTime.now();

//       if (_lastTimestamp == null ||
//           now.difference(_lastTimestamp!).inMilliseconds >= 100) {
//         _lastTimestamp = now;
//         _saveAccelerometerData(event.x, event.y, event.z);
//       }
//     });
//   }

//   // ★ データをバッファして20件ごとにDBに一括保存
//   void _saveAccelerometerData(double x, double y, double z) {
//     final timestamp = DateTime.now();

//     _buffer.add({
//       'x': x,
//       'y': y,
//       'z': z,
//       'timestamp': timestamp.toIso8601String(),
//     });

//     if (_buffer.length >= 20) {
//       final List<Map<String, dynamic>> batch = List.from(_buffer);
//       _buffer.clear();

//       Future(() async {
//         final db = await DatabaseHelper.instance.database;
//         await db.transaction((txn) async {
//           for (final row in batch) {
//             await txn.insert('sensor_data', row);
//           }
//         });
//       });
//     }
//   }

//   // ★ アプリ終了前などに未挿入のデータを保存
//   Future<void> _flushBuffer() async {
//     if (_buffer.isNotEmpty) {
//       final db = await DatabaseHelper.instance.database;
//       await db.transaction((txn) async {
//         for (final row in _buffer) {
//           await txn.insert('sensor_data', row);
//         }
//       });
//       _buffer.clear();
//     }
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     _flushBuffer(); // ★ バッファのフラッシュを忘れずに
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Accelerometer Logger (10Hz)')),
//       body: Center(
//         child: Text(
//           'Logging accelerometer data at 10Hz...',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
