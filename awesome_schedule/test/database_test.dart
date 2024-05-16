import 'package:awesome_schedule/utils/common.dart';
import 'package:awesome_schedule/utils/sharedPreference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_schedule/database/courseListRelation_db.dart';
import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/database/courseTimeInfoRelation_db.dart';
import 'package:awesome_schedule/database/course_db.dart';
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
  test('清空数据库', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

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

    await courseTimeInfoDB.clear();
    await courseTimeInfoRelationDB.clear();
    await courseDB.clear();
    await courseListRelationDB.clear();
    await courseListDB.clear();
  });

  test('数据库测试', () async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

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

    CourseList courseList = CourseList(semester: '第一学期');
    courseList.weekNum = defalutWeekNum;
    courseList.currentWeek = 1;

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

    CourseList? tmp = await courseListDB.getCourseListByID(1);
    expect(tmp!.getSemester, courseList.getSemester);
    expect(tmp.getWeekNum, courseList.getWeekNum);
    expect(tmp.getCurrentWeek, courseList.getCurrentWeek);

    List<Course> tmpSet = tmp.getAllCourse();
    for (int i = 0; i < courseSet.length; i++) {
      expect(tmpSet[i].getCourseID, courseSet[i].getCourseID);
      expect(tmpSet[i].getDescription, courseSet[i].getDescription);
    }
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