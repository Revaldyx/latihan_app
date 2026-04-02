import 'dart:convert';
import 'dart:io';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherRemoteDatasource {
  Future<Map<String, dynamic>> _getCoordinates(String city) async {
    final geoUrl = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1",
    );

   try {
    final response = await http.get(geoUrl);

    if (response.statusCode == 404) {
      throw NotFoundException();
    }
    if (response.statusCode >= 500) {
      throw ServerException();
    }

    final data = jsonDecode(response.body);

    if (data['results'] == null || data['results'].isEmpty) {
      throw NotFoundException();
    }

    final result = data['results'][0];

    return {
      'latitude': result['latitude'],
      'longitude': result['longitude'],
    };
   } on SocketException {
    throw NetworkException();
   }
  }

  Future<WeatherModel> fetchWeather(String city) async {
    final coords = await _getCoordinates(city);

    final weatherUrl = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=${coords['latitude']}"
      "&longitude=${coords['longitude']}"
      "&current_weather=true"
      "&daily=temperature_2m_max,temperature_2m_min,weathercode"
      "&timezone=auto",
    );

  
    try {
      final weatherResponse = await http.get(weatherUrl);
      if (weatherResponse.statusCode == 404) {
          throw NotFoundException();
      }
      if (weatherResponse.statusCode >= 500) {
        throw ServerException();
      }
      final weatherData = jsonDecode(weatherResponse.body);
      
      if (weatherData['current_weather'] == null) {
        throw ParsingException();
      }

      final current = weatherData['current_weather'];

      final daily = weatherData['daily'];

      if (daily['time'] == null || daily['temperature_2m_max'] == null || daily['temperature_2m_min'] == null || daily['weathercode'] == null) {
        throw ParsingException();
      }

      List<DailyForecast> forecast = [];
      for (int i = 0; i < daily['time'].length; i++) {
        forecast.add(DailyForecast(
          date: DateTime.parse(daily['time'][i]),
          maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
          minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
          weatherCode: (daily['weathercode'][i] as num).toInt(),
        ));
      }

      
    return WeatherModel(
      city: city,
      date: DateTime.parse(current['time']),
      temperature: (current['temperature'] as num).toDouble(),
      windspeed: (current['windspeed'] as num).toDouble(),
      weatherCode: current['weathercode'],
      forecast: forecast,
    );
    } on SocketException {
      throw NetworkException();
    }
  }

  
}
