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
  Widget build(BuildContext context) {
    // final itemProvider = Provider.of<ItemProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("APLIKASI TEST"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: "Nama Kota",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Text tidak boleh kosong";
                  }
                  if (value.length < 3) {
                    return "Minimal 3 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       setState(() {
              //         // itemProvider.addItem(_controller.text);
              //         _controller.clear();
              //       });
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text("Data berhasil ditambahkan"),
              //         ),
              //       );
              //     }
              //   },
              //   child: const Text("Lanjut"),
              // ),
              ElevatedButton(
                onPressed: () {
                  final city = _cityController.text.trim();
                  if (city.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nama kota tidak boleh kosong"),
                      ),
                    );
                    return;
                  }
                  context.read<WeatherProvider>().fetchWeather(city);
                },
                child: const Text("Ambil Data Cuaca"),
              ),

              Consumer<WeatherProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) {
                    return Text(provider.error!);
                  }
                  if (provider.weather != null) {
                    final formattedDate = DateFormat(
                      'dd MMMM yyyy, HH:mm',
                    ).format(provider.weather!.date);
                    return Card(
                      margin: const EdgeInsets.only(top: 20),
                      child: ListTile(
                        title: Text(provider.weather!.city),
                        subtitle: Text(formattedDate),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${provider.weather!.temperature}°C"),
                            Text(
                              "Windspeed: ${provider.weather!.windspeed} km/h",
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Text("Belum ada data cuaca");
                },
              ),

              // const SizedBox(height: 20),
              // Expanded(
              //   // child: itemProvider.items.isEmpty
              //   //     ? const Center(
              //   //         child: Text(
              //   //           "Tidak ada data",
              //   //           style: TextStyle(fontSize: 16),
              //   //         ),
              //   //       )
              //   child: ListView.builder(
              //     // itemCount: itemProvider.items.length,
              //     itemBuilder: (context, index) {
              //       return Card(
              //         child: ListTile(
              //           // title: Text(itemProvider.items[index]),
              //           trailing: IconButton(
              //             icon: const Icon(Icons.delete),
              //             onPressed: () {
              //               setState(() {
              //                 // itemProvider.removeItem(
              //                 //   itemProvider.items[index],
              //                 // );
              //               });
              //               // if (itemProvider.items.isEmpty) {
              //               //   ScaffoldMessenger.of(context).showSnackBar(
              //               //     const SnackBar(
              //               //       content: Text("Data berhasil dihapus"),
              //               //     ),
              //               //   );
              //               // }
              //             },
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
