export './course_db.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_schedule/database/course_db.dart';
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
// 是否打印数据库
bool printDB = true;

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

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取一个课程表的id
  Future<int> getCourseListID(CourseList courseList) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      columns: [_columuName[1]],
      where: '${_columuName[1]} = ?',
      whereArgs: [courseList.getSemester],
      limit: 1);
    List<CourseList> result = [];

    await _database.close();

    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}CourseList: semester = ${courseList.getSemester()}不存在，无法获取');
      return 0;
    }
    else {
      int id = resultMap[0][_columuName[0]];
      if (showLog) logger.i('$logTag获取CourseList: id = $id');
      return id;
    }
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

    int index = await courseDB.addCourse(course, id);

    await _database.close();
    return index;
  }

  // 获取全部数据
  Future<List<CourseList>> getAllCourseList() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    CourseDB courseDB = CourseDB();

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<CourseList> result = [];
    for (var item in resultMap) {
      CourseList courseList = CourseList(semester: item[_columuName[1]]);
      courseList.weekNum = item[_columuName[3]];
      courseList.currentWeek = item[_columuName[2]];
      courseList.id = item[_columuName[0]];
      List<Course> courses = await courseDB.getCoursesByCourseListId(item[_columuName[0]]);
      
      for (var course in courses) {
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
    CourseDB courseDB = CourseDB();
    for (var item in resultMap) {
      CourseList courseList = CourseList(semester: item[_columuName[1]]);
      courseList.weekNum = item[_columuName[3]];
      courseList.currentWeek = item[_columuName[2]];
      courseList.id = item[_columuName[0]];
      List<Course> courses = await courseDB.getCoursesByCourseListId(item[_columuName[0]]);
      for (var course in courses) {
        courseList.addCourse(course);
      }
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

    return result[0];
  }

  // 根据课程表id和课程名删除课程，返回值为课程id
  Future<int> deleteCourseByNameAndCourseListId(String name, int courseListId) async {
    CourseDB courseDB = CourseDB();
    return await courseDB.deleteCourseByNameAndCourseListId(name, courseListId);
  }

  // 根据id删除一条数据
  Future<void> deleteCourseListByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    // 先获取课程表
    CourseList? courseList = await getCourseListByID(id);
    if (courseList == null) {
      if (showLog) logger.w('${logTag}CourseList: id = $id不存在，无法删除');
      return;
    }

    // 删除课程
    CourseDB courseDB = CourseDB();
    courseDB.deleteCoursesByCourseListId(id);
    // 删除课程表
    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (showLog) logger.i('$logTag删除CourseList: id = $id');

    if (printDB) {
      await printDatabase();
    }
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

  // 打印数据库
  Future<void> printDatabase() async {
    if (await isEmpty()) {
      logger.i('$logTag数据库$_tableName为空');
      return;
    }
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    logger.i('$logTag数据库$_tableName全部数据：');

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);

    for (var item in resultMap) {
      String print = logTag;
      for (int i = 0; i < _columuName.length; i++) {
        print += '${_columuName[i]}:${item[_columuName[i]]}\t';
      }
      logger.i(print);
    }

    await _database.close();
  }

  // 单例模式，确保全局只有一个数据库管理实例
  static final CourseListDB _instance = CourseListDB._internal();

  CourseListDB._internal();

  factory CourseListDB() {
    return _instance;
  }
}
