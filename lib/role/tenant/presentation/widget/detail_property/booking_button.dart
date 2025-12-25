

import 'package:flutter/material.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookingButton extends StatelessWidget {
  const BookingButton({
    super.key,
    required this.price,
    this.onTap,
    this.onChat,
  });

  final String price;
  final VoidCallback? onTap;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final formattedPrice = _formatPrice(price);



    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Price',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                formattedPrice,
                style: const TextStyle(
                  color: appPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),


              if (onChat != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onChat,
                        icon: Icon(LucideIcons.messageSquare,
                            color: appPrimaryColor),
                        label: const Text(
                          'Chat Owner',
                          style: TextStyle(
                            color: appPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: appPrimaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _BookingGradientButton(onTap: onTap)),
                  ],
                )
              else
                _BookingGradientButton(onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw.isNotEmpty ? raw : 'Rp 0';

    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    final reversed = buffer.toString().split('').reversed.join();
    return 'Rp $reversed';
  }
}

class _BookingGradientButton extends StatelessWidget {
  const _BookingGradientButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {

      return Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Booking',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: customLinearGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
