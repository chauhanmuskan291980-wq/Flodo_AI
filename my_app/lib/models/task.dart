import 'package:flutter/material.dart';
import 'package:my_app/constants/colors.dart';

class Task {
  int? id;
  IconData? iconData;
  String? title;
  int? blockBy;
  Color? bgColor;
  Color? iconColor;
  Color? btnColor;
  num? left;
  num? done;
  List<Map<String, dynamic>>? desc;
  bool? isLast;
  Task({
    this.id,
    this.iconData,
    this.title,
    this.blockBy,
    this.bgColor,
    this.iconColor,
    this.btnColor,
    this.left,
    this.done,
    this.desc,
    this.isLast = false,
  });
  static List<Task> generateTask() {
    return [
      Task(
        iconData: Icons.person_rounded,
        title: "Personal",
        bgColor: kYellowLight,
        iconColor: kYellowDark,
        btnColor: kYellow,
        left: 3,
        done: 1,
        desc: [],
      ),
      Task(
        iconData: Icons.cases_rounded,
        title: "Work",
        bgColor: kRedLight,
        iconColor: kRedDark,
        btnColor: kRed,
        left: 0,
        done: 0,
        desc: [],
      ),
      Task(
        iconData: Icons.favorite_rounded,
        title: "Health",
        bgColor: kBlueLight,
        iconColor: kBlueDark,
        btnColor: kBlue,
        left: 0,
        done: 0,
        desc: [],
      ),
      Task(isLast: true),
    ];
  }
}
