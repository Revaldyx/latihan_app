import 'package:weather_app/models/weather_model.dart';

abstract class WeatherRepository {
  Future<WeatherModel> getWeather(String city);
  Future<String?> loadLastCity();
}
