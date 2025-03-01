import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'sign_speech_screen.dart';
import 'speech_sign_screen.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SignSpeak',
      theme: ThemeData.light(), // Light Theme
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/sign_speech': (context) => const SignSpeechScreen(),
        '/speech_sign': (context) => const SpeechSignScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      initialRoute: '/',
    );
  }
}
