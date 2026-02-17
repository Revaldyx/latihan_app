class WeatherModel {
  final String city;
  final DateTime date;
  final double temperature;
  final double windspeed;
  final int weatherCode;

  WeatherModel({
    required this.city,
    required this.date,
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'];

    if (current == null) {
      throw Exception('Data cuaca tidak ditemukan');
    }

    return WeatherModel(
      city: json['timezone'] ?? 'Unknown',
      date: DateTime.parse(current['time']),
      temperature: current['temperature'],
      windspeed: current['windspeed'],
      weatherCode: current['weather_code'] ?? 0,
    );
  }
}
