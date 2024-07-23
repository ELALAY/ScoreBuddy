import 'package:flutter/material.dart';


// ignore: camel_case_types, must_be_immutable
class myTextField extends StatelessWidget {

  TextEditingController controller;
  String hintText;
  bool obscureText;

  myTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          label: Text(hintText),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          )
        ),
      ),
    );
  }
}