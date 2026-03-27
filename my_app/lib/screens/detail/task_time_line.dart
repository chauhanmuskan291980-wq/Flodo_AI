import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TaskTimeLine extends StatelessWidget {
  final Map<String, dynamic> detail;

  const TaskTimeLine(this.detail, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          _buildTimeline(
            detail['tiColor'] ?? const Color.fromARGB(255, 8, 125, 152),
          ),

          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail['time'] ?? ''),
                detail['title'].isNotEmpty
                    ? _buildCard(
                        detail['bgColor'] ??
                            const Color.fromARGB(255, 255, 255, 255),
                        detail['title'] ?? '',
                        detail['slot'] ?? '',
                      )
                    : _buildCard(Colors.white, '', ''),
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

  Widget _buildCard(Color bgColor, String title, String slot) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Top Row (Title + Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              if (title.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    print("Edit clicked");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    print("Delete clicked");
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),
          Text(slot, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
