import 'package:flutter/material.dart';

class TaskTitle extends StatelessWidget {
  const TaskTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🔹 Increased padding for a more professional look
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tasks',
            style: TextStyle(
              fontSize: 24, // Slightly larger
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // Dark slate instead of pure black
              letterSpacing: 0.5,
            ),
          ),
          
          // 🔹 Refined Timeline Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08), // Softer background
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // 👈 FIX: Prevents Row from expanding too much
              children: [
                Text(
                  "Timeline",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4), // Spacing between text and arrow
                const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}