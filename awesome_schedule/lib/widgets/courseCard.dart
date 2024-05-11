import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import '../models/course.dart';

export './CourseCard.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      // 卡片装饰
      elevation: 4, // 阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 圆角
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 课程标题
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              course.getName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 课程描述
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              course.getDescription,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          )
        ],
      )
    );
  }
}