import 'package:ab_planner/models/lesson.dart';
import 'package:flutter/material.dart';

class LessonItem extends StatelessWidget {

  final Lesson lesson;

  const LessonItem({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(lesson.title),
      subtitle: Text(lesson.description),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {}
    );
  }
}
