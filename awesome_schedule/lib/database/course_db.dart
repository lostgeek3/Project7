export './course_db.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_schedule/database/timeInfo_db.dart';
import '../models/course.dart';
import 'package:awesome_schedule/models/timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0
  )
);
const String logTag = '[Database]CourseDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = true;

class CourseDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'course.db';
  // 数据库表名
  final String _tableName = 'courses';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  Future<void> initDatabase() async {
    _columuName = ['id', 'courseID', 'name', 'location', 'description', 'teacher', 'courseListId'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} TEXT NOT NULL,'
    '${_columuName[4]} TEXT NOT NULL,'
    '${_columuName[5]} TEXT NOT NULL,'
    '${_columuName[6]} INTEGER)';

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

  // 给课程表添加一个课程
  Future<int> addCourse(Course course, int courseListId) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> courseMap = {
      _columuName[1]: course.getCourseID,
      _columuName[2]: course.getName,
      _columuName[3]: course.getLocation,
      _columuName[4]: course.getDescription,
      _columuName[5]: course.getTeacher,
      _columuName[6]: courseListId
    };

    int index = await _database.insert(_tableName, courseMap);

    // 储存时间信息，并获取其id，储存课程与时间关联表信息
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    List<CourseTimeInfo> courseTimeInfo = course.getTimeInfo;
    
    for (var item in courseTimeInfo) {
      int courseTimeInfoID = await timeInfoDB.addCourseTimeInfo(item, index);
    }

    if (showLog) logger.i('$logTag添加Course: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<Course>> getAllCourse() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<Course> result = [];
    for (var item in resultMap) {
      // 根据课程id获取时间信息
      List<CourseTimeInfo> courseTimeInfos = await timeInfoDB.getCourseTimeInfosByCourseId(item[_columuName[0]]);
      Course course = Course(
        item[_columuName[2]],
        courseTimeInfos,
        courseID: item[_columuName[1]],
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        teacher: item[_columuName[5]]
        );
        course.id = item[_columuName[0]];
        course.courseListId = item[_columuName[6]];
      result.add(course);
    }
    if (showLog) logger.i('$logTag获取全部Course共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据课程表id获取数据
  Future<List<Course>> getCoursesByCourseListId(int courseListId) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'courseListId = ?',
      whereArgs: [courseListId]);
    List<Course> result = [];
    for (var item in resultMap) {
      // 根据课程id获取时间信息
      List<CourseTimeInfo> courseTimeInfos = await timeInfoDB.getCourseTimeInfosByCourseId(item[_columuName[0]]);
      Course course = Course(
        item[_columuName[2]],
        courseTimeInfos,
        courseID: item[_columuName[1]],
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        teacher: item[_columuName[5]]
        );
        course.id = item[_columuName[0]];
        course.courseListId = item[_columuName[6]];
      result.add(course);
    }
    if (showLog) logger.i('$logTag获取Courses共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<Course?> getCourseByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<Course> result = [];

    for (var item in resultMap) {
      // 根据课程id获取时间信息
      List<CourseTimeInfo> courseTimeInfos = await timeInfoDB.getCourseTimeInfosByCourseId(item[_columuName[6]]);
      Course course = Course(
        item[_columuName[2]],
        courseTimeInfos,
        courseID: item[_columuName[1]],
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        teacher: item[_columuName[5]]
        );
        course.id = item[_columuName[0]];
        course.courseListId = item[_columuName[6]];
      result.add(course);
    }
    
    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}Course: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取Course: id = $id');
      return result[0];
    }
  }

  // 根据课程表id删除
  Future<void> deleteCoursesByCourseListId(int courseListId) async {
    // 先获取相关课程
    List<Course> courses = await getCoursesByCourseListId(courseListId);
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();
    for (var item in courses) {
      // 删除时间信息和课程
      timeInfoDB.deleteCourseTimeInfosByCourseId(item.id);
      deleteCourseByID(item.id);
    }
  }

  // 根据id删除一条数据
  Future<int> deleteCourseByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}Course: id = $id不存在，无法删除');
      return 0;
    }
    else {
      if (showLog) logger.i('$logTag删除Course: id = $id');
    }

    // 删除时间表中对应的数据
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();
    timeInfoDB.deleteCourseTimeInfosByCourseId(id);

    if (printDB) {
      await printDatabase();
    }

    return id;
  }

  // 根据课程名和课程表id获取id
  Future<int> getIDByName(String name, int courseListId) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: '${_columuName[2]} = ? AND ${_columuName[6]} = ?',
      whereArgs: [name, courseListId],
      limit: 1);

    await _database.close();

    if (resultMap.isEmpty) {
      if (showLog) logger.w('${logTag}Course: name = $name不存在，无法获取id');
      return 0;
    }
    else {
      int id = resultMap[0][_columuName[0]];
      if (showLog) logger.i('$logTag获取Course: id = $id');
      return id;
    }
  }

  // 根据课程名和课程表id删除一条数据
  Future<int> deleteCourseByNameAndCourseListId(String name, int courseListId) async {
    int id = await getIDByName(name, courseListId);

    await deleteCourseByID(id);

    return id;
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
    List<Course> result = await getAllCourse();
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
  static final CourseDB _instance = CourseDB._internal();

  CourseDB._internal();

  factory CourseDB() {
    return _instance;
  }
}
