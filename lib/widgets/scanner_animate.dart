import 'package:flutter/material.dart';

class ScannerLine extends StatefulWidget {
  const ScannerLine({Key? key}) : super(key: key);

  @override
  _ScannerLineState createState() => _ScannerLineState();
}

class _ScannerLineState extends State<ScannerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // keeps looping up and down
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Positioned(
          top: 200 + (value * 250),
          child: Container(
            width: 200,
            height: 2,
            color: Colors.green,
          ),
        );
      },
    );
  }
}
