import 'package:flutter/material.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/presentation/providers/weather_providers.dart';
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
    Future.microtask(() => _initWeather());
  }

  Future<void> _initWeather() async {
    final provider = context.read<WeatherProvider>();
    await provider.fetchWeatherByLocation();
    if (provider.weather == null) {
      await provider.loadLastCity();
    }
  }

  // Future<void> _loadcity() async {
  //   final provider = context.read<WeatherProvider>();
  //   await provider.loadLastCity();
  // }

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

  String _formatDay(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const  Text(
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
                  if (provider.state == WeatherState.loading) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator()
                      ),
                    );
                  }

                  if (provider.state == WeatherState.error) {
                    return _buildErrorState(provider.errorMessage);
                  }

                  if (provider.state == WeatherState.loaded) {
                    return _buildWeatherCard(provider);
                  }

                  return _buildEmptyState();
                },
              ),
              // ElevatedButton.icon(onPressed: (){
              //   context.read<WeatherProvider>().fetchWeatherByLocation();
              // }, 
              // icon: const Icon(Icons.my_location, color: Colors.white),
              // label: const Text("Gunakan Lokasi Saya", style: TextStyle(color: Colors.blue),))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.location_off,
          size: 80,
          color: Colors.grey[400],
        ),
        
        const SizedBox(height: 16),

        Text(
          message ?? "Terjadi Kesalahan",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            context.read<WeatherProvider>().fetchWeatherByLocation();
          },
          icon: const Icon(Icons.my_location),
          label: const Text("Gunakan Lokasi Saya"),
          )
      ],
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
            toTitleCase(weather.city),
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
          _buildForecastList(weather.forecast),
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
  Widget _buildForecastList(List<DailyForecast> forecast) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final item = forecast[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.9),
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
                Icon(
                  _getWeatherIcon(item.weatherCode)['icon'],
                  size: 30,
                  color: Colors.blueAccent,
          ),
          Text (
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
