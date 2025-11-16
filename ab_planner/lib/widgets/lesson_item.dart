import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ab_planner/models/lesson.dart';
import 'package:ab_planner/screens/lesson_details_screen.dart';

class LessonItem extends StatelessWidget {
  final dynamic lesson; // Akceptuje zarówno Lesson jak i LessonV1

  const LessonItem({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    final dateFormat = DateFormat('EEE, d MMM', 'pl_PL');

    // Obsługa zarówno starych jak i nowych lekcji
    final DateTime startTime;
    final DateTime endTime;
    final String title;
    final String roomText;

    if (lesson is LessonV1) {
      final lessonV1 = lesson as LessonV1;
      startTime = lessonV1.startsAt.toLocal();
      endTime = lessonV1.endsAt.toLocal();
      title = lessonV1.subject.name;
      roomText = '${lessonV1.room.building} ${lessonV1.room.number}';
    } else {
      final oldLesson = lesson as Lesson;
      startTime = oldLesson.start.toLocal();
      endTime = oldLesson.end.toLocal();
      title = oldLesson.title;
      roomText = oldLesson.room;
    }

    final startTimeStr = timeFormat.format(startTime);
    final endTimeStr = timeFormat.format(endTime);
    final dayText = dateFormat.format(startTime);

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
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(dayText, style: const TextStyle(color: Colors.white70)),
                    Text('$startTimeStr – $endTimeStr | Sala $roomText', style: const TextStyle(color: Colors.white60)),
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
