export './courseListRelation_db.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:awesome_schedule/database/courseListRelation_db.dart';
import 'package:awesome_schedule/models/timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[Database]CourseTimeInfoRelationDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = false;

// 表示课程和课程时间信息之间的包含关系
class CourseTimeInfoRelation {
  final int courseID;
  final int courseTimeInfoID;

  CourseTimeInfoRelation(this.courseID, this.courseTimeInfoID);
}

class CourseTimeInfoRelationDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'courseTimeInfoRelation.db';
  // 数据库表名
  final String _tableName = 'courseTimeInfoRelations';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = ['id', 'course_id', 'courseTimeInfo_id'];

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
  Future<int> addCourseTimeInfoRelation(CourseTimeInfoRelation courseTimeInfoRelation) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, dynamic> courseTimeInfoRelationMap = {
      _columuName[1]: courseTimeInfoRelation.courseID,
      _columuName[2]: courseTimeInfoRelation.courseTimeInfoID
    };
    int index = await _database.insert(_tableName, courseTimeInfoRelationMap);
    if (showLog) logger.i('$logTag添加CourseTimeInfoRelation: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<CourseTimeInfoRelation>> getAllCourseTimeInfoRelation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<CourseTimeInfoRelation> result = [];
    for (var item in resultMap) {
      result.add(CourseTimeInfoRelation(item[_columuName[1]], item[_columuName[2]]));
    }
    if (showLog) logger.i('$logTag获取全部CourseTimeInfoRelation共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据课程id获取该课程所有时间数据
  Future<List<CourseTimeInfoRelation>> getCourseTimeInfoRelationByID(int courseID) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'course_id = ?',
      whereArgs: [courseID]);
    List<CourseTimeInfoRelation> result = [];
    for (var item in resultMap) {
      result.add(CourseTimeInfoRelation(item[_columuName[1]], item[_columuName[2]]));
    }
    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}CourseTimeInfoRelation: course_id = $courseID不存在，无法获取');
    }
    else {
      if (showLog) logger.i('$logTag获取CourseTimeInfoRelation: course_id = $courseID共${result.length}条');
    }

    return result;
  }

  // 根据课程id删除一个课程的所有关联数据
  Future<int> deleteTimeInfoRelationByID(int courseID) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'course_id = ?',
      whereArgs: [courseID]);
    
    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}CourseTimeInfoRelation: course_id = $courseID不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除CourseTimeInfoRelation: course_id = $courseID');
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
    List<CourseTimeInfoRelation> result = await getAllCourseTimeInfoRelation();
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

  static final CourseTimeInfoRelationDB _instance = CourseTimeInfoRelationDB._internal();

  CourseTimeInfoRelationDB._internal();

  factory CourseTimeInfoRelationDB() {
    return _instance;
  }
}
