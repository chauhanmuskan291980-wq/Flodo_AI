import 'package:flutter/material.dart';
import 'package:my_app/models/task.dart';
import 'package:my_app/screens/detail/detail.dart';

class Tasks extends StatelessWidget {
  final List<Task> taskList = Task.generateTask();

  Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        itemCount: taskList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final task = taskList[index];

          return task.isLast
              ? _buildAddTask(context)
              : _buildTask(context, task);
        },
      ),
    );
  }

  // 🔥 ADD TASK CARD (Clickable)
  Widget _buildAddTask(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // 👉 Navigate or open dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add Task Clicked")),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 40, color: Colors.black54),
              SizedBox(height: 10),
              Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 TASK CARD (UPGRADED UI)
  Widget _buildTask(BuildContext context, Task task) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailPage(task),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.bgColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: task.iconColor?.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.iconData ?? Icons.task,
                color: task.iconColor ?? Colors.black,
                size: 22,
              ),
            ),

            const Spacer(),

            // 🔥 TITLE
            Text(
              task.title ?? 'Task',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 STATUS ROW
            Row(
              children: [
                _buildTaskStatus(
                  task.btnColor ?? Colors.black,
                  Colors.white,
                  '${task.left ?? 0} left',
                ),
                const SizedBox(width: 6),
                _buildTaskStatus(
                  Colors.white,
                  task.iconColor ?? Colors.black,
                  '${task.done ?? 0} done',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 STATUS CHIP
  Widget _buildTaskStatus(Color bgColor, Color textColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}