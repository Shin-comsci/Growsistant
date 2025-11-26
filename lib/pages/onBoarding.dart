import 'package:flutter/material.dart';
import 'package:growsistant/theme/constants.dart';

class on_Boarding extends StatelessWidget{
  const on_Boarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
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
                    "Hello there!",
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's make your home green with\n Growsistant",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
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
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.5),
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
