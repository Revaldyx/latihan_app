import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherServices {
  Future<Map<String, double>> getCoordinates(String city) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        final result = data['results'][0];

        return {
          'latitude': result['latitude'],
          'longitude': result['longitude'],
        };
      } else {
        throw Exception("Kota tidak ditemukan");
      }
    } else {
      throw Exception("Gagal ambil koordinat");
    }
  }

  Future<WeatherModel> fetchWeather(String city) async {
    final coords = await getCoordinates(city);

    final latitude = coords['latitude'];
    final longitude = coords['longitude'];

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception("Gagal ambil data cuaca");
    }
  }
}
