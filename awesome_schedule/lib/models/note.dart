export './note.dart';
import 'dart:typed_data';

import 'package:awesome_schedule/models/noteImage.dart';
import 'package:logger/logger.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Note: ';

/// 类：笔记
/// 用法：组成一个课程的笔记内容
class Note {
  late int id;
  // 课程id
  late int courseId;
  // 笔记类型
  NoteType _noteType = NoteType.markdown;
  // 笔记标题
  String _title = '';
  // 笔记内容
  String _content = '';
  // 笔记中的图片
  List<NoteImage> noteImages = <NoteImage>[];
  // 笔记创建/更新时间
  DateTime _updateTime;

  Note(this._title, this._updateTime, {NoteType noteType = NoteType.Unedited}) {
    _noteType = noteType;
  }

  set setNoteType(NoteType noteType) {
    _noteType = noteType;
  }
  set setTitle(String title) {
    _title = title;
  }
  set setContent(String content) {
    _content = content;
  }
  set setUpdateTime(DateTime updateTime) {
    _updateTime = updateTime;
  }
  NoteType get getNoteType {
    return _noteType;
  }
  String get getTitle {
    return _title;
  }
  String get getContent {
    return _content;
  }
  DateTime get getUpdateTime {
    return _updateTime;
  }
}

// 枚举：笔记类型
enum NoteType {
  Unedited,
  markdown,
  handwritten
}