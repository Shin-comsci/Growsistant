import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  ValueNotifier<bool> isScanned = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Kamera untuk scanning barcode
          MobileScanner(
            onDetect: (barcodeCapture) {
              if (!isScanned.value) {
                isScanned.value = true;

                // Ambil data hasil scan (apa pun)
                final List<Barcode> barcodes = barcodeCapture.barcodes;
                final String? code = barcodes.isNotEmpty ? barcodes.first.rawValue : null;
                debugPrint("Barcode detected: $code");

                // Langsung navigasi ke HomePage
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),

          // Area scanner overlay (seperti iPhone style)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              ),
            ),
          ),

          // Garis animasi scanner bergerak
          _buildAnimatedScannerLine(),

          // Tombol kembali
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Keterangan teks
          Positioned(
            bottom: 100,
            child: Text(
              "Arahkan kamera ke barcode apa saja",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    isScanned.dispose();
    super.dispose();
  }

  // Fungsi animasi garis scanner
  Widget _buildAnimatedScannerLine() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Positioned(
          top: 200 + (value * 250),
          child: Container(
            width: 200,
            height: 2,
            color: Colors.greenAccent,
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {}); // ulang animasi terus-menerus
      },
    );
  }
}
