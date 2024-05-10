import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:awesome_schedule/database/courseListRelation_db.dart';
import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/database/course_db.dart';
import 'package:awesome_schedule/database/timeInfo_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:awesome_schedule/pages/homePage.dart';
import 'package:awesome_schedule/pages/logInPage.dart';

void main() async {
  // 初始化数据库
  WidgetsFlutterBinding.ensureInitialized();
  // TimeInfoDB timeInfoDB = TimeInfoDB();
  // await timeInfoDB.initDatabase();
  // CourseDB courseDB = CourseDB();
  // await courseDB.initDatabase();
  // CourseListRelationDB courseListRelationDB = CourseListRelationDB();
  // await courseListRelationDB.initDatabase();
  // CourseListDB courseListDB = CourseListDB();
  // await courseListDB.initDatabase();
  
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
