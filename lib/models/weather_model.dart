class WeatherModel {
  final String city;
  final DateTime date;
  final double temperature;
  final double windspeed;
  final int weatherCode;
  final List<DailyForecast> forecast;

  WeatherModel({
    required this.city,
    required this.date,
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
    required this.forecast,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}
