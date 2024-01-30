import 'package:flutter/material.dart';
import 'package:vui/screens/VoiceScreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VUI',
      home: VoiceScreen()
    );
  }
}
