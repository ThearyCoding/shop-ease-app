import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool obscureText;
  final bool isPasswordField;
  final VoidCallback? togglePasswordVisibility;
  final bool isPasswordVisible;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    required this.validator,
    this.obscureText = false,
    this.focusNode,
    this.isPasswordField = false,
    this.togglePasswordVisibility,
    this.isPasswordVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      focusNode: focusNode,
      controller: controller,
      obscureText: isPasswordField ? !isPasswordVisible : obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: TextStyle(color: Colors.grey[600]),
        errorStyle: TextStyle(color: Colors.red),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
      ),
      validator: validator,
    );
  }
}
