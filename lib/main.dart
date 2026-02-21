import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: prefs));
}
