import 'package:flutter/material.dart';

class TaskTitle extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const TaskTitle({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Done':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterColor = _getFilterColor(selectedFilter);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //  Title Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your daily work',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // 🔥 Filter Chip Style (Modern)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: filterColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: filterColor.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: filterColor,
                ),
                style: TextStyle(
                  color: filterColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),

                items: ['All', 'Pending', 'In Progress', 'Done']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),

                onChanged: (value) {
                  if (value != null) {
                    onFilterChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}