import 'package:flutter/material.dart';
import 'package:my_app/models/task.dart';
import 'package:my_app/screens/detail/date_picker.dart';
import 'package:my_app/screens/detail/task_titile.dart';
import 'package:my_app/screens/detail/task_time_line.dart';

class DetailPage extends StatefulWidget {
  final Task task;

  const DetailPage(this.task, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late List detailList;

  @override
  void initState() {
    super.initState();
    detailList = widget.task.desc ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),

          // 🔹 Top Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [DatePicker(), TaskTitle()],
              ),
            ),
          ),

          // 🔹 Task List / Empty State
          (detailList.isEmpty)
              ? SliverFillRemaining(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        'No Task today',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TaskTimeLine(
                      detailList[index],

                      // Delete
                      onDelete: () {
                        setState(() {
                          detailList.removeAt(index);
                        });
                      },

                      // Edit
                      onEdit: () {
                        _showEditDialog(context, index);
                      },
                    ),
                    childCount: detailList.length,
                  ),
                ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final item = detailList[index];

    TextEditingController timeController = TextEditingController(
      text: item['time'],
    );

    TextEditingController titleController = TextEditingController(
      text: item['title'],
    );

    TextEditingController slotController = TextEditingController(
      text: item['slot'],
    );

    String selectedStatus = item['status'] ?? 'Pending';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  Time
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "Time"),
              ),

              //  Title / Status
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              //  Slot / Status detail
              TextField(
                controller: slotController,
                decoration: const InputDecoration(labelText: "Slot"),
              ),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: ['Pending', 'In Progress', 'Done']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
                decoration: const InputDecoration(labelText: "Status"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  detailList[index]['time'] = timeController.text;
                  detailList[index]['title'] = titleController.text;
                  detailList[index]['slot'] = slotController.text;
                  detailList[index]['status'] = selectedStatus;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 AppBar
  Widget _buildAppBar(BuildContext context) {
    int totalTasks = detailList
        .where((e) => (e['title'] ?? '').isNotEmpty)
        .length;

    int doneTasks = detailList
        .where((e) => (e['status'] ?? '') == 'Done')
        .length;

    int remainingTasks = totalTasks - doneTasks;

    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.white,
        iconSize: 20,
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'add') {
              _showAddTaskDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'add', child: Text('Add Task')),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$remainingTasks tasks',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'You have $remainingTasks tasks for today!',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    TextEditingController slotController = TextEditingController();

    String selectedStatus = 'Pending';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "Time (e.g. 10:00 AM)",
                ),
              ),
              TextField(
                controller: slotController,
                decoration: const InputDecoration(labelText: "Slot"),
              ),

              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: ['Pending', 'In Progress', 'Done']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
                decoration: const InputDecoration(labelText: "Status"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newTask = {
                  'time': timeController.text,
                  'title': titleController.text,
                  'slot': slotController.text,
                  'status': selectedStatus,
                  'tiColor': Colors.blue,
                  'bgColor': Colors.blue.shade50,
                };

                int index = detailList.indexWhere(
                  (e) => e['time'] == timeController.text,
                );
                setState(() {
                  if (index != -1) {
                    detailList[index] = newTask;
                  } else {
                    detailList.add(newTask);
                  }
                });

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
