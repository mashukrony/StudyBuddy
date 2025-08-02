import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.green;
  static const Color error = Colors.red;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
}

class FirestorePaths {
  static String user(String uid) => 'users/$uid';
  static String tasks(String uid) => 'tasks';
}