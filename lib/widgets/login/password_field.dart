import 'package:flutter/material.dart';
import 'package:restaurant_helper/widgets/login/text_field_container.dart';
import 'package:restaurant_helper/constants.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController textEditingController;
  final ValueChanged<String> onChanged;
  final String? errorText;
  const PasswordField({
    Key? key,
    required this.textEditingController,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showPassword = true;
  Icon _iconToShow = const Icon(Icons.visibility_off);

  void setPasswordVisible() {
    setState(() {
      _showPassword = !_showPassword;
      if (_showPassword) {
        _iconToShow = const Icon(Icons.visibility_off);
      } else {
        _iconToShow = const Icon(Icons.visibility);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      error: widget.errorText,
      width: 0.75,
      child: TextField(
        controller: widget.textEditingController,
        keyboardType: TextInputType.text,
        obscureText: _showPassword,
        onChanged: widget.onChanged,
        cursorColor: primaryColor,
        decoration: InputDecoration(
            hintText: "Password",
            errorText: widget.errorText,
            errorStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12.0)),
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
                fontSize: 18),
            suffixIcon: IconButton(
              icon: _iconToShow,
              onPressed: () => {setPasswordVisible()},
              color: primaryColor,
              splashRadius: 1.0,
            ),
            fillColor: Colors.grey.shade200,
            filled: true),
      ),
    );
  }
}
