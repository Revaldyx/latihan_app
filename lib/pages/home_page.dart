import 'package:flutter/material.dart';
import 'package:latihan_app/providers/weather_providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
    _loadcity();
  }

  Future<void> _loadcity() async {
    final provider = context.read<WeatherProvider>();
    await provider.loadLastCity();
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
      // Sembunyikan keyboard setelah menekan tombol
      FocusScope.of(context).unfocus();
    }
  }

  // Fungsi untuk mendapatkan icon berdasarkan weather code
  Map<String, dynamic> _getWeatherIcon(int weatherCode) {
    final iconColor = Colors.white;
    final iconSize = 80.0;

    // WMO Weather interpretation codes
    if (weatherCode == 0) {
      return {
        'icon': Icons.wb_sunny,
        'color': Colors.orangeAccent,
        'size': iconSize,
        'description': 'Cerah',
      };
    } else if (weatherCode == 1 || weatherCode == 2) {
      return {
        'icon': Icons.cloud,
        'color': iconColor,
        'size': iconSize,
        'description': 'Sebagian Berawan',
      };
    } else if (weatherCode == 3) {
      return {
        'icon': Icons.cloud,
        'color': iconColor,
        'size': iconSize,
        'description': 'Berawan',
      };
    } else if (weatherCode == 45 || weatherCode == 48) {
      return {
        'icon': Icons.cloud_queue,
        'color': Colors.grey,
        'size': iconSize,
        'description': 'Berkabut',
      };
    } else if (weatherCode == 51 ||
        weatherCode == 53 ||
        weatherCode == 55 ||
        weatherCode == 80 ||
        weatherCode == 81 ||
        weatherCode == 82) {
      return {
        'icon': Icons.cloud_download,
        'color': Colors.lightBlue,
        'size': iconSize,
        'description': 'Hujan',
      };
    } else if (weatherCode == 61 || weatherCode == 63 || weatherCode == 65) {
      return {
        'icon': Icons.cloud_download,
        'color': Colors.lightBlue,
        'size': iconSize,
        'description': 'Hujan',
      };
    } else if (weatherCode == 71 ||
        weatherCode == 73 ||
        weatherCode == 75 ||
        weatherCode == 77 ||
        weatherCode == 85 ||
        weatherCode == 86) {
      return {
        'icon': Icons.cloud_queue,
        'color': Colors.blue,
        'size': iconSize,
        'description': 'Salju',
      };
    } else if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
      return {
        'icon': Icons.flash_on,
        'color': Colors.amber,
        'size': iconSize,
        'description': 'Badai Petir',
      };
    } else {
      return {
        'icon': Icons.help_outline,
        'color': iconColor,
        'size': iconSize,
        'description': 'Tidak Diketahui',
      };
    }
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
                  if (provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return _buildErrorState(provider.error!);
                  }

                  if (provider.weather != null) {
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
    final weatherInfo = _getWeatherIcon(weather.weatherCode);

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
            weather.city,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
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
          Icon(
            weatherInfo['icon'],
            size: weatherInfo['size'],
            color: weatherInfo['color'],
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
            "${weather.temperature.toStringAsFixed(1)}°C",
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

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.cloud_queue,
          size: 100,
          // ignore: deprecated_member_use
          color: Colors.blueAccent.withOpacity(0.2),
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
}
