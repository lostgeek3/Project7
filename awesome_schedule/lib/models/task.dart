export './task.dart';
import 'package:logger/logger.dart';
import 'timeInfo.dart';
import 'event.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Task: ';

/// 类：任务（实现自事件类）
/// 用法：任务事件的对象
class Task implements Event{
  @override
  late int id;
  // 课程id
  late int courseId;
  // 任务名称
  String _name = '';
  // 截止时间
  DateTime _deadline;
  // 任务地点
  String _location = '';
  // 任务简介
  String _description = '';
  // 任务种类
  TaskType _taskType = TaskType.defaultType;
  // 是否完成
  bool _finished = false;

  Task(this._name, this._deadline, {String location = '', String description = '', TaskType taskType = TaskType.defaultType}) {
    _location = location;
    _description = description;
    _taskType = taskType;
  }

  // 设置完成
  void setFinished() {
    _finished = true;
  }

  // 设置未完成
  void setUnfinished() {
    _finished = false;
  }

  // set函数
  set name(String name) {
    _name = name;
  }
  set deadline(DateTime deadline) {
    _deadline = deadline;
  }
  set location(String location) {
    _location = location;
  }
  set description(String description) {
    _description = description;
  }
  set taskType(TaskType taskType) {
    _taskType = taskType;
  }

  // get函数
  String get getName {
    return _name;
  }
  DateTime get getDeadline {
    return _deadline;
  }
  String get getLocation {
    return _location;
  }
  String get getDescription {
    return _description;
  }
  TaskType get getTaskType {
    return _taskType;
  }
  bool get getFinished {
    return _finished;
  }
}

/// 枚举：任务种类
/// 用法：表示任务的种类
enum TaskType {
  defaultType,
  homework,
  lab,
  private
}