import 'package:flutter/material.dart';
import 'package:weather_app/data/repository/weather_repository.dart';
import '../models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherRepository repository;

  WeatherProvider(this.repository);

  WeatherModel? weather;
  bool isLoading = false;
  String? error;

  Future<void> fetchWeather(String city) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      weather = await repository.getWeather(city);
    } catch (e) {
      error = e is Exception
          ? e.toString().replaceFirst("Exception: ", "")
          : "Terjadi kesalahan";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLastCity() async {
    final lastCity = await repository.loadLastCity();
    if (lastCity != null) {
      await fetchWeather(lastCity);
    }
  }
}
