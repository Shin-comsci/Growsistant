import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growsistant/theme/constants.dart';

Future<double?> showWaterModal({
  required BuildContext context,
  required ValueListenable<double> soilMoisture, // live value source
  double initialMl = 10,
  Future<void> Function(double ml)? onConfirmAsync,
}) {
  double tambahAir = initialMl.clamp(10, 60);

  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // grab handle
                Container(
                  width: 40, height: 5, margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                Text(
                  'Time to water Bubble!',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Icon(Icons.water_drop, size: 48, color: secondary),
                const SizedBox(height: 18),

                // Live soil moisture readout
                ValueListenableBuilder<double>(
                  valueListenable: soilMoisture,
                  builder: (_, value, __) => Text(
                    value.toStringAsFixed(0),
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Soil Moisture Level',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle, size: 32, color: secondary),
                    onPressed: () {
                      setModalState(() {
                        if (tambahAir > 10) tambahAir -= 10;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: Text(
                      "${tambahAir.toStringAsFixed(0)} ml",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.add_circle, size: 32, color: secondary),
                    onPressed: () {
                      setModalState(() {
                        if (tambahAir < 60) tambahAir += 10;
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: secondary),
                          foregroundColor: secondary,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (onConfirmAsync != null) {
                            await onConfirmAsync(tambahAir);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop(tambahAir); // return selected ml
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Water now'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}
