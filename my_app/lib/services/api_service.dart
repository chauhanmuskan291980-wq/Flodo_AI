import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS
  static const String baseUrl = "http://localhost:8000/api";

  // Helper to convert Color to Hex String
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  static Future<void> postTask({
    required String title,
    required Color iconColor,
    required Color bgColor,
    required List<Map<String, dynamic>> desc,
    int? iconCode,
  }) async {
    final url = Uri.parse('$baseUrl/tasks');

    final body = jsonEncode({
      "title": title,
      "iconData": iconCode ?? Icons.person.codePoint,
      "bgColor": colorToHex(bgColor),
      "iconColor": colorToHex(iconColor),
      "btnColor": colorToHex(iconColor), // Using icon color for btn
      "left": desc.length,
      "done": 0,
      "desc": desc,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" Task Saved to Postgres!");
      } else {
        print("Server Error: ${response.body}");
      }
    } catch (e) {
      print("Connection Error: $e");
    }
  }
}