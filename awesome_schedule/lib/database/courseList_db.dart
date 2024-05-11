export './course_db.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_schedule/database/courseListRelation_db.dart';
import 'package:awesome_schedule/database/course_db.dart';
import 'package:awesome_schedule/database/timeInfo_db.dart';
import 'package:awesome_schedule/models/courseList.dart';
import '../models/course.dart';
import 'package:awesome_schedule/models/timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0
  )
);
const String logTag = '[Database]CourseListDB: ';
// 是否显示日志
bool showLog = false;

class CourseListDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'courseList.db';
  // 数据库表名
  final String _tableName = 'coursesList';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  Future<void> initDatabase() async {
    _columuName = ['id', 'semester', 'currentWeek', 'weekNum'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} INTEGER NOT NULL,'
    '${_columuName[3]} INTEGER NOT NULL)';

    try {
      // 数据库文件路径
      String path = join(await getDatabasesPath(), _databaseName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          db.execute(_sql);
        }
      );
      if (showLog) logger.i('$logTag数据库初始化成功');
    }
    catch (error) {
      if (showLog) logger.e('$logTag数据库初始化失败。$error');
    }
  }

  // 添加一个课程表
  Future<int> addCourseList(CourseList courseList) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> courseListMap = {
      _columuName[1]: courseList.getSemester,
      _columuName[2]: courseList.getCurrentWeek,
      _columuName[3]: courseList.getWeekNum
    };

    int index = await _database.insert(_tableName, courseListMap);
    if (showLog) logger.i('$logTag添加CourseList: id = $index');

    await _database.close();
    return index;
  }

  // 给一个课程表添加课程
  Future<int> addCourseToCourseListByID(int id, Course course) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    CourseList? courseList = await getCourseListByID(id);

    if (courseList == null) {
      if (showLog) logger.w('${logTag}CourseList: id = $id不存在，无法添加课程');
      return 0;
    }

    CourseDB courseDB = CourseDB();

    int index = await courseDB.addCourse(course);

    // 在关系表里添加对应关系
    CourseListRelationDB courseListRelationDB = CourseListRelationDB();

    await courseListRelationDB.addCourseListRelation(CourseListRelation(id, index));

    await _database.close();
    return index;
  }

  // 获取全部数据
  Future<List<CourseList>> getAllCourseList() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    CourseListRelationDB courseListRelationDB = CourseListRelationDB();

    CourseDB courseDB = CourseDB();

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<CourseList> result = [];
    for (var item in resultMap) {
      CourseList courseList = CourseList(semester: item[_columuName[1]]);
      courseList.currentWeek = item[_columuName[2]];
      courseList.currentWeek = item[_columuName[3]];

      List<CourseListRelation> relations = await courseListRelationDB.getCourseListRelationByID(item[_columuName[0]]);
      for (var item in relations) {
        Course? course = await courseDB.getCourseByID(item.courseID);
        if (course == null) continue;
        courseList.addCourse(course);
      }

      result.add(courseList);
    }

    if (showLog) logger.i('$logTag获取全部CourseList共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<CourseList?> getCourseListByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<CourseList> result = [];

    for (var item in resultMap) {
      CourseList courseList = CourseList(semester: item[_columuName[1]]);
      courseList.weekNum = item[_columuName[3]];
      courseList.currentWeek = item[_columuName[2]];
      result.add(courseList);
    }
    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}CourseList: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取CourseList: id = $id');
    }

    // 继续获取课程表包含的课程
    CourseListRelationDB courseListRelationDB = CourseListRelationDB();

    List<CourseListRelation> relations = await courseListRelationDB.getCourseListRelationByID(id);
    CourseDB courseDB = CourseDB();

    for (var item in relations) {
      Course? course = await courseDB.getCourseByID(item.courseID);
      if (course == null) continue;
      result[0].addCourse(course);
    }

    return result[0];
  }

  // 根据id删除一条数据
  Future<int> deleteCourseListByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    CourseListRelationDB courseListRelationDB = CourseListRelationDB();

    CourseDB courseDB = CourseDB();

    List<CourseListRelation> relations = await courseListRelationDB.getCourseListRelationByID(index);
    for (var relation in relations) {
      await courseDB.deleteCourseByID(relation.courseID);
    }

    if (index == 0) {
      if (showLog) logger.w('${logTag}CourseList: id = $id不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除CourseList: id = $id');
    }
    return index;
  }

  // 清空数据库
  Future<void> clear() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    await _database.execute('DROP TABLE IF EXISTS $_tableName');
    await _database.execute(_sql);
    if (showLog) logger.i('$logTag数据库已清空');

    await _database.close();
  }

  // 数据库是否为空
  Future<bool> isEmpty() async {
    List<CourseList> result = await getAllCourseList();
    if (result.isEmpty) {
      return true;
    }
    else {
      return false;
    }
  }

  // 单例模式，确保全局只有一个数据库管理实例
  static final CourseListDB _instance = CourseListDB._internal();

  CourseListDB._internal();

  factory CourseListDB() {
    return _instance;
  }
}
