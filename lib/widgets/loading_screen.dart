import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growsistant/theme/constants.dart';
import 'dart:math';

class LoadingIndicator extends StatelessWidget {
  final double fontSize;
  final Color? textColor;
  final Color? indicatorColor;
  static const List<String> loadingMessages = [
    "Loading your green space...",
    "Preparing your plant data...",
    "Connecting to your garden...",
    "Fetching the latest growth stats...",
    "Tending to your virtual garden...",
    "Sprouting new ideas for you...",
    "Cultivating a better experience...",
    "Nurturing your plant care...",
    "Growing your garden insights...",
    "Watering your app experience...",
  ];

  LoadingIndicator({
    Key? key,
    String? customText,
    this.fontSize = 20,
    this.textColor,
    this.indicatorColor = primary,
  })  : message = customText ?? loadingMessages[Random().nextInt(loadingMessages.length)],
        super(key: key);

  final String message;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: textColor ?? Colors.black,
              ),
            ),
          ),
          CircularProgressIndicator(
            color: indicatorColor,
          ),
        ],
      ),
    );
  }
}