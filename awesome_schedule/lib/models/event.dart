export 'event.dart';
import 'package:logger/logger.dart';
import 'timeInfo.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Event: ';

/// 类：事件类
/// 用法：作为所有事件的父类
class Event {
  // 事件名称
  String _name = '';
  // 事件时间信息
  TimeInfo _timeInfo;
  // 事件地点
  String _location = '';
  // 事件简介
  String _description = '';

  Event(this._name, this._timeInfo, {String location = '', String description = ''}) {
    _location = location;
    _description = description;
  }

  // 给出下一周期事件
  Event? getNext() {
    TimeInfo? nextTimeInfo = _timeInfo.getNext();
    if (nextTimeInfo == null) {
      logger.w('$logTag当前周期数为最大值，停止生成下一周期');
      return null;
    }
    return Event(_name, nextTimeInfo, location: _location, description: _description);
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
}