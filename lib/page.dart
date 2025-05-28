import 'package:and_inv/database_helpler.dart';
import 'package:and_inv/position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:intl/intl.dart';

DatabaseHelper databaseHelper = DatabaseHelper();

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final accelerometerEventsStream = useStream(accelerometerEvents);
    final userAccelerometerEventStream = useStream(userAccelerometerEvents);
    final data = useState<Map<String, Object>>({});
    final stackData = useState<List<Map<String, Object>>>([]);
    final isRecording = useState(false);
    final timestampFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final buffer = useState<List<Map<String, Object>>>([]);

    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        Future(() async {
          final event = userAccelerometerEventStream.data;

          if (event != null) {
            final timestamp = timestampFormat.format(DateTime.now());

            double latitude = 0.0;
            double longitude = 0.0;

            try {
              PositionHelper positionHelper = PositionHelper();
              Map<String, double> position =
                  await positionHelper.getCurrentPosition();
              latitude = position['latitude']!;
              longitude = position['longitude']!;
            } catch (e) {
              print('Error while fetching location: $e');
            }

            final entry = {
              'timestamp': timestamp,
              'useraccelerometerData_X': event.x,
              'useraccelerometerData_Y': event.y,
              'useraccelerometerData_Z': event.z,
              'location_latitude': latitude,
              'location_longitude': longitude,
            };

            buffer.value = [...buffer.value, entry];

            if (buffer.value.length >= 500) {
              final batchToInsert =
                  List<Map<String, Object>>.from(buffer.value);
              buffer.value = [];
              await databaseHelper.insertBatch(batchToInsert);
            }
          }
        });
      });

      return timer.cancel;
    }, [isRecording.value]);

    // Future(() async {
    //   try {
    //     // 現在位置を取得
    //     PositionHelper positionHelper = PositionHelper();
    //     Map<String, double> position =
    //         await positionHelper.getCurrentPosition();

    //     final latitude = position['latitude']!;
    //     final longitude = position['longitude']!;
    //     final accelerometerDataTimestamp = accelerometerData.timestamp;
    //     final userAccelerometerDataTimestamp = event.timestamp;

    //     // データマップを作成
    //     final newDataMap = {
    //       'accelerometerDataTimestamp':
    //           timestampFormat.format(accelerometerDataTimestamp),
    //       'userAccelerometerDataTimestamp':
    //           timestampFormat.format(userAccelerometerDataTimestamp),
    //       'accelerometerData_X': accelerometerData.x,
    //       'accelerometerData_Y': accelerometerData.y,
    //       'accelerometerData_Z': accelerometerData.z,
    //       'userAccelerometerData_X': userAccelerometerData_X.x,
    //       'userAccelerometerData_Y': userAccelerometerData_Y.y,
    //       'userAccelerometerData_Z': userAccelerometerData_Z.z,
    //       'location_latitude': latitude,
    //       'location_longitude': longitude,
    //     };

    //     stackData.value = [...stackData.value, newDataMap];
    //     if (stackData.value.length == 100) {
    //       // データベースに挿入
    //       await databaseHelper.insertListData(stackData.value);
    //       stackData.value = [];
    //     }

    //     // 状態を更新
    //     data.value = newDataMap;

    //     // print(
    //     //     'Data recorded: Lat=$latitude, Long=$longitude at $timestamp');
    //   } catch (e) {
    //     print('Error while fetching location: $e');
    //   }
    // });
    //     }
    //   });

    //   // クリーンアップ処理：タイマーを停止
    //   return timer.cancel;
    // }, [isRecording.value]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isRecording.value
                ? const Text('Recording data...')
                : const Text('Recording stopped.'),
            const SizedBox(height: 20),
            data.value.isEmpty
                ? const Text('Waiting for accelerometer data...')
                : Column(
                    children: [
                      Text(
                          'Timestamp1 : ${data.value['accelerometerDataTimestamp']}'),
                      Text(
                          'Timestamp2 : ${data.value['userAccelerometerDataTimestamp']}'),
                      Text('x : ${data.value['accelerometerData_X']}'),
                      Text('y : ${data.value['accelerometerData_Y']}'),
                      Text('z : ${data.value['accelerometerData_Z']}'),
                      Text('latitude : ${data.value['location_latitude']}'),
                      Text('longitude : ${data.value['location_longitude']}'),
                    ],
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    isRecording.value = true;
                  },
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    isRecording.value = false;
                  },
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
