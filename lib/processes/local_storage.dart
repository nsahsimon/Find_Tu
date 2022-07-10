import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocalStorage {
  static late SharedPreferences _prefs;

  Future<void> initialize() async{
    _prefs = await SharedPreferences.getInstance();
  }



}