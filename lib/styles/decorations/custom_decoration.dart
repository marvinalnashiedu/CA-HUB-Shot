import 'package:flutter/material.dart';
import 'package:cahubshot/styles/text_style/custom_text_style.dart';

InputDecoration customInputDecoration = InputDecoration(
  hintStyle: CustomTextStyle.basicTextStyle.copyWith(
    fontSize: 14.0,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
  border: OutlineInputBorder(
    borderSide: BorderSide(),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(),
  ),
);
