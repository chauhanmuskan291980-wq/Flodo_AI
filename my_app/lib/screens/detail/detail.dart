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

      for (var task in data) {
        // 🔹 Fallback to empty list if null to prevent "Iterable" error
        final List<dynamic> originalDescList = task['desc'] ?? [];

        for (int i = 0; i < originalDescList.length; i++) {
          Map<String, dynamic> displayItem = Map<String, dynamic>.from(
            originalDescList[i] as Map,
          );

          // 🔹 CRITICAL: Store these three things for instant UI updates
          displayItem['id'] = task['id']; // The DB ID
          displayItem['subIndex'] = i; // Position in JSON
          displayItem['parentList'] = originalDescList; // The full JSON list

          allSubTasks.add(displayItem);
        }
      }
      setState(() {
        detailList = allSubTasks;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("🔴 LOADING ERROR: $e"); // 🔹 Prints error to console
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
                      onDelete: () async {
                        // Use 'as int?' or check for null to prevent the crash
                        final dynamic idValue = detailList[index]['id'];

                        if (idValue == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Error: Task ID missing. Try refreshing.",
                              ),
                            ),
                          );
                          return;
                        }

                        int taskId = idValue as int; // Now it is safe to cast

                        final bool success = await ApiService.deletetask(
                          taskId,
                        );
                        if (success) {
                          setState(() {
                            detailList.removeAt(index);
                          });
                        }
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

    bool isUpdating = false; // Loading state

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "Time"),
                    enabled: !isUpdating,
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                    enabled: !isUpdating,
                  ),
                  TextField(
                    controller: slotController,
                    decoration: const InputDecoration(labelText: "Slot"),
                    enabled: !isUpdating,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Pending', 'In Progress', 'Done']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: isUpdating
                        ? null
                        : (v) => setDialogState(() => selectedStatus = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          setDialogState(() => isUpdating = true);
                          try {
                            final int taskId = item['id'] as int;
                            final int subIndex = item['subIndex'] as int;

                            // 1. Force the list to be List<Map<String, dynamic>>
                            List<Map<String, dynamic>> fullList =
                                (item['parentList'] as List)
                                    .map(
                                      (e) =>
                                          Map<String, dynamic>.from(e as Map),
                                    )
                                    .toList();

                            final Map<String, dynamic> newEntry = {
                              'time': timeController.text,
                              'title': titleController.text,
                              'slot': slotController.text,
                              'status': selectedStatus,
                            };

                            // 2. Update the specific index
                            fullList[subIndex] = newEntry;

                            // 3. API Call
                            await ApiService.updatetask(taskId, {
                              "desc": fullList,
                            });

                            // 4. Update UI with typed data
                            setState(() {
                              detailList[index] = {
                                ...Map<String, dynamic>.from(
                                  item,
                                ), // Ensure item is casted
                                ...newEntry,
                                'parentList': fullList,
                              };
                            });

                            if (context.mounted)
                              Navigator.of(context, rootNavigator: true).pop();
                          } catch (e) {
                            debugPrint("🔴 UPDATE FAILED: $e");
                            if (context.mounted) {
                              setDialogState(() => isUpdating = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
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
    bool isAdding = false; // Local state to track loading

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while saving
      builder: (context) {
        // 1. Wrap with StatefulBuilder to manage dialog-specific state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                    enabled: !isAdding, // Disable input during loading
                  ),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "Time"),
                    enabled: !isAdding,
                  ),
                  TextField(
                    controller: slotController,
                    decoration: const InputDecoration(labelText: "Slot"),
                    enabled: !isAdding,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Pending', 'In Progress', 'Done']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: isAdding
                        ? null
                        : (value) {
                            setDialogState(() => selectedStatus = value!);
                          },
                    decoration: const InputDecoration(labelText: "Status"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isAdding ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  // 2. Disable button if isAdding is true to prevent double-tapping
                  onPressed: isAdding
                      ? null
                      : () async {
                          // 3. Start loading state
                          setDialogState(() => isAdding = true);

                          try {
                            // 4. Simulate mandatory 2-second delay [cite: 28]
                            await Future.delayed(const Duration(seconds: 2));

                            final List<Map<String, dynamic>> currentDesc = [
                              {
                                'time': timeController.text,
                                'title': titleController.text,
                                'slot': slotController.text,
                                'status': selectedStatus,
                              },
                            ];

                            // API call [cite: 34]
                            await ApiService.postTask(
                              title: titleController.text,
                              iconColor: Colors.blue,
                              bgColor: Colors.blue.withOpacity(0.1),
                              desc: currentDesc,
                            );

                            // Update main page list
                            setState(() {
                              detailList.add(currentDesc[0]);
                            });

                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            print("Error: $e");
                          } finally {
                            // 5. Reset loading state if the dialog is still open
                            if (context.mounted)
                              setDialogState(() => isAdding = false);
                          }
                        },
                  child: isAdding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
