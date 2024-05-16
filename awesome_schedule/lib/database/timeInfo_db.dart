export './timeInfo_db.dart';
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
const String logTag = '[Database]TimeInfoDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = false;

class CourseTimeInfoDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'courseTimeInfo.db';
  // 数据库表名
  final String _tableName = 'courseTimeInfos';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = [
      'id',
      'startHour',
      'startMinute',
      'endHour',
      'endMinute',
      'endWeek',
      'weekListStr',
      'weekday',
      'startSection',
      'endSection'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} INTEGER NOT NULL,'
    '${_columuName[2]} INTEGER NOT NULL,'
    '${_columuName[3]} INTEGER NOT NULL,'
    '${_columuName[4]} INTEGER NOT NULL,'
    '${_columuName[5]} INTEGER NOT NULL,'
    '${_columuName[6]} TEXT NOT NULL,'
    '${_columuName[7]} INTEGER NOT NULL,'
    '${_columuName[8]} INTEGER NOT NULL,'
    '${_columuName[9]} INTEGER NOT NULL)';

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
  Future<int> addCourseTimeInfo(CourseTimeInfo timeInfo) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> timeInfoMap = {
      _columuName[1]: timeInfo.getStartHour,
      _columuName[2]: timeInfo.getStartMinute,
      _columuName[3]: timeInfo.getEndHour,
      _columuName[4]: timeInfo.getEndMinute,
      _columuName[5]: timeInfo.getEndWeek,
      _columuName[6]: timeInfo.getWeekListStr(),
      _columuName[7]: timeInfo.getWeekday,
      _columuName[8]: timeInfo.getStartSection,
      _columuName[9]: timeInfo.getEndSection
    };
    int index = await _database.insert(_tableName, timeInfoMap);
    if (showLog) logger.i('$logTag添加TimeInfo: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<CourseTimeInfo>> getAllCourseTimeInfo() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<CourseTimeInfo> result = [];
    for (var item in resultMap) {
      CourseTimeInfo courseTimeInfo = CourseTimeInfo(
        item[_columuName[1]],
        item[_columuName[2]],
        item[_columuName[3]],
        item[_columuName[4]],
        endWeek: item[_columuName[5]],
        weeks: readWeekListStr(item[_columuName[6]]),
        weekday: item[_columuName[7]],
        startSection: item[_columuName[8]],
        endSection: item[_columuName[9]]);
      result.add(courseTimeInfo);
    }
    if (showLog) logger.i('$logTag获取全部TimeInfo共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<CourseTimeInfo?> getCourseTimeInfoByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<CourseTimeInfo> result = [];
    for (var item in resultMap) {
      CourseTimeInfo courseTimeInfo = CourseTimeInfo(
        item[_columuName[1]],
        item[_columuName[2]],
        item[_columuName[3]],
        item[_columuName[4]],
        endWeek: item[_columuName[5]],
        weeks: readWeekListStr(item[_columuName[6]]),
        weekday: item[_columuName[7]],
        startSection: item[_columuName[8]],
        endSection: item[_columuName[9]]);
      result.add(courseTimeInfo);
    }
    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}CourseTimeInfo: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取CourseTimeInfo: id = $id');
      return result[0];
    }
  }

  // 根据id删除一条数据
  Future<int> deleteCourseTimeInfoByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}CourseTimeInfo: id = $id不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除CourseTimeInfo: id = $id');
    }

    if (printDB) {
      await printDatabase();
    }
    
    if (index == 0) return index;
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
    List<CourseTimeInfo> result = await getAllCourseTimeInfo();
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

  static final CourseTimeInfoDB _instance = CourseTimeInfoDB._internal();

  CourseTimeInfoDB._internal();

  factory CourseTimeInfoDB() {
    return _instance;
  }
}
