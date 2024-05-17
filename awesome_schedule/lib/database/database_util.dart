import 'dart:async';

import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/database/courseTimeInfoRelation_db.dart';
import 'package:awesome_schedule/database/timeInfo_db.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/utils/common.dart';
import '../models/course.dart';
export './database_util.dart';

// 初始化全局数据库
Future<void> initDatabase() async {
  CourseTimeInfoDB courseTimeInfoDB = CourseTimeInfoDB();
  await courseTimeInfoDB.initDatabase();
  CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();
  await courseTimeInfoRelationDB.initDatabase();
  CourseDB courseDB = CourseDB();
  await courseDB.initDatabase();
  CourseListRelationDB courseListRelationDB = CourseListRelationDB();
  await courseListRelationDB.initDatabase();
  CourseListDB courseListDB = CourseListDB();
  await courseListDB.initDatabase();
}

// 清空数据库
Future<void> clearDatabase() async {
  initDatabase();
  CourseTimeInfoDB courseTimeInfoDB = CourseTimeInfoDB();
  await courseTimeInfoDB.clear();
  CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();
  await courseTimeInfoRelationDB.clear();
  CourseDB courseDB = CourseDB();
  await courseDB.clear();
  CourseListRelationDB courseListRelationDB = CourseListRelationDB();
  await courseListRelationDB.clear();
  CourseListDB courseListDB = CourseListDB();
  await courseListDB.clear();
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

  for (var course in courseSet) {
    await courseListDB.addCourseToCourseListByID(index, course);
  }
}