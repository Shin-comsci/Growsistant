// import 'package:flutter/material.dart';
//
// class LightControlPage extends StatefulWidget {
//   const LightControlPage({super.key});
//
//   @override
//   State<LightControlPage> createState() => _LightControlPageState();
// }
//
// class _LightControlPageState extends State<LightControlPage>
//     with SingleTickerProviderStateMixin {
//   bool isSidebarOpen = false;
//   bool isLightOn = true;
//   double lightIntensity = 0.5; // 0 = dark, 1 = full light
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//   }
//
//   void toggleSidebar() {
//     setState(() {
//       isSidebarOpen = !isSidebarOpen;
//       isSidebarOpen ? _controller.forward() : _controller.reverse();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8F5C8),
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFE8F5C8), Color(0xFFD8F0A3)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//
//           // Sidebar panel
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 400),
//             left: isSidebarOpen ? 0 : -220,
//             top: 0,
//             bottom: 0,
//             child: Container(
//               width: 220,
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Color(0xFFDDE9B3),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(24),
//                   bottomRight: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Intensitas Cahaya",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   RotatedBox(
//                     quarterTurns: -1,
//                     child: Slider(
//                       value: lightIntensity,
//                       onChanged: (value) {
//                         if (isLightOn) {
//                           setState(() => lightIntensity = value);
//                         }
//                       },
//                       activeColor: const Color(0xFFB7CF6B),
//                       inactiveColor: Colors.grey.shade300,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     "${(lightIntensity * 100).toInt()}%",
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Main content
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 400),
//             left: isSidebarOpen ? 150 : 0,
//             right: isSidebarOpen ? -150 : 0,
//             top: 0,
//             bottom: 0,
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: const [
//                             Icon(Icons.arrow_back_ios, size: 20),
//                             SizedBox(width: 6),
//                             Text.rich(
//                               TextSpan(
//                                 text: "Saatnya siram ",
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                                 children: [
//                                   TextSpan(
//                                     text: "Bubble",
//                                     style: TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         // Sidebar button
//                         IconButton(
//                           icon: Icon(
//                             isSidebarOpen ? Icons.close : Icons.menu_rounded,
//                             size: 28,
//                             color: Colors.black87,
//                           ),
//                           onPressed: toggleSidebar,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//
//                   // IoT Image with Light Effect
//                   Expanded(
//                     child: Center(
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Image.asset(
//                             'assets/images/IoT.png',
//                             height: 260,
//                           ),
//                           if (isLightOn)
//                             AnimatedOpacity(
//                               opacity: lightIntensity,
//                               duration: const Duration(milliseconds: 300),
//                               child: Container(
//                                 height: 250,
//                                 width: 250,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   gradient: RadialGradient(
//                                     colors: [
//                                       Colors.yellowAccent.withOpacity(0.4),
//                                       Colors.transparent,
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   // On/Off Button
//                   GestureDetector(
//                     onTap: () => setState(() => isLightOn = !isLightOn),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: isLightOn ? const Color(0xFFB7CF6B) : Colors.grey.shade400,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             isLightOn ? "ON" : "OFF",
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Icon(
//                             Icons.power_settings_new_rounded,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
