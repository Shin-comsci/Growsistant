import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/water_page.dart';
import 'pages/lightning_page.dart';
import 'pages/humidity_page.dart';
import 'pages/temperature_page.dart';
import 'pages/onBoarding.dart';
import 'pages/scan_barcode.dart';


void main(){
  runApp(const SmartGardenApp());
}

class SmartGardenApp extends StatelessWidget{
  const SmartGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Garden',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFFCCE58D),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const on_Boarding(),
        '/scan': (context) => const ScanBarcodePage(),
        '/home': (context) => const HomePage(),
        '/water': (context) => const WaterPage(),
        // '/lightning': (context) => const LightControlPage(),
        // '/humidity': (context) => const humidityPage(),
        // '/temperature': (context) => const temperaturePage(),
      },
    );
  }
}