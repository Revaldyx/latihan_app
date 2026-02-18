import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latihan_app/models/weather_model.dart';

class WeatherRemoteDatasource {
  Future<Map<String, dynamic>> _getCoordinates(String city) async {
    final geoUrl = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1",
    );

    final response = await http.get(geoUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] == null || data['results'].isEmpty) {
        throw Exception("Kota tidak ditemukan");
      }

      final result = data['results'][0];
      return {'latitude': result['latitude'], 'longitude': result['longitude']};
    } else {
      throw Exception("Gagal mengambil koordinat");
    }
  }

  Future<WeatherModel> fetchWeather(String city) async {
    final coords = await _getCoordinates(city);

    final weatherUrl = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=${coords['latitude']}"
      "&longitude=${coords['longitude']}"
      "&current_weather=true",
    );

    final weatherResponse = await http.get(weatherUrl);

    if (weatherResponse.statusCode != 200) {
      throw Exception("Gagal mengambil data cuaca");
    }

    final weatherData = jsonDecode(weatherResponse.body);
    final current = weatherData['current_weather'];

    return WeatherModel(
      city: weatherData['timezone'],
      date: DateTime.parse(current['time']),
      temperature: (current['temperature'] as num).toDouble(),
      windspeed: (current['windspeed'] as num).toDouble(),
      weatherCode: current['weathercode'],
      forecast: [],
    );
  }
}
