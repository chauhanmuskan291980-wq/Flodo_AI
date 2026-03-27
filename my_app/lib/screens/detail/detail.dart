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
                children: [
                  DatePicker(),
                  TaskTitle(),
                ],
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
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TaskTimeLine(
                      detailList[index],

                      // ✅ DELETE FUNCTION
                      onDelete: () {
                        setState(() {
                          detailList.removeAt(index);
                        });
                      },

                      // ✏️ EDIT (for future)
                      onEdit: () {
                        print("Edit task at index $index");
                      },
                    ),
                    childCount: detailList.length,
                  ),
                ),
        ],
      ),
    );
  }

  // 🔹 AppBar
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.white,
        iconSize: 20,
      ),
      actions: const [
        Icon(Icons.more_vert, size: 30, color: Colors.white),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.task.title} tasks',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'You have ${widget.task.left} tasks for today!',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}