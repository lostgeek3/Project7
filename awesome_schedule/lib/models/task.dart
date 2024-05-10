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
  // 任务名称
  String _name = '';
  // 任务时间信息
  TimeInfo _timeInfo;
  // 任务地点
  String _location = '';
  // 任务简介
  String _description = '';
  // 任务种类
  TaskType _taskType = TaskType.defaultType;
  // 是否完成
  bool _ifFinished = false;

  Task(this._name, this._timeInfo, {String location = '', String description = '', TaskType taskType = TaskType.defaultType}) {
    _location = location;
    _description = description;
    _taskType = taskType;
  }

  // 给出下一周期任务
  // @override
  // Task? getNext() {
  //   TimeInfo? nextTimeInfo = _timeInfo.getNext();
  //   if (nextTimeInfo == null) {
  //     logger.w('$logTag当前周期数为最大值，停止生成下一周期');
  //     return null;
  //   }
  //   return Task(_name, nextTimeInfo, location: _location, description: _description, taskType: _taskType);
  // }

  // 设置完成
  void setFinished() {
    _ifFinished = true;
  }

  // 设置未完成
  void setUnfinished() {
    _ifFinished = false;
  }

  // set函数
  set name(String name) {
    _name = name;
  }
  set timeInfo(TimeInfo timeInfo) {
    _timeInfo = timeInfo;
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
  TimeInfo get getTimeInfo {
    return _timeInfo;
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
  bool get getIfFinished {
    return _ifFinished;
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