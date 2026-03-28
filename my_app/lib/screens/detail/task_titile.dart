import 'package:flutter/material.dart';

class TaskTitle extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const TaskTitle({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
          
          // 🔹 Status Filter Dropdown 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 18, color: Colors.black),
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                // 🔹 Match the "Must-Have" Statuses from PDF 
                items: ['All', 'Pending', 'In Progress', 'Done']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onFilterChanged(newValue);
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}