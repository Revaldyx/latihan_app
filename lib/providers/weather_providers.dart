import 'package:flutter/material.dart';
import '../services/weather_services.dart';
import '../models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherServices _services = WeatherServices();

  WeatherModel? weather;
  bool isLoading = false;
  String? error;

  Future<void> fetchWeather(String city) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      weather = await _services.fetchWeather(city);
    } catch (e) {
      error = e is Exception
          ? e.toString().replaceFirst("Exception: ", "")
          : "Terjadi kesalahan";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
