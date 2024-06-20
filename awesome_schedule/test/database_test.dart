import 'package:awesome_schedule/database/note_db.dart';
import 'package:awesome_schedule/database/task_db.dart';
import 'package:awesome_schedule/models/note.dart';
import 'package:awesome_schedule/utils/common.dart';
import 'package:awesome_schedule/utils/sharedPreference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/database/database_util.dart';
import 'package:awesome_schedule/database/timeInfo_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/task.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/models/event.dart';
import 'package:awesome_schedule/models/course.dart';

void main() {
  test('重置数据库', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await clearDatabase();
    await initDatabase();
  });

  test('timeInfo_db测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    CourseTimeInfoDB courseTimeInfoDB = CourseTimeInfoDB();
    
  });

  test('task_db测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TaskDB taskDB = TaskDB();
    int courseId = 1;
    Task task1 = Task('1', DateTime.now());
    await taskDB.printDatabase();
    await taskDB.getTaskByID(1);
    await taskDB.deleteTaskByID(1);
    await taskDB.deleteTasksByCourseId(courseId);
    await taskDB.addTask(task1, courseId);
    await taskDB.getAllTask();
    await taskDB.getTaskByID(1);
    await taskDB.getTasksByCourseId(courseId);
    await taskDB.printDatabase();

    task1.setFinished();
    await taskDB.updateFinished(task1);
    await taskDB.deleteTaskByID(1);
    await taskDB.addTask(task1, courseId);
    await taskDB.deleteTasksByCourseId(courseId);
  });

  test('首选项测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    // 初始值
    SharedPreferences.setMockInitialValues({'number': 1, 'str': ''});

    int a = 114514;
    SharedPreferencesUtil.save<int>('number', a);
    int? geta = await SharedPreferencesUtil.read<int>('number');
    expect(geta, a);

    String b = '114514';
    SharedPreferencesUtil.save<String>('str', b);
    String? getb = await SharedPreferencesUtil.read<String>('str');
    expect(getb, b);
  });
}