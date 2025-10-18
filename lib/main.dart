import 'package:flutter/material.dart';
import 'package:growsistant/widget_tree.dart';
import 'pages/home_page.dart';
import 'pages/water_page.dart';
import 'pages/scan_barcode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartGardenApp());

}

class SmartGardenApp extends StatelessWidget{
  const SmartGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growsistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: const Color(0xFFCBD5C0),
      ),
      home: WidgetTree(),
      routes: {
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