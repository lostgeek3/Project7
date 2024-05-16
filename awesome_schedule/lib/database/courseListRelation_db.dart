export './courseListRelation_db.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_schedule/models/timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[Database]CourseListRelationDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = false;

// 表示课程表和课程之间的包含关系
class CourseListRelation {
  final int courseListID;
  final int courseID;

  CourseListRelation(this.courseListID, this.courseID);
}

class CourseListRelationDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'courseListRelation.db';
  // 数据库表名
  final String _tableName = 'courseListRelations';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = ['id', 'courseList_id', 'course_id'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY NOT NULL,'
    '${_columuName[1]} INTEGER NOT NULL,'
    '${_columuName[2]} INTEGER NOT NULL)';

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

  // 添加一条数据
  Future<int> addCourseListRelation(CourseListRelation courseListRelation) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, dynamic> courseListRelationMap = {
      _columuName[1]: courseListRelation.courseListID,
      _columuName[2]: courseListRelation.courseID
    };
    int index = await _database.insert(_tableName, courseListRelationMap);
    if (showLog) logger.i('$logTag添加CourseListRelation: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<CourseListRelation>> getAllCourseListRelation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<CourseListRelation> result = [];
    for (var item in resultMap) {
      result.add(CourseListRelation(item[_columuName[1]], item[_columuName[2]]));
    }
    if (showLog) logger.i('$logTag获取全部CourseListRelation共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据课程表id获取该课程表所有数据
  Future<List<CourseListRelation>> getCourseListRelationByID(int courseListID) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'courseList_id = ?',
      whereArgs: [courseListID]);
    List<CourseListRelation> result = [];
    for (var item in resultMap) {
      result.add(CourseListRelation(item[_columuName[1]], item[_columuName[2]]));
    }
    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}CourseListRelation: courseList_id = $courseListID不存在，无法获取');
    }
    else {
      if (showLog) logger.i('$logTag获取CourseListRelation: courseList_id = $courseListID共${result.length}条');
    }

    return result;
  }

  // 根据课程表id删除一个课程表的所有数据
  Future<int> deleteCourseListRelationByID(int courseListID) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'courseList_id = ?',
      whereArgs: [courseListID]);
    
    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}CourseListRelation: courseList_id = $courseListID不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除CourseListRelation: courseList_id = $courseListID');
    }

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 根据课程表关联信息删除一条数据
  Future<int> deleteCourseListRelationByRelation(CourseListRelation courseListRelation) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: '${_columuName[1]} = ? AND ${_columuName[2]} = ?',
      whereArgs: [courseListRelation.courseListID, courseListRelation.courseID]);
    
    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}CourseListRelation: courseList_id = ${courseListRelation.courseListID}, course_id = ${courseListRelation.courseID}不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除CourseListRelation: courseList_id = ${courseListRelation.courseListID}, course_id = ${courseListRelation.courseID}');
    }

    if (printDB) {
      await printDatabase();
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
    List<CourseListRelation> result = await getAllCourseListRelation();
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

  static final CourseListRelationDB _instance = CourseListRelationDB._internal();

  CourseListRelationDB._internal();

  factory CourseListRelationDB() {
    return _instance;
  }
}
