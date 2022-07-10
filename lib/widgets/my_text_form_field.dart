import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/constants.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIconButton;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final TextInputType textInputType;
  final TextAlign textAlign;
  final bool autoFocus;
  final String? Function(dynamic value)? validator;
  final void Function(dynamic)? onChanged;

  MyTextFormField({@required this.controller,
    this.obscureText = false,
    this.textAlign = TextAlign.start,
    this.textInputType = TextInputType.text,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIconButton,
    this.autoFocus = false,
    this.labelText = "",
    this.prefixIcon ,
    this.validator,
    this.hintText = "",
    this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        enabled: enabled,
        validator: validator,
        controller: controller,
        readOnly: readOnly,
        autofocus: autoFocus,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),
        cursorColor: appColor,
        keyboardType: textInputType,
        textAlign: textAlign,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIconButton,
          focusColor: Colors.white,
          labelText: labelText ?? "",
          fillColor: Colors.transparent,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: appColor, width: 2.0),
              borderRadius: BorderRadius.circular(25.0)
          ),
          disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(25.0)
          ) ,
          enabledBorder: OutlineInputBorder(
              borderSide:  BorderSide(color: appColor.withOpacity(0.4), width: 2.0),
              borderRadius: BorderRadius.circular(25.0)
          ),
          labelStyle: TextStyle(
            color: appColor,
          ),
        )
    );
  }
}
