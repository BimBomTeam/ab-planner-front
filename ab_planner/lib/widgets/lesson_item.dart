import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ab_planner/models/lesson.dart';
import 'package:ab_planner/screens/lesson_details_screen.dart';

class LessonItem extends StatelessWidget {
  final Lesson lesson;

  const LessonItem({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    final dateFormat = DateFormat('EEE, d MMM', 'pl_PL');

    final startTime = timeFormat.format(lesson.start.toLocal());
    final endTime = timeFormat.format(lesson.end.toLocal());
    final dayText = dateFormat.format(lesson.start.toLocal());

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailsScreen(lesson: lesson),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1A1F38),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.school, color: Colors.deepPurpleAccent, size: 32),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(dayText, style: const TextStyle(color: Colors.white70)),
                    Text('$startTime – $endTime | Sala ${lesson.room}', style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
