import 'package:flutter/material.dart';
import '../../data/repository/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../../core/error/failure.dart';
import '../../core/services/loc_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  final WeatherRepository repository;

  WeatherProvider(this.repository);

  WeatherState state = WeatherState.initial;
  WeatherModel? weather;
  String? errorMessage;

  
  Future<bool> fetchWeatherByLocation() async {
    state = WeatherState.loading;
    notifyListeners();

    try {
      final locservice = LocationService();
      final position = await locservice.getCurrentLocation();

      final cityName = await locservice.getCityName(
        position.latitude, position.longitude
      );

      weather = await repository.getWeatherByLoc(
        position.latitude, position.longitude,
      );
      weather = weather!.copyWith(city: cityName);

      state = WeatherState.loaded;
      notifyListeners();
      return true;
    }
    on Failure catch (e) {
      weather = null;
      errorMessage = e.message;
      state = WeatherState.error;
    }
    catch (_) {
      weather = null;
      errorMessage = 'An unexpected error occurred';
      state = WeatherState.error;
    }
    notifyListeners();
    return false;
  }
  
  Future<void> fetchWeather(String city) async {
    state = WeatherState.loading;
    errorMessage = null;
    weather = null;

    try {
      weather = await repository.getWeather(city);
      state = WeatherState.loaded;
    }
    on Failure catch (e) {
      weather = null;
      errorMessage = e.message;
      state = WeatherState.error;
    }
    catch (_) {
      weather = null;
      errorMessage = 'An unexpected error occurred';
      state = WeatherState.error;
    }
    notifyListeners();
  }

  Future<void> loadLastCity() async {
    final lastCity = await repository.loadLastCity();
    if (lastCity != null) {
      await fetchWeather(lastCity);
    }
  }

}
