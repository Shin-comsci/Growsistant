import 'package:flutter/material.dart';
import 'package:growsistant/theme/constants.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.history_rounded, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.white : Colors.black.withOpacity(0.6),
        ),
      ),
    );
  }
}
