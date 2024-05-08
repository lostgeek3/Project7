import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled3/database/courseListRelation_db.dart';
import 'package:untitled3/database/courseList_db.dart';
import 'package:untitled3/database/course_db.dart';
import 'package:untitled3/database/timeInfo_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:untitled3/models/courseList.dart';
import 'package:untitled3/models/task.dart';
import 'package:untitled3/models/timeInfo.dart';
import 'package:untitled3/models/event.dart';
import 'package:untitled3/models/course.dart';

void main() {
  test('清空数据库', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TimeInfoDB timeInfoDB = TimeInfoDB();
    await timeInfoDB.initDatabase();
    CourseDB courseDB = CourseDB();
    await courseDB.initDatabase();
    CourseListRelationDB courseListRelationDB = CourseListRelationDB();
    await courseListRelationDB.initDatabase();
    CourseListDB courseListDB = CourseListDB();
    await courseListDB.initDatabase();

    await timeInfoDB.clear();
    await courseDB.clear();
    await courseListRelationDB.clear();
    await courseListDB.clear();
  });

  test('TimeInfoDB测试', () async {
    // 初始化数据库工厂
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TimeInfoDB timeInfoDB = TimeInfoDB();
    await timeInfoDB.initDatabase();

    await timeInfoDB.clear();
    await timeInfoDB.addTimeInfo(TimeInfo(DateTime.now(), DateTime.now()));
    await timeInfoDB.getAllTimeInfo();
    await timeInfoDB.getTimeInfoByID(0);
    await timeInfoDB.getTimeInfoByID(1);

    await timeInfoDB.deleteTimeInfoByID(0);
    await timeInfoDB.deleteTimeInfoByID(1);

    await timeInfoDB.getAllTimeInfo();
  });

  test('CourseDB测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    CourseDB courseDB = CourseDB();
    await courseDB.initDatabase();

    await courseDB.addCourse(Course('课程', TimeInfo(DateTime.now(), DateTime.now())));
    await courseDB.getAllCourse();
    await courseDB.getCourseByID(0);
    await courseDB.getCourseByID(1);
  });

  test('CourseListRelationDB测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    CourseListRelationDB courseListRelationDB = CourseListRelationDB();
    await courseListRelationDB.initDatabase();

    await courseListRelationDB.addCourseListRelation(CourseListRelation(1, 1));
    await courseListRelationDB.addCourseListRelation(CourseListRelation(1, 2));
    await courseListRelationDB.addCourseListRelation(CourseListRelation(2, 3));
    await courseListRelationDB.addCourseListRelation(CourseListRelation(2, 4));
    await courseListRelationDB.addCourseListRelation(CourseListRelation(2, 5));
    await courseListRelationDB.getAllCourseListRelation();
    await courseListRelationDB.getCourseListRelationByID(0);
    await courseListRelationDB.getCourseListRelationByID(1);
    await courseListRelationDB.getCourseListRelationByID(2);

    await courseListRelationDB.deleteTimeInfoByID(2);
    await courseListRelationDB.getAllCourseListRelation();
  });

  test('CourseListDB测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    CourseListDB courseListDB = CourseListDB();
    await courseListDB.initDatabase();

    int index = await courseListDB.addCourseList(CourseList(semester: '学期'));
    await courseListDB.addCourseToCourseListByID(index, Course('课程1', TimeInfo(DateTime.now(), DateTime.now())));
    await courseListDB.addCourseToCourseListByID(index, Course('课程2', TimeInfo(DateTime.now(), DateTime.now())));

    CourseList? courseList = await courseListDB.getCourseListByID(index);
    if (courseList == null) return;
    courseList.getAllCourse()[0].printCourse();
    courseList.getAllCourse()[1].printCourse();
  });
}