import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:awesome_schedule/database/database_util.dart';
import 'dart:math';
import 'package:awesome_schedule/pages/homePage.dart';
import 'package:awesome_schedule/pages/logInPage.dart';

void main() async {
  // 初始化数据库
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  await clearDatabase();
  await setSomeDataToDatabase();
  // 获取课程表数据
  CourseListDB courseListDB = CourseListDB();
  currentCourseList = await courseListDB.getCourseListByID(1);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/logIn': (context) => const LogInPage()
      }
    );
  }
}
