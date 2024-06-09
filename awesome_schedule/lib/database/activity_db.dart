export './activity_db.dart';
import 'dart:async';
import 'package:awesome_schedule/models/activity.dart';
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
const String logTag = '[Database]ActivityDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = true;

class ActivityDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'activity.db';
  // 数据库表名
  final String _tableName = 'activities';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = [
      'id',
      'name',
      'startTime',
      'endTime',
      'location',
      'description',
      'activityType'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} TEXT NOT NULL,'
    '${_columuName[4]} TEXT NOT NULL,'
    '${_columuName[5]} TEXT NOT NULL,'
    '${_columuName[6]} INTEGER NOT NULL)';

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

  // 添加活动
  Future<int> addActivity(Activity activity) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> timeInfoMap = {
      _columuName[1]: activity.getName,
      _columuName[2]: activity.getStartTime.toIso8601String(),
      _columuName[3]: activity.getEndTime.toIso8601String(),
      _columuName[4]: activity.getLocation,
      _columuName[5]: activity.getDescription,
      _columuName[6]: activity.getActivityType.index
    };
    int index = await _database.insert(_tableName, timeInfoMap);
    if (showLog) logger.i('$logTag添加Activity: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<Activity>> getAllActivity() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<Activity> result = [];
    for (var item in resultMap) {
      Activity activity = Activity(
        item[_columuName[1]],
        DateTime.parse(item[_columuName[2]]),
        DateTime.parse(item[_columuName[3]]),
        location: item[_columuName[4]],
        description: item[_columuName[5]],
        activityType: ActivityType.values[item[_columuName[6]]]
      );
      activity.id = item[_columuName[0]];
      result.add(activity);
    }
    if (showLog) logger.i('$logTag获取全部Activity共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<Activity?> getActivityByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
    List<Activity> result = [];
    for (var item in resultMap) {
      Activity activity = Activity(
        item[_columuName[1]],
        DateTime.parse(item[_columuName[2]]),
        DateTime.parse(item[_columuName[3]]),
        location: item[_columuName[4]],
        description: item[_columuName[5]],
        activityType: ActivityType.values[item[_columuName[6]]]
      );
      activity.id = item[_columuName[0]];
      result.add(activity);
    }

    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}Activity: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取Activity: id = $id');
      return result[0];
    }
  }

  // 根据id删除一条数据
  Future<int> deleteActivityByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}Activity: id = $id不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除Activity: id = $id');
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
    List<Activity> result = await getAllActivity();
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

  static final ActivityDB _instance = ActivityDB._internal();

  ActivityDB._internal();

  factory ActivityDB() {
    return _instance;
  }
}
