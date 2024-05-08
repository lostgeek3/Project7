export './course_db.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled3/database/timeInfo_db.dart';
import '../models/course.dart';
import 'package:untitled3/models/timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0
  )
);
const String logTag = '[Database]CourseDB: ';

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
    _columuName = ['id', 'courseID', 'name', 'timeInfoID', 'location', 'description', 'teacher'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} INTEGER NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} INTEGER NOT NULL,'
    '${_columuName[4]} TEXT NOT NULL,'
    '${_columuName[5]} TEXT NOT NULL,'
    '${_columuName[6]} TEXT NOT NULL)';

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
      logger.i('$logTag数据库初始化成功');
    }
    catch (error) {
      logger.e('$logTag数据库初始化失败。$error');
    }
  }

  Future<int> addCourse(Course course) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    // 先储存时间信息，并获取其id
    TimeInfoDB timeInfoDB = TimeInfoDB();
    await timeInfoDB.initDatabase();
    int timeInfoID = await timeInfoDB.addTimeInfo(course.getTimeInfo);

    Map<String, Object?> courseMap = {
      _columuName[1]: course.getCourseID,
      _columuName[2]: course.getName,
      _columuName[3]: timeInfoID,
      _columuName[4]: course.getLocation,
      _columuName[5]: course.getDescription,
      _columuName[6]: course.getTeacher
    };

    int index = await _database.insert(_tableName, courseMap);
    logger.i('$logTag添加Course: id = $index');

    await _database.close();
    return index;
  }

  // 获取全部数据
  Future<List<Course>> getAllCourse() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    TimeInfoDB timeInfoDB = TimeInfoDB();
    await timeInfoDB.initDatabase();

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<Course> result = [];
    for (var item in resultMap) {
      TimeInfo? timeInfo = await timeInfoDB.getTimeInfoByID(item[_columuName[3]]);
      timeInfo ??= TimeInfo(DateTime.now(), DateTime.now());
      result.add(Course(
        item[_columuName[2]],
        timeInfo,
        courseID: item[_columuName[1]],
        location: item[_columuName[4]],
        description: item[_columuName[5]],
        teacher: item[_columuName[6]]
        ));
    }
    logger.i('$logTag获取全部Course共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<Course?> getTimeInfoByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    TimeInfoDB timeInfoDB = TimeInfoDB();
    await timeInfoDB.initDatabase();

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<Course> result = [];

    for (var item in resultMap) {
      TimeInfo? timeInfo = await timeInfoDB.getTimeInfoByID(item[_columuName[3]]);
      timeInfo ??= TimeInfo(DateTime.now(), DateTime.now());
      result.add(Course(
        item[_columuName[2]],
        timeInfo,
        courseID: item[_columuName[1]],
        location: item[_columuName[4]],
        description: item[_columuName[5]],
        teacher: item[_columuName[6]]
        ));
    }
    await _database.close();
    if (result.isEmpty) {
      logger.w('${logTag}Course: id = $id不存在，无法获取');
      return null;
    }
    else {
      logger.i('$logTag获取Course: id = $id');
      return result[0];
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
      logger.w('${logTag}Course: id = $id不存在，无法删除');
    }
    else {
      logger.i('$logTag删除Course: id = $id');
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
    logger.i('$logTag数据库已清空');

    await _database.close();
  }

  // 单例模式，确保全局只有一个数据库管理实例
  static final CourseDB _instance = CourseDB._internal();

  CourseDB._internal();

  factory CourseDB() {
    return _instance;
  }
}
