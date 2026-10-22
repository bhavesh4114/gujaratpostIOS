import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GujaratPostApp());
}

class GujaratPostApp extends StatelessWidget {
  const GujaratPostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gujarat Post',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSansGujarati',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB3121B),
          primary: const Color(0xFFB3121B),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
