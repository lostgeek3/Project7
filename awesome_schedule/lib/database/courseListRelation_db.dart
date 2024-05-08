export './courseListRelation_db.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled3/models/timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[Database]CourseListRelationDB: ';

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
      logger.i('$logTag数据库初始化成功');
    }
    catch (error) {
      logger.e('$logTag数据库初始化失败。$error');
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
    logger.i('$logTag添加CourseListRelation: id = $index');

    await _database.close();
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
    logger.i('$logTag获取全部CourseListRelation共${result.length}条');

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
      logger.w('${logTag}CourseListRelation: courseList_id = $courseListID不存在，无法获取');
    }
    else {
      logger.i('$logTag获取CourseListRelation: courseList_id = $courseListID共${result.length}条');
    }

    return result;
  }

  // 根据课程表id删除一个课程表的所有数据
  Future<int> deleteTimeInfoByID(int courseListID) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'courseList_id = ?',
      whereArgs: [courseListID]);
    
    await _database.close();

    if (index == 0) {
      logger.w('${logTag}CourseListRelation: courseList_id = $courseListID不存在，无法删除');
    }
    else {
      logger.i('$logTag删除CourseListRelation: courseList_id = $courseListID');
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

  static final CourseListRelationDB _instance = CourseListRelationDB._internal();

  CourseListRelationDB._internal();

  factory CourseListRelationDB() {
    return _instance;
  }
}
