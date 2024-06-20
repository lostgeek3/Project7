export './task_db.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/course.dart';
import '../models/task.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0
  )
);
const String logTag = '[Database]TaskDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = false;

class TaskDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'task.db';
  // 数据库表名
  final String _tableName = 'tasks';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  Future<void> initDatabase() async {
    _columuName = ['id', 'name', 'deadline', 'location', 'description', 'taskType', 'finished', 'courseId'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} TEXT NOT NULL,'
    '${_columuName[4]} TEXT NOT NULL,'
    '${_columuName[5]} INTEGER NOT NULL,'
    '${_columuName[6]} BIT,'
    '${_columuName[7]} INTEGER)';

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

  // 给课程添加一个任务
  Future<int> addTask(Task task, int courseId) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> courseMap = {
      _columuName[1]: task.getName,
      _columuName[2]: task.getDeadline.toIso8601String(),
      _columuName[3]: task.getLocation,
      _columuName[4]: task.getDescription,
      _columuName[5]: task.getTaskType.index,
      _columuName[6]: task.getFinished,
      _columuName[7]: courseId
    };

    int index = await _database.insert(_tableName, courseMap);
    task.courseId = courseId;
    task.id = index;

    if (showLog) logger.i('$logTag添加Task: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<Task>> getAllTask() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<Task> result = [];
    for (var item in resultMap) {
      Task task = Task(
        item[_columuName[1]],
        DateTime.parse(item[_columuName[2]]),
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        taskType: TaskType.values[item[_columuName[5]]]
      );
      task.id = item[_columuName[0]];
      if (item[_columuName[6]] > 0) task.setFinished();
      task.courseId = item[_columuName[7]];
      result.add(task);
    }
    if (showLog) logger.i('$logTag获取全部Task共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据课程id获取数据
  Future<List<Task>> getTasksByCourseId(int courseId) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'courseId = ?',
      whereArgs: [courseId]);
    List<Task> result = [];
    for (var item in resultMap) {
      Task task = Task(
        item[_columuName[1]],
        DateTime.parse(item[_columuName[2]]),
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        taskType: TaskType.values[item[_columuName[5]]]
      );
      task.id = item[_columuName[0]];
      if (item[_columuName[6]] > 0) task.setFinished();
      task.courseId = item[_columuName[7]];
      result.add(task);
    }
    if (showLog) logger.i('$logTag获取Tasks共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<Task?> getTaskByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);
    List<Task> result = [];

    for (var item in resultMap) {
      Task task = Task(
        item[_columuName[1]],
        DateTime.parse(item[_columuName[2]]),
        location: item[_columuName[3]],
        description: item[_columuName[4]],
        taskType: TaskType.values[item[_columuName[5]]]
      );
      task.id = item[_columuName[0]];
      if (item[_columuName[6]]) task.setFinished();
      task.courseId = item[_columuName[7]];
      result.add(task);
    }
    
    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}Task: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取Task: id = $id');
      return result[0];
    }
  }

  // 设置完成情况
  Future<void> updateFinished(Task task) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> courseMap = {
      _columuName[6]: task.getFinished,
    };

    int index = await _database.update(
      _tableName, 
      courseMap, 
      where: 'id = ?',
      whereArgs: [task.id]);

    await _database.close();

    if (printDB) {
      await printDatabase();
    }
  }

  // 根据课程id删除
  Future<void> deleteTasksByCourseId(int courseId) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'courseId = ?',
      whereArgs: [courseId]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}Task: courseId = $courseId不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除Tasks: courseId = $courseId');
    }

    if (printDB) {
      await printDatabase();
    }
  }

  // 根据id删除一条数据
  Future<int> deleteTaskByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}Task: id = $id不存在，无法删除');
      return 0;
    }
    else {
      if (showLog) logger.i('$logTag删除Task: id = $id');
    }

    if (printDB) {
      await printDatabase();
    }

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
    List<Task> result = await getAllTask();
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
  static final TaskDB _instance = TaskDB._internal();

  TaskDB._internal();

  factory TaskDB() {
    return _instance;
  }
}
