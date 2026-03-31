import 'package:flutter/material.dart';
import 'package:my_app/models/task.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/screens/detail/date_picker.dart';
import 'package:my_app/screens/detail/task_titile.dart';
import 'package:my_app/screens/detail/task_time_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final Task task;

  const DetailPage(this.task, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> detailList = [];
  bool isLoading = true;
  String currentFilter = 'All';

  List<dynamic> get filteredList {
    return detailList.where((task) {
      // 1. Filter by Search Query (Requirement: Search by Title)
      final String title = (task['title'] ?? '').toString().toLowerCase();
      final bool matchesSearch = title.contains(searchQuery.toLowerCase());

      // 2. Filter by Status (Requirement: Filter by Status) [cite: 25]
      // Options: "To-Do", "In Progress", "Done" [cite: 14]
      final bool matchesStatus =
          currentFilter == 'All' || task['status'] == currentFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  bool _isTaskLocked(Map<String, dynamic> task) {
    final blockedById = task['blocked_by'];

    // 1. If no blocker, it's not locked
    if (blockedById == null) return false;

    // 2. Find the parent task.
    // We use cast to ensure the return type matches exactly what Dart expects.
    final parentTask = detailList.firstWhere(
      (t) => t['id'] == blockedById,
      orElse: () => <String, dynamic>{}, // Returns an empty map instead of null
    );

    // 3. Check if we actually found a task and if its status is NOT Done
    if (parentTask.isEmpty || parentTask['status'] != 'Done') {
      return true;
    }

    return false;
  }

  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";

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
          displayItem['id'] = int.tryParse(task['id'].toString()); // The DB ID
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
      debugPrint("LOADING ERROR: $e"); // 🔹 Prints error to console
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveDraft({
    required String title,
    required String time,
    required String slot,
    required String status,
    required int? blockedBy,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('draft_title', title);
    await prefs.setString('draft_time', time);
    await prefs.setString('draft_slot', slot);
    await prefs.setString('draft_status', status);
    if (blockedBy != null) {
      await prefs.setInt('draft_blocked_by', blockedBy);
    } else {
      await prefs.remove('draft_blocked_by');
    }
  }

  Future<Map<String, dynamic>> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'title': prefs.getString('draft_title') ?? '',
      'time': prefs.getString('draft_time') ?? '',
      'slot': prefs.getString('draft_slot') ?? '',
      'status': prefs.getString('draft_status') ?? 'Pending',
      'blocked_by': prefs.getInt('draft_blocked_by'),
    };
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DatePicker(),
                  TaskTitle(
                    selectedFilter: currentFilter,
                    onFilterChanged: (newFilter) {
                      setState(() {
                        currentFilter = newFilter;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Task List / Empty State
          (filteredList.isEmpty)
              ? SliverFillRemaining(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        'No matching tasks found',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                )
              : // 🔹 Inside your SliverList in detail.dart
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Use filteredList for display, but detailList for logic if needed
                    final currentTask = filteredList[index];
                    bool isLocked = _isTaskLocked(currentTask);

                    return IgnorePointer(
                      ignoring: isLocked,
                      child: ColorFiltered(
                        colorFilter: isLocked
                            ? const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              )
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                        child: Opacity(
                          opacity: isLocked ? 0.5 : 1.0,
                          child: TaskTimeLine(
                            currentTask,
                            index,
                            onDelete: () async {
                              final dynamic idValue = currentTask['id'];
                              if (idValue != null) {
                                int? taskId = int.tryParse(idValue.toString());
                                if (taskId == null) return;
                                final bool success =
                                    await ApiService.deletetask(taskId);
                                if (success) {
                                  setState(() {
                                    detailList.removeWhere(
                                      (t) => t['id'] == taskId,
                                    );
                                  });
                                }
                              }
                            },
                            onEdit: () {
                              // Find the original index in detailList if needed,
                              // or just pass the task data to your dialog
                              _showEditDialog(context, currentTask);
                            },
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredList.length),
                ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    // Controllers for text fields
    TextEditingController timeController = TextEditingController(
      text: item['time'],
    );
    TextEditingController titleController = TextEditingController(
      text: item['title'],
    );
    TextEditingController slotController = TextEditingController(
      text: item['slot'],
    );

    // State variables for the dialog
    String selectedStatus = item['status'] ?? 'Pending';

    // 🔹 Get the existing blocked_by ID (safely cast to int)
    int? selectedBlockedById = item['blocked_by'] != null
        ? int.tryParse(item['blocked_by'].toString())
        : null;

    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Task"),
              content: SingleChildScrollView(
                // Added scroll to prevent overflow with dropdown
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                      enabled: !isUpdating,
                    ),

                    //  DATE FIELD (fixed)
                    TextFormField(
                      controller: timeController,
                      readOnly: true,
                      enabled: !isUpdating,
                      decoration: const InputDecoration(
                        labelText: "Due Date",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: !isUpdating
                          ? () async {
                              DateTime initialDate;

                              //  Parse existing date safely
                              try {
                                initialDate = DateTime.parse(
                                  timeController.text,
                                );
                              } catch (e) {
                                initialDate = DateTime.now();
                              }

                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                              );

                              if (pickedDate != null) {
                                setDialogState(() {
                                  timeController.text =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                });
                              }
                            }
                          : null,
                    ),

                    TextField(
                      controller: slotController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      enabled: !isUpdating,
                    ),
                    const SizedBox(height: 10),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: "Status"),
                      items: ['Pending', 'In Progress', 'Done']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: isUpdating
                          ? null
                          : (v) => setDialogState(() => selectedStatus = v!),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 "Blocked By" Dropdown (The key addition)
                    DropdownButtonFormField<int>(
                      value:
                          detailList
                              .where((t) => t['id'] != item['id'])
                              .any(
                                (t) =>
                                    int.tryParse(t['id'].toString()) ==
                                    selectedBlockedById,
                              )
                          ? selectedBlockedById
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Blocked By (Parent Task)",
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                      hint: const Text("None (Select Parent)"),
                      // Filter out the current task so it can't block itself
                      items: detailList
                          .where((t) => t['id'] != item['id'])
                          .map((taskItem) {
                            final id = int.tryParse(taskItem['id'].toString());
                            if (id == null) return null;

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                taskItem['title'] ?? "Untitled Task",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>() // removes nulls
                          .toList(),
                      onChanged: isUpdating
                          ? null
                          : (value) {
                              setDialogState(() => selectedBlockedById = value);
                            },
                    ),
                  ],
                ),
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
                            final int? taskId = item['id'] is int
                                ? item['id']
                                : int.tryParse(item['id']?.toString() ?? '');

                            final int? subIndex = item['subIndex'] is int
                                ? item['subIndex']
                                : int.tryParse(
                                    item['subIndex']?.toString() ?? '',
                                  );

                            if (taskId == null || subIndex == null) {
                              throw Exception(
                                "Invalid taskId or subIndex (null)",
                              );
                            }

                            // Prepare the full list for the "desc" field update
                            List<Map<String, dynamic>> fullList =
                                (item['parentList'] as List)
                                    .map(
                                      (e) =>
                                          Map<String, dynamic>.from(e as Map),
                                    )
                                    .toList();

                            final Map<String, dynamic> updatedEntry = {
                              'time': timeController.text,
                              'title': titleController.text,
                              'slot': slotController.text,
                              'status': selectedStatus,
                              'blocked_by':
                                  selectedBlockedById, // 🔹 Include the ID here
                            };

                            fullList[subIndex] = updatedEntry;

                            // API Update
                            await ApiService.updatetask(taskId, {
                              "desc": fullList,
                              // If your backend stores blocked_by at the top level, add it here too:
                              "blocked_by": selectedBlockedById,
                            });

                            // UI Update
setState(() {
  final i = detailList.indexWhere(
    (t) =>
        t['id'] == item['id'] &&
        t['subIndex'] == item['subIndex'],
  );

  if (i != -1) {
    detailList[i] = {
      ...Map<String, dynamic>.from(item),
      ...updatedEntry,
      'parentList': fullList,
    };
  }
});

                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            debugPrint("UPDATE FAILED: $e");
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
      pinned: true,
      // Slightly increase height when not searching to accommodate the two-line title
      expandedHeight: isSearching ? 80 : 100,
      backgroundColor: widget.task.bgColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (isSearching) {
            setState(() {
              isSearching = false;
              searchQuery = "";
              searchController.clear();
            });
          } else {
            Navigator.of(context).pop();
          }
        },
        // Change icon based on search state
        icon: Icon(isSearching ? Icons.close : Icons.arrow_back_ios),
        color: const Color.fromARGB(255, 0, 0, 0),
        iconSize: 20,
      ),
      actions: [
        // Only show Search Icon if not currently searching
        if (!isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => setState(() => isSearching = true),
          ),
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
        titlePadding: EdgeInsets.only(
          left: isSearching ? 50 : 60,
          bottom: isSearching ? 12 : 15,
          right: 20,
        ),
        // Toggle between Search TextField and Task Summary Title
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  hintText: "Search tasks by title...", // Requirement
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$remainingTasks tasks',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'You have $remainingTasks tasks In this week!',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color.fromARGB(
                        255,
                        0,
                        0,
                        0,
                      ).withOpacity(0.7),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) async {
    final draft = await _loadDraft();

    TextEditingController titleController = TextEditingController(
      text: draft['title'],
    );

    TextEditingController timeController = TextEditingController(
      text: draft['time'],
    );

    TextEditingController slotController = TextEditingController(
      text: draft['slot'],
    );

    int? selectedBlockedById = draft['blocked_by'];
    String selectedStatus = draft['status'] ?? 'Pending';

    bool isAdding = false;

    // 🔹 Helper to save draft everywhere
    void saveDraft() {
      _saveDraft(
        title: titleController.text,
        time: timeController.text,
        slot: slotController.text,
        status: selectedStatus,
        blockedBy: selectedBlockedById,
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Task"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                      enabled: !isAdding,
                      onChanged: (_) => saveDraft(),
                    ),

                    // 🔹 Date
                    TextFormField(
                      controller: timeController,
                      readOnly: true,
                      enabled: !isAdding,
                      decoration: const InputDecoration(
                        labelText: "Due Date",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: isAdding
                          ? null
                          : () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                              );

                              if (pickedDate != null) {
                                setDialogState(() {
                                  timeController.text =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                });
                                saveDraft();
                              }
                            },
                    ),

                    // 🔹 Description
                    TextField(
                      controller: slotController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      enabled: !isAdding,
                      onChanged: (_) => saveDraft(),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Status
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: "Status"),
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
                              setDialogState(() {
                                selectedStatus = value!;
                              });
                              saveDraft();
                            },
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Blocked By (FIXED CRASH)
                    DropdownButtonFormField<int>(
                      value:
                          detailList.any(
                            (t) =>
                                int.tryParse(t['id'].toString()) ==
                                selectedBlockedById,
                          )
                          ? selectedBlockedById
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Blocked By (Optional)",
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                      hint: const Text("Select a task"),
                      items: detailList
                          .where((t) => t['id'] != null)
                          .map((taskItem) {
                            final id = int.tryParse(taskItem['id'].toString());
                            if (id == null) return null;

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                taskItem['title'] ?? "Untitled Task",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>()
                          .toList(),
                      onChanged: isAdding
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedBlockedById = value;
                              });
                              saveDraft();
                            },
                    ),
                  ],
                ),
              ),

              actions: [
                // 🔹 Cancel
                TextButton(
                  onPressed: isAdding
                      ? null
                      : () {
                          Navigator.pop(context);
                          // ❌ DO NOT clear draft here
                        },
                  child: const Text("Cancel"),
                ),

                // 🔹 Add Button
                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          setDialogState(() => isAdding = true);

                          try {
                            final Map<String, dynamic> newTaskData = {
                              'time': timeController.text,
                              'title': titleController.text,
                              'slot': slotController.text,
                              'status': selectedStatus,
                              'blocked_by': selectedBlockedById,
                            };

                            await ApiService.postTask(
                              title: titleController.text,
                              blockedBy: selectedBlockedById,
                              iconColor: Colors.blue,
                              bgColor: Colors.blue.withOpacity(0.1),
                              desc: [newTaskData],
                            );

                            setState(() {
                              detailList.add(newTaskData);
                            });

                            // ✅ CLEAR DRAFT AFTER SUCCESS
                            await _clearDraft();

                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            debugPrint("Error adding task: $e");
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => isAdding = false);
                            }
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
