import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.hinttext,
    required this.textInputType,
    required this.borderColor,
    required this.focusedColor,
    required this.isPass,
    required this.validation,
    required this.onSaved,
  });
  final String hinttext;
  final TextInputType textInputType;
  final Color borderColor;
  final Color focusedColor;
  final bool isPass;
  final String? Function(String?)? validation;
  final void Function(String? value) onSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 10,
      ),
      child: TextFormField(
        validator: validation,
        keyboardType: textInputType,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hinttext,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: focusedColor, width: 2),
          ),
        ),
        onSaved: onSaved,
      ),
    );
  }
}
