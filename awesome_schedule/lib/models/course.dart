export 'course.dart';
import 'package:logger/logger.dart';
import 'package:untitled3/models/note.dart';
import 'package:untitled3/models/task.dart';
import 'timeInfo.dart';
import 'event.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Course: ';

/// 类：课程（实现自事件类）
/// 用法：课程事件的对象
class Course implements Event{
  // 课程ID
  String _courseID = '';
  // 课程名称
  String _name = '';
  // 课程时间信息
  TimeInfo _timeInfo;
  // 课程地点
  String _location = '';
  // 课程简介
  String _description = '';
  // 教师名称
  String _teacher = '';

  // 课程任务
  final _tasks = <Task>[];
  // 课程笔记
  final _note = Note();

  Course(this._name, this._timeInfo, {String courseID = '', String location = '', String teacher = '', String description = ''}) {
    _courseID = courseID;
    _location = location;
    _teacher = teacher;
    _description = description;
  }

  // 给出下一周期课程
  @override
  Course? getNext() {
    TimeInfo? nextTimeInfo = _timeInfo.getNext();
    if (nextTimeInfo == null) {
      logger.w('$logTag当前周期数为最大值，停止生成下一周期');
      return null;
    }
    return Course(_name, nextTimeInfo, courseID: _courseID, location: _location, description: _description);
  }

  // 根据名称获取任务
  Task? getTaskByName(String name) {
    for (var it in _tasks) {
      if (it.getName == name) {
        return it;
      }
    }
    logger.w('$logTag任务 $name 不存在，无法获取');
    return null;
  }

  // 添加任务
  void addTask(Task task) {
    String name = task.getName;
    for (var it in _tasks) {
      if (it.getName == name) {
        logger.w('$logTag任务 $name 已存在，请选择覆盖');
        return;
      }
    }
    _tasks.add(task);
  }

  // 覆盖任务
  void updateTask(Task task) {
    String name = task.getName;
    for (var it in _tasks) {
      if (it.getName == name) {
        it = task;
        return;
      }
    }
    logger.w('$logTag任务 $name 不存在，无法覆盖');
  }

  // 根据名称删除任务
  void removeTaskByName(String name) {
    for (var it in _tasks) {
      if (it.getName == name) {
        _tasks.remove(it);
      }
    }
    logger.w('$logTag任务 $name 不存在，无法删除');
  }

  // set函数
  set name(String name) {
    _name = name;
  }
  set courseID(String courseID) {
    _courseID = courseID;
  }
  set timeInfo(TimeInfo timeInfo) {
    _timeInfo = timeInfo;
  }
  set location(String location) {
    _location = location;
  }
  set teacher(String teacher) {
    _teacher = teacher;
  }
  set description(String description) {
    _description = description;
  }

  // get函数
  String get getName {
    return _name;
  }
  String get getCourseID {
    return _courseID;
  }
  TimeInfo get getTimeInfo {
    return _timeInfo;
  }
  String get getLocation {
    return _location;
  }
  String get getTeacher {
    return _teacher;
  }
  String get getDescription {
    return _description;
  }
  Note get getNote {
    return _note;
  }
}