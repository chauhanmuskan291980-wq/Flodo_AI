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
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
      height: 90,
      width: 20,
      child: TimelineTile(
        alignment: TimelineAlign.manual,
        lineXY: 0.5,
        isFirst: false,
        isLast: false,
        indicatorStyle: IndicatorStyle(
          width: 16,
          indicator: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: color, width: 3),
            ),
          ),
        ),
        beforeLineStyle: LineStyle(color: color.withOpacity(0.3), thickness: 2),
        afterLineStyle: LineStyle(color: color.withOpacity(0.3), thickness: 2),
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

    final Color statusColor = _getStatusColor(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 260,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, // 🔥 clean white card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.2), // subtle status border
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Title + Actions Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left colored strip (status indicator)
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(width: 10),

              // Title + Slot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slot,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 Actions (clean icons)
              Row(
                children: [
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.edit, size: 18, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete, size: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🔥 Status Badge (Modern pill)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
