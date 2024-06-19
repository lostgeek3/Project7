import 'dart:async';

import 'package:awesome_schedule/database/activity_db.dart';
import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/database/noteImage_db.dart';
import 'package:awesome_schedule/database/note_db.dart';
import 'package:awesome_schedule/database/task_db.dart';
import 'package:awesome_schedule/database/timeInfo_db.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/task.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/utils/common.dart';
import '../models/course.dart';
export './database_util.dart';
import 'package:awesome_schedule/models/note.dart';

// 初始化全局数据库
Future<void> initDatabase() async {
  CourseTimeInfoDB courseTimeInfoDB = CourseTimeInfoDB();
  await courseTimeInfoDB.initDatabase();
  CourseDB courseDB = CourseDB();
  await courseDB.initDatabase();
  CourseListDB courseListDB = CourseListDB();
  await courseListDB.initDatabase();
  TaskDB taskDB = TaskDB();
  await taskDB.initDatabase();
  ActivityDB activityDB = ActivityDB();
  await activityDB.initDatabase();
  NoteImageDB noteImageDB = NoteImageDB();
  await noteImageDB.initDatabase();
  NoteDB noteDB = NoteDB();
  await noteDB.initDatabase();
}

// 清空数据库
Future<void> clearDatabase() async {
  initDatabase();
  CourseTimeInfoDB courseTimeInfoDB = CourseTimeInfoDB();
  await courseTimeInfoDB.clear();
  CourseDB courseDB = CourseDB();
  await courseDB.clear();
  CourseListDB courseListDB = CourseListDB();
  await courseListDB.clear();
  TaskDB taskDB = TaskDB();
  await taskDB.clear();
  ActivityDB activityDB = ActivityDB();
  await activityDB.clear();
  NoteImageDB noteImageDB = NoteImageDB();
  await noteImageDB.clear();
  NoteDB noteDB = NoteDB();
  await noteDB.clear();
}

// 若课表数据库为空，则给予一些初始值
Future<void> setSomeDataToDatabase() async {
  CourseList courseList = CourseList(semester: '第一学期');
  courseList.weekNum = 20;
  courseList.currentWeek = 1;

  CourseListDB courseListDB = CourseListDB();
  if (!await courseListDB.isEmpty()) {
    return;
  }
  int index = await courseListDB.addCourseList(courseList);

  var courseSet = [
    Course('高等数学',
        [CourseTimeInfo(8, 0, 9, 40,
            endWeek: defalutWeekNum,
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
            endWeek: defalutWeekNum,
            weekday: 3,
            startSection: 7,
            endSection: 8,
            weeks: [1, 2, 3, 4])],
        location: '教1-102',
        teacher: '李四',
        description: '这是一门代数课'),
  ];

  courseSet[0].addTask(Task('作业1', DateTime(2024, 6, 20, 23, 59), location: '宿舍', description: '高数作业1', taskType: TaskType.homework));
  courseSet[0].addTask(Task('作业2', DateTime(2024, 6, 21, 23, 59), location: '宿舍', description: '高数作业2', taskType: TaskType.homework));
  courseSet[1].addTask(Task('Lab1', DateTime(2024, 6, 22, 23, 59), location: '图书馆', description: 'Lab1', taskType: TaskType.lab));
  courseSet[1].addTask(Task('作业1', DateTime(2024, 6, 23, 23, 59), location: '自习室', description: '线代作业1', taskType: TaskType.homework));
  courseSet[1].addTask(Task('作业2', DateTime(2024, 6, 24, 23, 59), location: '教室', description: '线代作业1', taskType: TaskType.homework));

  for (var course in courseSet) {
    await courseListDB.addCourseToCourseListByID(index, course);
  }

  Note note = Note('课堂笔记1', DateTime.now());
  note.courseId = 1;
  NoteDB noteDB = NoteDB();
  noteDB.addNote(note);
}