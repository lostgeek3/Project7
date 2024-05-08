export './timeInfo_db.dart';
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
const String logTag = '[Database]TimeInfoDB: ';

class TimeInfoDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'timeInfo.db';
  // 数据库表名
  final String _tableName = 'timeInfos';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = ['id', 'beginTime', 'endTime', 'cycle', 'currentCycle', 'cyclePeriod'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} INTEGER NOT NULL,'
    '${_columuName[4]} INTEGER NOT NULL,'
    '${_columuName[5]} INTEGER NOT NULL)';

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
  Future<int> addTimeInfo(TimeInfo timeInfo) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> timeInfoMap = {
      _columuName[1]: timeInfo.getBeginTime.toIso8601String(),
      _columuName[2]: timeInfo.getEndTime.toIso8601String(),
      _columuName[3]: timeInfo.getCycle,
      _columuName[4]: timeInfo.getCurrentCycle,
      _columuName[5]: timeInfo.getCyclePeriod.index
    };
    int index = await _database.insert(_tableName, timeInfoMap);
    logger.i('$logTag添加TimeInfo: id = $index');

    await _database.close();
    return index;
  }

  // 获取全部数据
  Future<List<TimeInfo>> getAllTimeInfo() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<TimeInfo> result = [];
    for (var item in resultMap) {
      result.add(TimeInfo(
        DateTime.parse(item[_columuName[1]]),
        DateTime.parse(item[_columuName[2]]),
        cycle: item[_columuName[3]],
        currentCycle: item[_columuName[4]],
        cyclePeriod: CyclePeriod.values[item[_columuName[5]]]
        ));
    }
    logger.i('$logTag获取全部TimeInfo共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<TimeInfo?> getTimeInfoByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<TimeInfo> result = [];
    for (var item in resultMap) {
      result.add(TimeInfo(
        DateTime.parse(item[_columuName[1]]),
        DateTime.parse(item[_columuName[2]]),
        cycle: item[_columuName[3]],
        currentCycle: item[_columuName[4]],
        cyclePeriod: CyclePeriod.values[item[_columuName[5]]]
        ));
    }
    await _database.close();
    if (result.isEmpty) {
      logger.w('${logTag}TimeInfo: id = $id不存在，无法获取');
      return null;
    }
    else {
      logger.i('$logTag获取TimeInfo: id = $id');
      return result[0];
    }
  }

  // 根据id删除一条数据
  Future<int> deleteTimeInfoByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    
    await _database.close();

    if (index == 0) {
      logger.w('${logTag}TimeInfo: id = $id不存在，无法删除');
    }
    else {
      logger.i('$logTag删除TimeInfo: id = $id');
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

  static final TimeInfoDB _instance = TimeInfoDB._internal();

  TimeInfoDB._internal();

  factory TimeInfoDB() {
    return _instance;
  }
}
