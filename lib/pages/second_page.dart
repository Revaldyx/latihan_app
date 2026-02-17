import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
    final String text;

    const SecondPage({super.key, required this.text});

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(title: const Text("Halaman Kedua")),
            body: Center(
                child: Text(
                    text,
                    style: const TextStyle(fontSize: 24),
                ),
            ),
        );
    }
}