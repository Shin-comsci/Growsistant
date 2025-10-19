import 'package:flutter/material.dart';
import 'package:growsistant/theme/constants.dart';
import 'scan_barcode.dart';

class on_Boarding extends StatelessWidget{
  const on_Boarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.4),
              child: Image.asset('assets/images/iboard1.png', height: 300, fit:  BoxFit.contain,
              ),
              ),

              Column(
                children: const[
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Make your home green with\n our plants",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),

              // const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7BAE73),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              //Tombol next
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0
                  ),
                child: SizedBox(
                  width: 100,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/scan');
                      Navigator.pushNamed(context, '/login_page');
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),

                    child: const Text('Next', style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          )
      ),
    );
  }


}
