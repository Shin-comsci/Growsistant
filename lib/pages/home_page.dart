import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growsistant/utilities/mqtt_connector.dart';
import 'package:mqtt_client/mqtt_client.dart';
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

  @override
  void initState() {
    super.initState();
    debugPrint('🧭 HomePage initState using MqttService');
    mqtt = MqttService();
    mqtt.connect();
    mqtt.client.updates?.listen((events) {
      final rec = events.first.payload as MqttPublishMessage;
      final topic = events.first.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(rec.payload.message);
      if (topic == 'GS-F87Y/sensors') {
        // setState(...) with decoded sensor values
      }
    });
  }

  void _handleSensorPayload(String payload) {
    try {
      final map = json.decode(payload) as Map<String, dynamic>;
      setState(() {
        soil = _toDouble(map['soil']) ?? soil;
        lux  = _toDouble(map['lux'])  ?? lux;
        temp = _toDouble(map['temp']) ?? temp;
        hum  = _toDouble(map['hum'])  ?? hum;
        // if the device also reports a light state, you can sync it here:
        if (map.containsKey('lightOn')) {
          final v = map['lightOn'];
          if (v is bool) isLightOn = v;
          if (v is num)  isLightOn = v != 0;
          if (v is String) {
            final s = v.toLowerCase();
            if (s == 'on' || s == 'true' || s == '1') isLightOn = true;
            if (s == 'off' || s == 'false' || s == '0') isLightOn = false;
          }
        }
      });
    } catch (_) {
      // ignore bad payloads to keep UI stable
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  void dispose() {
    mqtt.dispose();
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
      backgroundColor: const Color(0xFFE8F5C8),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ===========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bubble sedang",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Image.asset('assets/icons/notification_none.png', width: 40, height: 40),
                ],
              ),
              const Text(
                "happy",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

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

                  // Health + ON/OFF
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Health",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "96%", // keep static or derive from sensors later
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          setState(() => isLightOn = !isLightOn);
                          // publish ON/OFF command (retain so device can catch up)
                          // mqtt.publishMessage(
                          //   "GS-F87Y/lighting",
                          //   isLightOn ? "ON" : "OFF",
                          // );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isLightOn ? const Color(0xFFB7CF6B) : Colors.grey.shade400,
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

              const SizedBox(height: 20),

              // Grid ===========================================
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildInfoCard(
                      context,
                      'Water (soil)',
                      waterText,
                      '/water',
                      Image.asset('assets/icons/waterdrop.png', height: 50),
                    ),
                    _buildInfoCard(
                      context,
                      'Lighting (lux)',
                      lightText,
                      '/lighting',
                      Image.asset('assets/icons/lightbulb.png', height: 50),
                    ),
                    _buildInfoCard(
                      context,
                      'Humidity',
                      humidText,
                      '/humidity',
                      Image.asset('assets/icons/ph-balance.png', height: 50),
                    ),
                    _buildInfoCard(
                      context,
                      'Temperature',
                      tempText,
                      '/temperature',
                      Image.asset('assets/icons/thermometer.png', height: 50),
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
    Image image,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40, width: 30, child: image),
                    const SizedBox(width: 8),
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
                child: Image.asset('assets/icons/right-arrow.png', height: 20),
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
