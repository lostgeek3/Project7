export './noteImage_db.dart';
import 'dart:async';
import 'package:awesome_schedule/models/activity.dart';
import 'package:awesome_schedule/models/noteImage.dart';
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
const String logTag = '[Database]NoteImageDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = true;

class NoteImageDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'noteImage.db';
  // 数据库表名
  final String _tableName = 'noteImages';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = [
      'id',
      'name',
      'image',
      'noteId'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} BLOB NOT NULL,'
    '${_columuName[3]} INTEGER NOT NULL)';

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

  // 添加图片
  Future<int> addNoteImage(NoteImage noteImage) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> map = {
      _columuName[1]: noteImage.getName,
      _columuName[2]: noteImage.getImage,
      _columuName[3]: noteImage.noteId,
    };
    int index = await _database.insert(_tableName, map);
    if (showLog) logger.i('$logTag添加NoteImage: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<NoteImage>> getAllNoteImage() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<NoteImage> result = [];
    for (var item in resultMap) {
      NoteImage noteImage = NoteImage(item[_columuName[1]], item[_columuName[2]]);
      noteImage.id = item[_columuName[0]];
      noteImage.noteId = item[_columuName[3]];
      result.add(noteImage);
    }
    if (showLog) logger.i('$logTag获取全部NoteImage共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据noteId获取图片
  Future<List<NoteImage>> getNoteImagesByNoteId(int noteId) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'noteId = ?',
      whereArgs: [noteId]);
    List<NoteImage> result = [];
    for (var item in resultMap) {
      NoteImage noteImage = NoteImage(item[_columuName[1]], item[_columuName[2]]);
      noteImage.id = item[_columuName[0]];
      noteImage.noteId = item[_columuName[3]];
      result.add(noteImage);
    }
    if (showLog) logger.i('$logTag获取NoteImage共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<NoteImage?> getNoteImageByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
    List<NoteImage> result = [];
    for (var item in resultMap) {
      NoteImage noteImage = NoteImage(item[_columuName[1]], item[_columuName[2]]);
      noteImage.id = item[_columuName[0]];
      noteImage.noteId = item[_columuName[3]];
      result.add(noteImage);
    }

    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}NoteImage: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取NoteImage: id = $id');
      return result[0];
    }
  }

  // 根据id删除一条数据
  Future<int> deleteNoteImageByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}NoteImage: id = $id不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除NoteImage: id = $id');
    }

    if (printDB) {
      await printDatabase();
    }
    
    if (index == 0) return index;
    return id;
  }

  // 根据noteId删除所有图片数据
  Future<void> deleteNoteImagesByNoteId(int noteId) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'noteId = ?',
      whereArgs: [noteId]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}NoteImage: noteId = $noteId不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除NoteImages: noteId = $noteId');
    }

    if (printDB) {
      await printDatabase();
    }
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
    List<NoteImage> result = await getAllNoteImage();
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

  static final NoteImageDB _instance = NoteImageDB._internal();

  NoteImageDB._internal();

  factory NoteImageDB() {
    return _instance;
  }
}
