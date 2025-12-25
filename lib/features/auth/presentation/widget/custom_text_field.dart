

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/colors/custom_color.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: appPrimaryColor),
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              errorText!,
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
