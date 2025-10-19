import 'dart:math' show max; // optional
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:growsistant/auth.dart';
import 'package:growsistant/theme/constants.dart';
import 'package:growsistant/utilities/firestore_functions.dart';
import 'package:growsistant/widgets/modal.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';


class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isScanned = ValueNotifier<bool>(false);
  final MobileScannerController _scanner = MobileScannerController();
  late final AnimationController _scanCtrl;
  late CloudFirestoreService service;

  static const double _frameSize = 250;
  static const double _lineInset = 12; // padding from frame edges

  @override
  void initState() {
    super.initState();
    final currentEmail = Auth().currentUser?.email;
    if (currentEmail == null) {
      Navigator.pushReplacementNamed(context, '/login_page');
    }
    service = CloudFirestoreService(FirebaseFirestore.instance);
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _scanner.dispose();
    isScanned.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera
          MobileScanner(
            controller: _scanner,
            onDetect: (capture) async {
              if (isScanned.value) return;

              final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
              if (code == null) return;

              isScanned.value = true;

              final canVibrate = await Vibration.hasVibrator();
              if (canVibrate) Vibration.vibrate(duration: 120);

              if (!code.startsWith('GS-') || code.length > 15) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid QR code')),
                );
                isScanned.value = false;
                return;
              }

              // Fetch keys
              final devices = await service.fetchAll('devices'); // returns maps with 'id'
              final deviceKeys = devices
                  .map((m) => m['id'])
                  .whereType<String>()
                  .toSet();

              if (!deviceKeys.contains(code)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device not registered in our database')),
                );
                isScanned.value = false;
                return;
              }

              await _scanner.stop();

              bool confirmed = false;
              try {
                confirmed = await showConfirmAddDeviceSheet(
                  context: context,
                  deviceId: code,
                  onConfirmAsync: () async {
                    await service.update('users', Auth().currentUser!.email!, {
                      'devices': FieldValue.arrayUnion([code]),
                    });
                  },
                ) ?? false;
              } finally {
                if (!mounted) return;
                if (!confirmed) {
                  await _scanner.start();
                  isScanned.value = false;
                }
              }

              if (!mounted) return;

              if (confirmed) {
                _scanner.dispose();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                });
              }
            },
          ),

          Center(
            child: Container(
              width: _frameSize,
              height: _frameSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _scanCtrl,
                    builder: (context, _) {
                      final travel = _frameSize - (_lineInset * 2);
                      final y = _lineInset + travel * _scanCtrl.value;
                      return Positioned(
                        top: y,
                        left: _lineInset,
                        right: _lineInset,
                        child: Container(height: 2, color: primary),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => {
                Auth().signOut(),
                Navigator.pushReplacementNamed(context, '/login_page')
              }
            ),
          ),

          const Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Text(
              "Point your camera at the device's QR code to connect",
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
