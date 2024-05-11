import 'package:awesome_schedule/models/course.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/timeInfo.dart';


var courseSet = [
  Course('高等数学',
      [CourseTimeInfo(8, 0, 9, 40,
          endWeek: 16,
          weekday: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 2, 3, 4])],
      courseID: 'MATH001',
      location: '教1-101',
      teacher: '张三',
      description: '这是一门数学课'),
  Course('线性代数',
      [CourseTimeInfo(14, 0, 15, 40,
          endWeek: 16,
          weekday: 3,
          startSection: 7,
          endSection: 8,
          weeks: [1, 2, 3, 4])],
      location: '教1-102',
      teacher: '李四',
      description: '这是一门代数课'),
];