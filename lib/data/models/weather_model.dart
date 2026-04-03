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

  WeatherModel copyWith({
    String? city,
    DateTime? date,
    double? temperature,
    double? windspeed,
    int? weatherCode,
    List<DailyForecast>? forecast,
  }) {
    return WeatherModel(
      city: city ?? this.city,
      date: date ?? this.date,
      temperature: temperature ?? this.temperature,
      windspeed: windspeed ?? this.windspeed,
      weatherCode: weatherCode ?? this.weatherCode,
      forecast: forecast ?? this.forecast,
    );
  }
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

