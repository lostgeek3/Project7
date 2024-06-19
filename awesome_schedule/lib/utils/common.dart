import 'package:awesome_schedule/models/course.dart';
import 'package:awesome_schedule/models/note.dart';

export './common.dart';
// 全局常量

// 默认最大周数
int defalutWeekNum = 20;

// 笔记列表页传递参数
class NoteListArguments {
  late Course course;

  NoteListArguments(this.course);
}

// 笔记页传递参数
class NoteArguments {
  late Note note;

  NoteArguments(this.note);
}