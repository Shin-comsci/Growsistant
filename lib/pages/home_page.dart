import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:growsistant/auth.dart';
import 'package:growsistant/theme/constants.dart';
import 'package:growsistant/utilities/firestore_functions.dart';
import 'package:growsistant/utilities/helper.dart';
import 'package:growsistant/utilities/mqtt_connector.dart';
import 'package:growsistant/widgets/loading_screen.dart';
import 'package:growsistant/widgets/update_modal.dart';
import 'package:growsistant/widgets/water_modal.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MqttService mqtt;
  late CloudFirestoreService service;
  late String clientId;
  int selectedIndex = 0;
  bool isLightOn = false;
  bool isLoading = true;
  bool _didRoute = false;

  // Live sensor values (nullable so we can show placeholders until data arrives)
  double? soil;   // treat "Water" as soil moisture reading from device
  double? lux;    // lighting level
  double prevLux = 0;
  double prevSoil = 500;
  double prevHum = 50;
  double prevTemp = 25;
  double? hum;    // humidity %
  double? temp;   // °C
  String? soilStatus;
  String? luxStatus;
  String? humStatus;
  String? tempStatus; 
  num? healthPercentage;
  String? emotionStatus;
  String lightControl = "AUTO";
  String pumpControl = "AUTO";
  bool initialFetch = true;

  final ValueNotifier<double> soilNotifier = ValueNotifier<double>(0);

  void _routeReplace(String name) {
    if (_didRoute || !mounted) return;
    _didRoute = true;
    // Defer until after the current frame to avoid !_debugLocked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(name);
    });
  }
  void checkForUpdate() async {
    final versionData = await service.get("versions", "update");
    if (versionData != null && versionData['version'] != null && versionData['changes'] != null) {
      final latestVersion = versionData['version'] as String;
      final changes = versionData['changes'] as List<dynamic>;
      final url = versionData['url'] as String?;
      print("\n\n\n🚀 Latest version: $latestVersion\n\n\n");
      print("\n\n\n📱 Update URL: $url\n\n\n");
      if (latestVersion != appVersion) {
        if (!mounted) return;
        showUpdateModal(
          context: context,
          versionCode: latestVersion,
          changes: changes.cast<String>(),
          onConfirmAsync: () async {
            if (url != null) {
              launchUrl(Uri.parse(url));
            }
          },
        );
      }
    }
  }

  void setPumpMode() {
    setState(() {
      pumpControl = (pumpControl == "AUTO") ? "MANUAL" : "AUTO";
    });
    String msgPayload = '';
    if (pumpControl == "AUTO") {
      msgPayload = '{"auto_pump":true}';
    } else {
      msgPayload = '{"auto_pump":false}';
    }
    mqtt.publish(
      '${mqtt.clientId}/cmd',
      msgPayload,
    );
  }

  void initializePeripherals() async {
    service = CloudFirestoreService(FirebaseFirestore.instance);
    final userEmail = Auth().currentUser?.email;
    print("\n\n\n📸 User email: $userEmail\n\n\n");
    if (userEmail == null) {
      _routeReplace('/login_page');
      return;
    }
    Map<String, dynamic>? userData;
    
    try {
      userData = await service.get('users', userEmail);
    } catch (e, st) {
      debugPrint('🔥 Firestore get failed: $e\n$st');
    }
    print("\n\n\n📦 User data: $userData\n\n\n");

    final devices = (userData?['devices'] as List?)?.cast<String>() ?? const <String>[];

    if (devices.isNotEmpty) {
      clientId = devices.first;
      if (!mounted) return;
      setState(() => isLoading = false);
      initializeMQTT();
      checkForUpdate();
    } else {
      debugPrint("\n\n\n😭 No devices found\n\n\n");
      _routeReplace('/scan');
    }
  }

  void initializeMQTT() {
    mqtt = MqttService(clientId: clientId);
    mqtt.connect();
    mqtt.client.autoReconnect = true;
    mqtt.client.resubscribeOnAutoReconnect = true;
    mqtt.messages.listen((event) {
      final topic = event.keys.first;
      final payload = event.values.first;

      if (topic.endsWith('/sensors')) {
        try {
          final map = jsonDecode(payload) as Map<String, dynamic>;
          setState(() {
            final soilRaw = (map['soil'] as num?)?.toDouble();
            soil = soilRaw;
            if (soil != null) {
              soil = 100 - mapRangeClamp(value: soil ?? 600, inMin: 400, inMax: 800);
              if (soil! >= 0) {
                prevSoil = soil!;
              }
            }
            soilNotifier.value = soil ?? soilNotifier.value;
            soilStatus = statusFromPercent(soilRaw ?? 0, high: 600, low: 500, okLabel: 'Wet', highLabel: 'Too Dry', lowLabel: 'Too Wet');
            lux  = (map['lux']  as num?)?.toDouble();
            if (lux != null && lux! >= 0) {
              prevLux = lux!;
            }
            luxStatus = !isLightOn ? statusFromPercent(lux ?? 0, high: 500, low: 200, okLabel: 'OK', highLabel: 'Bright', lowLabel: 'Dim') : 'Light On';
            temp = (map['temp'] as num?)?.toDouble();
            if (temp != null) {
              prevTemp = temp!;
            }
            tempStatus = statusFromPercent(temp ?? 0, high: 30, low: 20, okLabel: 'OK', highLabel: 'Hot', lowLabel: 'Cold');
            hum  = (map['hum']  as num?)?.toDouble();
            if (hum != null) {
              prevHum = hum!;
            }
            humStatus = statusFromPercent(hum ?? 0, high: 70, low: 30, okLabel: 'OK', highLabel: 'Humid', lowLabel: 'Dry');
            isLightOn = map['lamp'] as bool? ?? false;
            if (initialFetch) {
              lightControl = (map['auto_lamp'] as bool? ?? true) ? "AUTO" : (isLightOn ? "ON" : "OFF");
              pumpControl = (map['auto_pump'] as bool? ?? true) ? "AUTO" : "MANUAL";
              initialFetch = false;
            }
            healthPercentage = (0.3 * calculateHealthPercentage(
              current: soilRaw ?? prevSoil,
              upperThreshold: 600,
              lowerThreshold: 500,
              min: 200,
              max: 800,
            ) + (isLightOn ? 0.3 * 100 : 0.3 * calculateHealthPercentage(
              current: lux ?? prevLux,
              upperThreshold: 999998,
              lowerThreshold: 200,
              min: 0,
              max: 999999,
            )) + 0.2 * calculateHealthPercentage(
              current: temp ?? prevTemp,
              upperThreshold: 32,
              lowerThreshold: 20,
              min: 0,
              max: 52,
            ) + 0.2 * calculateHealthPercentage(
              current: hum ?? prevHum,
              upperThreshold: 70,
              lowerThreshold: 30,
              min: 0,
              max: 100,
            ));
            if (healthPercentage != null) {
              if (healthPercentage! < 0) {
                healthPercentage = 0;
              } else if (healthPercentage! > 100) {
                healthPercentage = 100;
              }
              if (healthPercentage! >= 90) {
                emotionStatus = "🌸 Blooming";
              } else if (healthPercentage! >= 70) {
                emotionStatus = "🌻 Doing Well";
              } else if (healthPercentage! >= 50) {
                emotionStatus = "🍀 Stable";
              } else if (healthPercentage! >= 30) {
                emotionStatus = "🥀 Struggling";
              } else {
                emotionStatus = "⚠️ Needs Attention";
              }
            } else {
              emotionStatus = null;
            }
            
          });
        } catch (e) {
          // do nothing
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializePeripherals();
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

  void waterPlant(double amountMl) async {
    int pumpDurationMs = (
      amountMl == 10 ? 800 :
      amountMl == 20 ? 1700 :
      amountMl == 30 ? 2500 :
      amountMl == 40 ? 3300 :
      amountMl == 50 ? 4200 :
      amountMl == 60 ? 5000 : 0
    );
    final payload = '{"pump_ms":$pumpDurationMs}';
    await mqtt.publish(
      '${mqtt.clientId}/cmd',
      payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || emotionStatus == null) {
      return Scaffold(
        body: LoadingIndicator()
      );
    }
    // Pretty display values with sensible fallbacks
    final waterText = soil != null ? soil!.toStringAsFixed(0) : '•';
    final lightText = (lux != null && lux! >= 0) ? lux!.toStringAsFixed(2) : '•';
    final humidText = hum  != null ? hum!.toStringAsFixed(0) : '•';
    final tempText  = temp != null ? temp!.toStringAsFixed(1) : '•';

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
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 36),
                    onPressed: () async {
                      await Auth().signOut();
                      Navigator.pushReplacementNamed(context, '/login_page');
                      if (!mounted) return;
                    },
                  ),
                ],
              ),
              Text(
                emotionStatus ?? ' ',
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
                  const SizedBox(width: 10),

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
                        "${healthPercentage?.toStringAsFixed(0) ?? '•'}%",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () async {
                          setState(() => lightControl = (lightControl == "AUTO") ? "ON" : (lightControl == "OFF") ? "AUTO" : "OFF");
                          String msgPayload = '';
                          if (lightControl == "AUTO") {
                            msgPayload = '{"light":$isLightOn,"auto_light":true}';
                          } else if (lightControl == "ON") {
                            msgPayload = '{"light":true,"auto_light":false}';
                          } else {
                            msgPayload = '{"light":false,"auto_light":false}';
                          }
                          await mqtt.publish(
                            '${mqtt.clientId}/cmd',
                            msgPayload,
                          );
                          await Future.delayed(const Duration(milliseconds: 250));
                          await mqtt.publish(
                            '${mqtt.clientId}/cmd',
                            'UPD',
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: lightControl == 'AUTO' ? primary : lightControl == 'ON' ? yellowPoint : Colors.grey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lightControl,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
                      'Soil Moisture (%)',
                      waterText,
                      () async {
                        await showWaterModal(
                          context: context,
                          soilMoisture: soilNotifier,
                          onConfirmAsync: (ml) async {
                            waterPlant(ml);
                          },
                        );
                      },
                      Icons.waves_outlined,
                      rate: soilStatus ?? "",
                    ),
                    _buildInfoCard(
                      context,
                      'Lighting (lux)',
                      lightText,
                      () => Navigator.pushNamed(context, '/light'),
                      Icons.light_mode_outlined,
                      rate: isLightOn ? "Light On" : (luxStatus ?? ""),
                    ),
                    _buildInfoCard(
                      context,
                      'Humidity (%)',
                      humidText,
                      () => Navigator.pushNamed(context, '/humidity'),
                      Icons.water_drop_outlined,
                      rate: humStatus ?? "",
                    ),
                    _buildInfoCard(
                      context,
                      'Temperature (°C)',
                      tempText,
                      () => Navigator.pushNamed(context, '/temperature'),
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
    Function() handleTap,
    IconData icon, {
    String rate = "",
  }) {
    return GestureDetector(
      onTap: handleTap,
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
              if (title.contains("Moisture"))
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onTap: setPumpMode,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 65,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: pumpControl == 'AUTO' ? primary : Colors.grey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          Expanded(
                            child: Text(
                              pumpControl == "AUTO" ? "A" : "M",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
