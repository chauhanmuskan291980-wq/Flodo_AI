import 'package:flutter/material.dart';
import 'package:my_app/models/task.dart';
import 'package:my_app/services/api_service.dart';
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
  List<dynamic> detailList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

Future<void> _loadTaskDetails() async {
  try {
    final List<dynamic> data = await ApiService.getTasks(); 

    List<Map<String, dynamic>> allSubTasks = [];

    // 🔹 LOOP through every task in the database
    for (var task in data) {
      if (task['desc'] != null && task['desc'] is List) {
        // Add all sub-tasks from this specific task to our big list
        allSubTasks.addAll(List<Map<String, dynamic>>.from(task['desc']));
      }
    }

    setState(() {
      // Now detailList contains EVERY sub-task from EVERY category in the DB
      detailList = allSubTasks;
      isLoading = false;
    });
    
    print("Total sub-tasks fetched: ${detailList.length}");
  } catch (e) {
    print("Fetch Error: $e");
    setState(() => isLoading = false);
  }
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
              : // 🔹 Inside your SliverList in detail.dart
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                  
                    return TaskTimeLine(
                      detailList[index],
                      index,
                      onDelete: () {
                        setState(() {
                          detailList.removeAt(index);
                        });
                      },
                      onEdit: () {
                        _showEditDialog(context, index);
                      },
                    );
                  }, childCount: detailList.length),
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
      backgroundColor: widget.task.bgColor,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios),
        color: const Color.fromARGB(255, 0, 0, 0),
        iconSize: 20,
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
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
        titlePadding: const EdgeInsets.only(
          left: 60,
          bottom: 15,
        ), // Prevents text from hitting the back button
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$remainingTasks tasks',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0), // 🔹 Forced White
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'You have $remainingTasks tasks for today!',
              style: TextStyle(
                fontSize: 10,
                color: const Color.fromARGB(
                  255,
                  0,
                  0,
                  0,
                ).withOpacity(0.7), // 🔹 Forced Light Grey/White
                fontWeight: FontWeight.normal,
              ),
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
              onPressed: () async {
                final List<Map<String, dynamic>> currentDesc = [
                  {
                    'time': timeController.text,
                    'title': titleController.text,
                    'slot': slotController.text,
                    'status': selectedStatus,
                  },
                ];

                //  Send to Backend
                await ApiService.postTask(
                  title: titleController.text,
                  iconColor: Colors.blue,
                  bgColor: Colors.blue.withOpacity(0.1),
                  desc: currentDesc,
                );

                setState(() {
                  detailList.add(currentDesc[0]);
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
