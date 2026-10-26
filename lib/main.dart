import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
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
