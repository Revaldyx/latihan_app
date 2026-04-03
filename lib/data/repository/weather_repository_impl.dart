import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/datasources/weather_remote_datasources.dart';
import 'package:weather_app/data/datasources/weather_local_datasources.dart';
import 'weather_repository.dart';
import 'package:weather_app/core/error/failure.dart';
import 'package:weather_app/core/error/exceptions.dart';


class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDatasource remote;
  final WeatherLocalDataSource local;

  WeatherRepositoryImpl({required this.remote, required this.local});

  @override
  Future<WeatherModel> getWeather(String city) async {
    try {
      final weather = await remote.fetchWeather(city);
      await local.saveLastCity(city);
      return weather;
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException {
      throw const ServerFailure();
    } on NotFoundException {
      throw const NotFoundFailure();
    } on ParsingException {
      throw const ParsingFailure();
    } catch (e) {
      throw const ServerFailure();
    }
  }

  @override
  Future<String?> loadLastCity() async {
    return await local.getLastCity();
  }

  @override
  Future<WeatherModel> getWeatherByLoc(double lat, double lon) async {
    try {
      return await remote.fetchWeatherByCoord(lat, lon);
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException {
      throw const ServerFailure();
    } on NotFoundException {
      throw const NotFoundFailure();
    } on ParsingException {
      throw const ParsingFailure();
    } catch (e) {
      throw const ServerFailure();
    }
  }
}