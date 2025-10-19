import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growsistant/theme/constants.dart';

Future<bool?> showConfirmAddDeviceSheet({
  required BuildContext context,
  required String deviceId,
  Future<void> Function()? onConfirmAsync, // optional async handler
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          // respect keyboard (if you add a name input later)
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // grab handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Title
            Text(
              'Add this device?',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'We detected a device with ID:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Device ID pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                deviceId,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: secondary,
                ),
              ),
            ),

            const SizedBox(height: 24),
            Image.asset(  
              'assets/images/CahayaMati.png',
              height: 150,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
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
                        await onConfirmAsync();
                      }
                      if (ctx.mounted) Navigator.of(ctx).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Device'),
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
}
