import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'sign_speech_screen.dart';
import 'speech_sign_screen.dart';
import 'settings.dart';
import 'theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SignSpeak',
          theme: themeProvider.themeData,
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomePage(),
            '/sign_speech': (context) => const SignSpeechScreen(),
            '/speech_sign': (context) => const SpeechSignScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          initialRoute: '/',
        );
      },
    );
  }
}
