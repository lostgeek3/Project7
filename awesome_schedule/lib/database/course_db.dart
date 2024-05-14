export './course_db.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_schedule/database/courseTimeInfoRelation_db.dart';
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
    _columuName = ['id', 'courseID', 'name', 'location', 'description', 'teacher'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} INTEGER NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} TEXT NOT NULL,'
    '${_columuName[4]} TEXT NOT NULL,'
    '${_columuName[5]} TEXT NOT NULL)';

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

  Future<int> addCourse(Course course) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> courseMap = {
      _columuName[1]: course.getCourseID,
      _columuName[2]: course.getName,
      _columuName[3]: course.getLocation,
      _columuName[4]: course.getDescription,
      _columuName[5]: course.getTeacher
    };

    int index = await _database.insert(_tableName, courseMap);

    // 储存时间信息，并获取其id，储存课程与时间关联表信息
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();

    List<CourseTimeInfo> courseTimeInfo = course.getCourseTimeInfo;
    
    for (var item in courseTimeInfo) {
      int courseTimeInfoID = await timeInfoDB.addCourseTimeInfo(item);
      courseTimeInfoRelationDB.addCourseTimeInfoRelation(CourseTimeInfoRelation(index, courseTimeInfoID));
    }

    if (showLog) logger.i('$logTag添加Course: id = $index');

    await _database.close();
    return index;
  }

  // 获取全部数据
  Future<List<Course>> getAllCourse() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<Course> result = [];
    for (var item in resultMap) {
      // 根据课程id获取关联表信息
      List<CourseTimeInfoRelation> courseTimeInfoRelations = await courseTimeInfoRelationDB.getCourseTimeInfoRelationByID(item[_columuName[0]]);
      List<CourseTimeInfo> courseTimeInfos = [];

      for (var relation in courseTimeInfoRelations) {
        CourseTimeInfo? courseTimeInfo = await timeInfoDB.getCourseTimeInfoByID(relation.courseTimeInfoID);
        if (courseTimeInfo == null)  continue;
        courseTimeInfos.add(courseTimeInfo);
      }

      result.add(Course(
        item[_columuName[2]],
        courseTimeInfos,
        courseID: item[_columuName[1]],
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        teacher: item[_columuName[5]]
        ));
    }
    if (showLog) logger.i('$logTag获取全部Course共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<Course?> getCourseByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<Course> result = [];

    for (var item in resultMap) {
      // 根据课程id获取关联表信息
      List<CourseTimeInfoRelation> courseTimeInfoRelations = await courseTimeInfoRelationDB.getCourseTimeInfoRelationByID(item[_columuName[0]]);
      List<CourseTimeInfo> courseTimeInfos = [];

      for (var relation in courseTimeInfoRelations) {
        CourseTimeInfo? courseTimeInfo = await timeInfoDB.getCourseTimeInfoByID(relation.courseTimeInfoID);
        if (courseTimeInfo == null)  continue;
        courseTimeInfos.add(courseTimeInfo);
      }

      result.add(Course(
        item[_columuName[2]],
        courseTimeInfos,
        courseID: item[_columuName[1]],
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        teacher: item[_columuName[5]]
        ));
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
    }
    else {
      if (showLog) logger.i('$logTag删除Course: id = $id');
    }

    // 删除关联表中对应的数据
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();

    List<CourseTimeInfoRelation> relations = await courseTimeInfoRelationDB.getCourseTimeInfoRelationByID(index);
    for (var relation in relations) {
      await timeInfoDB.deleteCourseTimeInfoByID(relation.courseTimeInfoID);
    }
    return index;
  }

  // 根据课程名删除一条数据
  Future<int> deleteCourseByName(String name) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: '${_columuName[2]} = ?',
      whereArgs: [name]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}Course: name = $name不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除Course: name = $name');
    }

    // 删除关联表中对应的数据
    CourseTimeInfoDB timeInfoDB = CourseTimeInfoDB();

    CourseTimeInfoRelationDB courseTimeInfoRelationDB = CourseTimeInfoRelationDB();

    List<CourseTimeInfoRelation> relations = await courseTimeInfoRelationDB.getCourseTimeInfoRelationByID(index);
    for (var relation in relations) {
      await timeInfoDB.deleteCourseTimeInfoByID(relation.courseTimeInfoID);
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
    List<Course> result = await getAllCourse();
    if (result.isEmpty) {
      return true;
    }
    else {
      return false;
    }
  }

  // 单例模式，确保全局只有一个数据库管理实例
  static final CourseDB _instance = CourseDB._internal();

  CourseDB._internal();

  factory CourseDB() {
    return _instance;
  }
}
