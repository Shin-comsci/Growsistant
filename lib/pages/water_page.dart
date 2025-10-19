import 'package:flutter/material.dart';
import 'package:growsistant/theme/constants.dart';
import '../widgets/bottom_nav_bar.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  double waterLevel = 80; // contoh data awal dari sensor IoT
  double tambahAir = 0;

  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/'); // kembali ke home
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/history'); // route lain
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    "Saatnya siram",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Text(
                    " Bubble",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gambar tanaman dan persen air
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/cahayaNyala.png', height: 250),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        // stroke hijau
                        Text(
                          "${waterLevel.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = secondary,
                          ),
                        ),
                        Text(
                          "${waterLevel.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Persentase Kelembapan",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Tombol penyesuaian air
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, size: 40, color: secondary),
                    onPressed: () {
                      setState(() {
                        if (tambahAir > 0) tambahAir -= 1;
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  Text(
                    "${tambahAir.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 35,
                      color: secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 40, color: secondary),
                    onPressed: () {
                      setState(() {
                        if (tambahAir < 100) tambahAir += 1;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol "Beri Air"
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      waterLevel += tambahAir;
                      if (waterLevel > 100) waterLevel = 100;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Berhasil menambahkan air sebesar ${tambahAir.toStringAsFixed(0)}%!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    setState(() {
                      tambahAir = 0;
                    });
                  },
                  child: const Text(
                    "Beri Air",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ ganti ini agar tidak error
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
