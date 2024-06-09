export './activity.dart';
import 'package:logger/logger.dart';
import 'timeInfo.dart';
import 'event.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Activity: ';

/// 类：活动（实现自事件类）
/// 用法：任务事件的对象
class Activity implements Event{
  @override
  late int id;
  // 活动名称
  String _name = '';
  // 开始时间
  DateTime _startTime;
  // 结束时间
  DateTime _endTime;
  // 活动地点
  String _location = '';
  // 活动简介
  String _description = '';
  // 活动种类
  ActivityType _activityType = ActivityType.defaultType;

  Activity(this._name, this._startTime, this._endTime, {String location = '', String description = '', ActivityType activityType = ActivityType.defaultType}) {
    _location = location;
    _description = description;
    _activityType = activityType;
  }

  // set函数
  set name(String name) {
    _name = name;
  }
  set startTime(DateTime startTime) {
    _startTime = startTime;
  }
  set endTime(DateTime endTime) {
    _endTime = endTime;
  }
  set location(String location) {
    _location = location;
  }
  set description(String description) {
    _description = description;
  }
  set activityType(ActivityType activityType) {
    _activityType = activityType;
  }

  // get函数
  String get getName {
    return _name;
  }
  DateTime get getStartTime {
    return _startTime;
  }
  DateTime get getEndTime {
    return _endTime;
  }
  String get getLocation {
    return _location;
  }
  String get getDescription {
    return _description;
  }
  ActivityType get getActivityType {
    return _activityType;
  }
}

/// 枚举：活动种类
/// 用法：表示活动的种类
enum ActivityType {
  defaultType,
  meeting,
  work,
  leisure,
  private
}