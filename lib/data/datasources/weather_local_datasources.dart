import 'package:hive_flutter/hive_flutter.dart';

class WeatherLocalDataSource {
  final Box box = Hive.box('myBox');

  Future<void> saveLastCity(String city) async {
    await box.put('lastCity', city);
  }

  Future<String?> getLastCity() async {
    return box.get('lastCity');
  }
}
