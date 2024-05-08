import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled3/database/course_db.dart';
import 'package:untitled3/database/timeInfo_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

    await timeInfoDB.clear();
    await courseDB.clear();
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
    await courseDB.getTimeInfoByID(0);
    await courseDB.getTimeInfoByID(1);
  });
}