import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growsistant/theme/constants.dart';
import 'package:growsistant/utilities/helper.dart';
import 'package:growsistant/utilities/mqtt_connector.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MqttService mqtt;

  int selectedIndex = 0;
  bool isLightOn = false;

  // Live sensor values (nullable so we can show placeholders until data arrives)
  double? soil;   // treat "Water" as soil moisture reading from device
  double? lux;    // lighting level
  double? hum;    // humidity %
  double? temp;   // °C
  String? soilStatus;
  String? luxStatus;
  String? humStatus;
  String? tempStatus; 
  num? healthPercentage;

  @override
  void initState() {
    super.initState();
    final clientId = 'GS-F87Y';
    mqtt = MqttService(clientId: clientId);
    mqtt.connect();
    mqtt.messages.listen((event) {
      final topic = event.keys.first;
      final payload = event.values.first;

      // Only handle the topic you care about
      if (topic.endsWith('/sensors')) {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        setState(() {
          soil = (map['soil'] as num?)?.toDouble();
          soilStatus = statusFromPercent(soil ?? 0, high: 600, low: 500, okLabel: 'Wet', highLabel: 'Too Dry', lowLabel: 'Too Wet');
          lux  = (map['lux']  as num?)?.toDouble();
          luxStatus = statusFromPercent(lux ?? 0, high: 500, low: 200, okLabel: 'OK', highLabel: 'Bright', lowLabel: 'Dim');
          temp = (map['temp'] as num?)?.toDouble();
          tempStatus = statusFromPercent(temp ?? 0, high: 30, low: 20, okLabel: 'OK', highLabel: 'Hot', lowLabel: 'Cold');
          hum  = (map['hum']  as num?)?.toDouble();
          humStatus = statusFromPercent(hum ?? 0, high: 70, low: 30, okLabel: 'OK', highLabel: 'Humid', lowLabel: 'Dry');
          healthPercentage = (calculateHealthPercentage(
            current: soil ?? 0,
            upperThreshold: 600,
            lowerThreshold: 500,
            min: 0,
            max: 1024,
          ) + calculateHealthPercentage(
            current: lux ?? 0,
            upperThreshold: 500,
            lowerThreshold: 200,
            min: 0,
            max: 1024,
          ) + calculateHealthPercentage(
            current: temp ?? 0,
            upperThreshold: 30,
            lowerThreshold: 20,
            min: 0,
            max: 50,
          ) + calculateHealthPercentage(
            current: hum ?? 0,
            upperThreshold: 70,
            lowerThreshold: 30,
            min: 0,
            max: 100,
          )) / 4;
        });
      }
    });

  }

  @override
  void dispose() {
    // mqtt.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == selectedIndex) return;
    setState(() => selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pretty display values with sensible fallbacks
    final waterText = soil != null ? soil!.toStringAsFixed(0) : '—';
    final lightText = lux  != null ? lux!.toStringAsFixed(2) : '—';
    final humidText = hum  != null ? hum!.toStringAsFixed(0) + '%' : '—';
    final tempText  = temp != null ? temp!.toStringAsFixed(1) + '°C' : '—';

    return Scaffold(
      backgroundColor: bg,

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ===========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bubble is currently",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Image.asset('assets/icons/notification_none.png', width: 40, height: 40),
                ],
              ),
              const Text(
                "Happy",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              // Image + Health + Light toggle ==================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 250,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Image.asset(
                        isLightOn
                            ? 'assets/images/cahayaNyala.png'
                            : 'assets/images/CahayaMati.png',
                        key: ValueKey<bool>(isLightOn),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Condition",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${healthPercentage?.toStringAsFixed(0) ?? '—'}%",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          setState(() => isLightOn = !isLightOn);
                          // mqtt.publish(
                          //   isLightOn ? "ON" : "OFF",
                          // );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isLightOn ? secondary : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: isLightOn ? Colors.white : Colors.black54,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isLightOn ? "ON" : "OFF",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Grid ===========================================
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  // padding: const EdgeInsets.all(12),
                  children: [
                    _buildInfoCard(
                      context,
                      'Soil Moisture',
                      waterText,
                      '/water',
                      Icons.waves_outlined,
                      rate: soilStatus ?? "",
                    ),
                    _buildInfoCard(
                      context,
                      'Lighting (lux)',
                      lightText,
                      '/lighting',
                      Icons.light_mode_outlined,
                      rate: luxStatus ?? "",
                    ),
                    _buildInfoCard(
                      context,
                      'Humidity',
                      humidText,
                      '/humidity',
                      Icons.water_drop_outlined,
                      rate: humStatus ?? "",
                    ),
                    _buildInfoCard(
                      context,
                      'Temperature',
                      tempText,
                      '/temperature',
                      Icons.thermostat_outlined,
                      rate: tempStatus ?? "",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    String route,
    IconData icon, {
    String rate = "",
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40, width: 30, child: Icon(icon, size: 40, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Text(rate, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
