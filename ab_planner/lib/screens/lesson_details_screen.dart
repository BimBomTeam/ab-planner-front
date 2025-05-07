import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ab_planner/models/lesson.dart';

class LessonDetailsScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailsScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
    final timeFormat = DateFormat.Hm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zajęć'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧠 ${lesson.title}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('📅 Data: ${dateFormat.format(lesson.start)}'),
            Text('🕒 Czas: ${timeFormat.format(lesson.start)} – ${timeFormat.format(lesson.end)}'),
            Text('🏫 Sala: ${lesson.room}'),
            Text('👨‍🏫 Nauczyciel ID: ${lesson.teacherId}'),
            Text('📚 Typ zajęć ID: ${lesson.lessonTypeId}'),
            Text('👥 Grupa ID: ${lesson.groupId}'),
            const SizedBox(height: 24),
            Text('📌 ID lekcji: ${lesson.id}'),
            Text('🕐 Utworzono: ${lesson.createdAt.toLocal()}'),
            Text('🔄 Zmieniono: ${lesson.updatedAt.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
