import 'package:flutter/material.dart';
import 'package:my_app/models/task.dart';

class Tasks extends StatelessWidget {
  final List<Task> taskList = Task.generateTask();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GridView.builder(
        itemCount: taskList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85, // optional, adjust height
        ),
        itemBuilder: (context, index) {
          final task = taskList[index];
          return task.isLast ?? false
              ? _buildAddTask()
              : _buildTask(context, task);
        },
      ),
    );
  }

  // Widget for the "Add Task" button
  Widget _buildAddTask() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
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
    );
  }

  // Widget for a single task card
  Widget _buildTask(BuildContext context, Task task) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: task.bgColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            task.iconData ?? Icons.task,
            color: task.iconColor ?? Colors.black,
            size: 35,
          ),
          const SizedBox(height: 30),
          Text(
            task.title ?? 'Task',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTaskStatus(
                  task.btnColor ?? Colors.black, task.iconColor ?? Colors.white, '${task.left ?? 0} left'),
              const SizedBox(width: 5),
              _buildTaskStatus(Colors.white, task.iconColor ?? Colors.black, '${task.done ?? 0} done'),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for showing left/done status
  Widget _buildTaskStatus(Color bgColor, Color textColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}