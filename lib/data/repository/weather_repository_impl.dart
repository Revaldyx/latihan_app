import 'package:latihan_app/models/weather_model.dart';
import 'package:latihan_app/data/datasources/weather_remote_datasources.dart';
import 'package:latihan_app/data/datasources/weather_local_datasources.dart';
import 'weather_repository.dart';

class WeatherRepositoryImpl extends WeatherRepository {
  final WeatherRemoteDatasource remote;
  final WeatherLocalDataSource local;

  WeatherRepositoryImpl({required this.remote, required this.local});

  @override
  Future<WeatherModel> getWeather(String city) async {
    final weather = await remote.fetchWeather(city);
    await local.saveLastCity(city);
    return weather;
  }

  @override
  Future<String?> loadLastCity() async {
    return await local.getLastCity();
  }
}
