import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TaskTimeLine extends StatelessWidget {
  final Map<String, dynamic> detail;
  final int index; // Add index to check for odd/even
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskTimeLine(
    this.detail,
    this.index, { // Pass index instead of Color
    this.onDelete,
    this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Better row background (Light Grey instead of Black)
    final Color rowBgColor = index % 2 == 0
        ? const Color(0xFFF8FAFC) // Very light blue-grey for even rows
        : Colors.white; // Pure white for odd rows

    // 2. Logic for Empty Slot Color (Replacing Dark Black)
    final bool isEmpty = (detail['title'] ?? '').isEmpty;

    final Color timelineColor = isEmpty
        ? Colors
              .blueGrey
              .shade200 // Muted color for empty slots
        : const Color(0xFF1A2196); // Deep professional blue for active tasks

    return Container(
      color: rowBgColor, // This makes the rows alternate cleanly
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(timelineColor),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Text
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    detail['time'] ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // The Task Card
                _buildCard(
                  isEmpty,
                  detail['title'] ?? '',
                  detail['slot'] ?? '',
                  detail['status'] ?? 'Empty', // 👈 Add this new argument
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Color color) {
    return SizedBox(
      height: 80,
      width: 20,
      child: TimelineTile(
        alignment: TimelineAlign.manual,
        lineXY: 0,
        isFirst: false,
        isLast: false,
        indicatorStyle: IndicatorStyle(
          indicatorXY: 0,
          width: 15,
          indicator: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(width: 5, color: color),
            ),
          ),
        ),
        afterLineStyle: LineStyle(thickness: 2, color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      case 'Empty':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // 🔹 Change the first parameter from Color to bool
  Widget _buildCard(bool isEmpty, String title, String slot, String status) {
    if (isEmpty) {
      return const SizedBox(height: 80, width: 250);
    }

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        // Use the bgColor from your API/Map if available, else a light blue
        color: (detail['bgColor'] is String)
            ? ApiService.hexToColor(detail['bgColor'])
            : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Row for Title + Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Edit & Delete Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 🔥 Slot/Time Range
          Text(
            slot,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),

          const SizedBox(height: 8),

          // 🔥 Status Badge (Like your static data)
          if (status != 'Empty')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
