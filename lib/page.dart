import 'package:and_inv/database_helpler.dart';
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

    final data = useState<List<Map<String, Object>>>([]);

    useEffect(() {
      final accelerometerData = accelerometerEventsStream.data;
      final userAccelerometerData = userAccelerometerEventStream.data;
      final gyroscopeEventData = gyroscopeEventsStream.data;

      if (accelerometerData != null && userAccelerometerData != null) {
        final timestamp = DateTime.now().toIso8601String();
        final newDataMap = {
            'timestamp' : timestamp,
            'accelerometerData_X' : accelerometerData.x,
            'accelerometerData_Y' : accelerometerData.y,
            'accelerometerData_Z' : accelerometerData.z,
            'userAccelerometerData_X' : userAccelerometerData.x,
            'userAccelerometerData_Y' : userAccelerometerData.y,
            'userAccelerometerData_Z' : userAccelerometerData.z,
            //'locations_latitude' : gyroscopeEventData,
          };
        databaseHelper.insertUser(newDataMap);
        data.value = [
          ...data.value, newDataMap
        ];
        print('Timestamp : ${data.value.last['timestamp']}');
      }
      return null;
    }, [accelerometerEventsStream.data, userAccelerometerEventStream.data]);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body:  Center(
        child: data.value.isEmpty
            ? const Text('Waiting for accelerometer data...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Timestamp : ${data.value.last['timestamp']}'),
                  Text('x : ${data.value.last['accelerometerData_X']}'),
                  Text('y: ${data.value.last['accelerometerData_Y']}'),
                  Text('z: ${data.value.last['accelerometerData_Z']}'),
                ],
              ),
      ),
    );
  }

}
