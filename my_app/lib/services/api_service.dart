import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
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

  static Future<List<dynamic>> getTasks() async {
    final url = Uri.parse('$baseUrl/tasks');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the string from Postgres into a List
        return jsonDecode(response.body);
      } else {
        print("Server Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Connection Error: $e");
      return [];
    }
  }

  static Future<bool> deletetask(int taskId) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("Task deleted successfully");
        return true;
      }
      return false;
    } catch (e) {
      print("Delete Error: $e");
      return false;
    }
  }

  static Future<void> updatetask(
    int taskId,
    Map<String, dynamic> updatedData,
  ) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId');
    try {
      final response = await http.put(
        url,
        headers: {"Content-type": "application/json"},
        body: jsonEncode(updatedData),
      );
      if (response.statusCode == 200) {
        print("Task updated in postgres");
      }
    } catch (error) {
      print("Update Error: $error");
    }
  }

  // UPDATE only the desc list (used for editing timeline items)
  static Future<void> updateTaskDesc(int taskid, List<dynamic> newDesc) async {
    final url = Uri.parse('$baseUrl/tasks/$taskid');
    final body = jsonEncode({"desc": newDesc});

    try {
      await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
    } catch (error) {
      print("Desc update Error : $error");
    }
  }

  static Color hexToColor(String? hexString) {
  if (hexString == null || hexString.isEmpty) return Colors.blue;

  String cleanedHex = hexString.replaceFirst('#', '').trim();

  // If it's a 6-char hex (RRGGBB), add 'FF' for full opacity
  if (cleanedHex.length == 6) {
    cleanedHex = 'FF$cleanedHex';
  }

  // Handle 8-char hex (AARRGGBB)
  try {
    return Color(int.parse(cleanedHex, radix: 16));
  } catch (e) {
    return Colors.blue; 
  }
}
}
