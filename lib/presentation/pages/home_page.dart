import 'package:flutter/material.dart';
import 'package:weather_app/core/error/failure.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/presentation/providers/weather_providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initWeather());
  }

  Future<void> _initWeather() async {
    final provider = context.read<WeatherProvider>();
    await provider.fetchWeatherByLocation();
    if (provider.weather == null) {
      await provider.loadLastCity();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchWeather() {
    if (_formKey.currentState!.validate()) {
      final city = _cityController.text.trim();
      context.read<WeatherProvider>().fetchWeather(city);
      FocusScope.of(context).unfocus();
    }
  }

  Map<String, dynamic> _getWeatherAnimation(int weatherCode) {
    // WMO Weather interpretation codes
    if (weatherCode == 0) {
      return {
        'icon': 'assets/animations/sunny.json',
        'description': 'Cerah',
      };
    } else if (weatherCode == 1) {
      return {
        'icon': 'assets/animations/partly-cloudy.json',
        'description': 'Sebagian Berawan',
      };
    } else if (weatherCode == 2) {
      return {
        'icon': 'assets/animations/partly-cloudy.json',
        'description': 'Sebagian Berawan',
      };
    } else if (weatherCode == 3) {
      return {
        'icon': 'assets/animations/cloudy.json',
        'description': 'Berawan',
      };
    } else if (weatherCode == 45 || weatherCode == 48) {
      return {
        'icon': 'assets/animations/fog.json',
        'description': 'Berkabut',
      };
    } else if ((weatherCode >= 51 && weatherCode <= 57) || 
               (weatherCode >= 61 && weatherCode <= 67) ||
               (weatherCode >= 80 && weatherCode <= 82)) {
      return {
        'icon': 'assets/animations/rainy.json',
        'description': 'Hujan',
      };
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      return {
        'icon': 'assets/animations/snow.json',
        'description': 'Salju',
      };
    } else if (weatherCode == 85 || weatherCode == 86) {
      return {
        'icon': 'assets/animations/snow.json',
        'description': 'Hujan Salju Lebat',
      };
    } else if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
      return {
        'icon': 'assets/animations/storm.json',
        'description': 'Badai Petir',
      };
    } else {
      return {
        'icon': 'assets/animations/cloudy.json',
        'description': 'Tidak Diketahui',
      };
    }
  }

  String _formatDay(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initWeather,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchSection(),
              const SizedBox(height: 32),
              Consumer<WeatherProvider>(
                builder: (context, provider, child) {
                  if (provider.state == WeatherState.loading) {
                    return _buildLoadingSkeleton();
                  }

                  if (provider.state == WeatherState.error) {
                    return _buildErrorState(provider.failure);
                  }

                  if (provider.state == WeatherState.loaded) {
                    return _buildWeatherCard(provider);
                  }

                  return _buildEmptyState();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Failure? failure) {
    IconData icon;
    String title;
    String subtitle;

    if (failure is NetworkFailure) {
      icon = Icons.wifi_off;
      title = "Tidak Ada Koneksi Internet";
      subtitle = "Periksa koneksi Anda dan coba lagi.";
    } else if (failure is NotFoundFailure) {
      icon = Icons.wrong_location;
      title = "Kota Tidak Ditemukan";
      subtitle = "Coba gunakan nama kota lain.";
    } else if (failure is ServerFailure) {
      icon = Icons.cloud_off;
      title = "Server Bermasalah";
      subtitle = "Coba lagi nanti.";
    } else if (failure is LocationFailure) {
      icon = Icons.location_off;
      title = "Gagal Mendapatkan Lokasi";
      subtitle = "Pastikan izin lokasi diberikan dan coba lagi.";
    } else {
      icon = Icons.error_outline;
      title = "Terjadi Kesalahan";
      subtitle = failure?.message ?? "Coba lagi nanti.";
    }

    return Column(
      children: [
        Icon(icon, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        _buildActionButton(failure),
      ],
    );
  }

  Widget _buildActionButton(Failure? failure) {
    if (failure is LocationFailure) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              context.read<WeatherProvider>().fetchWeatherByLocation();
            },
            icon: const Icon(Icons.my_location),
            label: const Text("Coba Lagi"),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.location);
            },
            icon: const Icon(Icons.settings),
            label: const Text("Pengaturan Lokasi"),
          ),
        ],
      );
    }

    if (failure is NetworkFailure) {
      return ElevatedButton.icon(
        onPressed: _initWeather,
        icon: const Icon(Icons.refresh),
        label: const Text("Coba Lagi"),
      );
    }
    return ElevatedButton.icon(
      onPressed: _searchWeather,
      icon: const Icon(Icons.refresh),
      label: const Text("Coba Lagi"),
    );
  }

  Widget _buildSearchSection() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: "Masukkan Nama Kota",
              hintText: "Contoh: Jakarta",
              prefixIcon: const Icon(
                Icons.location_city,
                color: Colors.blueAccent,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  // ignore: deprecated_member_use
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Nama kota tidak boleh kosong";
              }
              return null;
            },
            onFieldSubmitted: (_) => _searchWeather(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _searchWeather,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8),
                Text(
                  "Cek Cuaca",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(WeatherProvider provider) {
    final weather = provider.weather!;
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(weather.date);
    final formattedTime = DateFormat('HH:mm').format(weather.date);
    final weatherInfo = _getWeatherAnimation(weather.weatherCode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            toTitleCase(weather.city),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Lottie.asset(
            weatherInfo['icon'],
            height: 120,
          ),
          const SizedBox(height: 8),
          Text(
            weatherInfo['description'],
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${weather.temperature.toStringAsFixed(0)}°C",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 24),
          // ignore: deprecated_member_use
          Divider(color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                Icons.air,
                "Windspeed",
                "${weather.windspeed} km/h",
              ),
              _buildWeatherDetail(Icons.access_time, "Updated", formattedTime),
            ],
          ),
          const SizedBox(height: 16),
          _buildForecastList(weather.forecast, weather.date),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          // ignore: deprecated_member_use
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Lottie.asset(
          'assets/animations/cloudy.json',
          height: 100,
        ),
        const SizedBox(height: 16),
        Text(
          "Cari kota untuk melihat prakiraan cuaca",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildForecastList(List<DailyForecast> forecast, DateTime currentDate) {
    final upcomingForecast = forecast.where((item) {
      return !DateUtils.isSameDay(item.date, currentDate);
    }).toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: upcomingForecast.length,
        itemBuilder: (context, index) {
          final item = upcomingForecast[index];
          final anim = _getWeatherAnimation(item.weatherCode);
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color.fromARGB(255, 205, 160, 235).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDay(item.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Lottie.asset(
                  anim['icon'],
                  height: 50,
                  repeat: true,
                  animate: true,
                  frameRate: FrameRate(30),
                ),
                Text(
                  "${item.maxTemp.toStringAsFixed(0)}° / ${item.minTemp.toStringAsFixed(0)}°",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
