import 'package:and_inv/database_helpler.dart';
import 'package:and_inv/position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

DatabaseHelper databaseHelper = DatabaseHelper();

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final gyroscopeEventsStream = useStream(gyroscopeEventStream());
    // final gyroscopeData = gyroscopeEventsStream.data;

    final accelerometerEventsStream = useStream(accelerometerEvents);

    final userAccelerometerEventStream = useStream(userAccelerometerEvents);

    final data = useState<Map<String, Object>>({});
    final isRecording = useState(false);

    useEffect(() {
      // if (!isRecording.value) return null;

      final accelerometerData = accelerometerEventsStream.data;
      final userAccelerometerData = userAccelerometerEventStream.data;
      final gyroscopeEventData = gyroscopeEventsStream.data;

      if (accelerometerData != null && userAccelerometerData != null) {
        Future(() async {
          try {
            // 現在位置を取得
            PositionHelper positionHelper = PositionHelper();
            Map<String, double> position =
                await positionHelper.getCurrentPosition();

            final latitude = position['latitude']!;
            final longitude = position['longitude']!;
            final timestamp = DateTime.now().toIso8601String();

            // データマップを作成
            final newDataMap = {
              'timestamp': timestamp,
              'accelerometerData_X': accelerometerData.x,
              'accelerometerData_Y': accelerometerData.y,
              'accelerometerData_Z': accelerometerData.z,
              'userAccelerometerData_X': userAccelerometerData.x,
              'userAccelerometerData_Y': userAccelerometerData.y,
              'userAccelerometerData_Z': userAccelerometerData.z,
              'location_latitude': latitude, // 緯度
              'location_longitude': longitude, // 経度
            };

            // データベースに挿入
            await databaseHelper.insertUser(newDataMap);

            // 状態を更新
            data.value = newDataMap;

            // デバッグ用の出力
            //print('Timestamp : ${data.value.last['timestamp']}');
            print(
                'Location : Lat=${position['latitude']}, Long=${position['longitude']}');
          } catch (e) {
            print('Error while fetching location: $e');
          }
        });
      }

      return null;
    }, [accelerometerEventsStream.data, userAccelerometerEventStream.data]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: data.value.isEmpty
            ? const Text('Waiting for accelerometer data...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Timestamp : ${data.value['timestamp']}'),
                  Text('x : ${data.value['accelerometerData_X']}'),
                  Text('y: ${data.value['accelerometerData_Y']}'),
                  Text('z: ${data.value['accelerometerData_Z']}'),
                  Text('latitude: ${data.value['latitude']}'),
                  Text('longitude: ${data.value['longitude']}')
                ],
              ),
      ),
    );
  }
}
