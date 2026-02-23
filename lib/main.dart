import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/data/datasources/weather_local_datasources.dart';
import 'package:weather_app/data/datasources/weather_remote_datasources.dart';
import 'data/repository/weather_repository.dart';
import 'data/repository/weather_repository_impl.dart';
import 'providers/weather_providers.dart';
import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('myBox');

  runApp(
    MultiProvider(
      providers: [
        Provider<WeatherRepository>(
          create: (_) => WeatherRepositoryImpl(
            remote: WeatherRemoteDatasource(),
            local: WeatherLocalDataSource(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              WeatherProvider(context.read<WeatherRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
