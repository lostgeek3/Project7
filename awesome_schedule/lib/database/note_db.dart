export './note_db.dart';
import 'dart:async';
import 'package:awesome_schedule/database/noteImage_db.dart';
import 'package:awesome_schedule/models/activity.dart';
import 'package:awesome_schedule/models/note.dart';
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
const String logTag = '[Database]NoteDB: ';
// 是否显示日志
bool showLog = false;
// 是否打印数据库
bool printDB = true;

class NoteDB {
  // 数据库实例
  late Database _database;
  // 数据库文件名
  final String _databaseName = 'note.db';
  // 数据库表名
  final String _tableName = 'notes';
  // 列名称
  late List<String> _columuName;
  // SQL
  late String _sql;

  // 初始化
  Future<void> initDatabase() async {
    _columuName = [
      'id',
      'title',
      'content',
      'noteType',
      'updateTime',
      'courseId'];

    _sql = 'CREATE TABLE IF NOT EXISTS $_tableName ('
    '${_columuName[0]} INTEGER PRIMARY KEY AUTOINCREMENT,'
    '${_columuName[1]} TEXT NOT NULL,'
    '${_columuName[2]} TEXT NOT NULL,'
    '${_columuName[3]} INTEGER NOT NULL,'
    '${_columuName[4]} TEXT NOT NULL,'
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
      if (showLog) logger.i('$logTag数据库初始化成功');
    }
    catch (error) {
      if (showLog) logger.e('$logTag数据库初始化失败。$error');
    }
  }

  // 添加笔记
  Future<int> addNote(Note note) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> map = {
      _columuName[1]: note.getTitle,
      _columuName[2]: note.getContent,
      _columuName[3]: note.getNoteType.index,
      _columuName[4]: note.getUpdateTime.toIso8601String(),
      _columuName[5]: note.courseId
    };
    int index = await _database.insert(_tableName, map);
    note.id = index;
    if (showLog) logger.i('$logTag添加Note: id = $index');

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 获取全部数据
  Future<List<Note>> getAllNote() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    NoteImageDB noteImageDB = NoteImageDB();

    List<Map<String, dynamic>> resultMap = await _database.query(_tableName);
    List<Note> result = [];
    for (var item in resultMap) {
      Note note = Note(item[_columuName[1]], DateTime.parse(item[_columuName[4]]));
      note.setContent = item[_columuName[2]];
      note.setNoteType = NoteType.values[item[_columuName[3]]];
      note.id = item[_columuName[0]];
      note.courseId = item[_columuName[5]];
      // 获取图片数据
      note.noteImages = await noteImageDB.getNoteImagesByNoteId(note.id);
      result.add(note);
    }
    if (showLog) logger.i('$logTag获取全部Note共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据课程Id获取数据
  Future<List<Note>> getNotesByCourseId(int courseId) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );
    NoteImageDB noteImageDB = NoteImageDB();

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'courseId = ?',
      whereArgs: [courseId]);
    List<Note> result = [];
    for (var item in resultMap) {
      Note note = Note(item[_columuName[1]], DateTime.parse(item[_columuName[4]]));
      note.setContent = item[_columuName[2]];
      note.setNoteType = NoteType.values[item[_columuName[3]]];
      note.courseId = item[_columuName[5]];
      note.id = item[_columuName[0]];
      // 获取图片数据
      //note.noteImages = await noteImageDB.getNoteImagesByNoteId(note.id);
      result.add(note);
    }
    if (showLog) logger.i('$logTag获取Note共${result.length}条');

    await _database.close();
    return result;
  }

  // 根据id获取一条数据
  Future<Note?> getNoteByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));
    NoteImageDB noteImageDB = NoteImageDB();

    List<Map<String, dynamic>> resultMap = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
    List<Note> result = [];
    for (var item in resultMap) {
      Note note = Note(item[_columuName[1]], DateTime.parse(item[_columuName[4]]));
      note.setContent = item[_columuName[2]];
      note.setNoteType = NoteType.values[item[_columuName[3]]];
      note.courseId = item[_columuName[5]];
      note.id = item[_columuName[0]];
      // 获取图片数据
      note.noteImages = await noteImageDB.getNoteImagesByNoteId(note.id);
      result.add(note);
    }

    await _database.close();
    if (result.isEmpty) {
      if (showLog) logger.w('${logTag}Note: id = $id不存在，无法获取');
      return null;
    }
    else {
      if (showLog) logger.i('$logTag获取Note: id = $id');
      return result[0];
    }
  }

  // 更新一个笔记的内容
  Future<int> updateNote(Note note) async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
    );

    Map<String, Object?> map = {
      _columuName[1]: note.getTitle,
      _columuName[2]: note.getContent,
      _columuName[4]: note.getUpdateTime.toIso8601String(),
    };
    int index = await _database.update(_tableName, map, where: 'id = ?', whereArgs: [note.id]);

    await _database.close();

    if (printDB) {
      await printDatabase();
    }

    return index;
  }

  // 根据课程id删除
  Future<void> deleteNotesByCourseId(int courseId) async {
    List<Note> notes = await getNotesByCourseId(courseId);
    for (var item in notes) {
      deleteNoteByID(item.id);
    }
  }

  // 根据id删除一条数据
  Future<int> deleteNoteByID(int id) async {
    _database = await openDatabase(join(await getDatabasesPath(), _databaseName));

    int index = await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id]);

    await _database.close();

    if (index == 0) {
      if (showLog) logger.w('${logTag}Note: id = $id不存在，无法删除');
    }
    else {
      if (showLog) logger.i('$logTag删除Note: id = $id');
    }

    // 删除图片数据
    NoteImageDB noteImageDB = NoteImageDB();
    noteImageDB.deleteNoteImagesByNoteId(id);

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
    List<Note> result = await getAllNote();
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

  static final NoteDB _instance = NoteDB._internal();

  NoteDB._internal();

  factory NoteDB() {
    return _instance;
  }
}
