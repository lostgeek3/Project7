export 'course.dart';
import 'package:logger/logger.dart';
import 'timeInfo.dart';
import 'event.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Course: ';

/// 类：课程（继承自事件类）
/// 用法：课程事件的对象
class Course extends Event {
  // 课程ID
  String _courseID = '';
  // 教师名称
  String _teacher = '';

  Course(String name, TimeInfo timeInfo, {String courseID = '', String location = '', String teacher = '', String description = ''})
  : super(name, timeInfo, location: location, description: description) {
    _courseID = courseID;
    _teacher = teacher;
  }

  // 给出下一周期课程
  @override
  Course? getNext() {
    TimeInfo? nextTimeInfo = super.getTimeInfo.getNext();
    if (nextTimeInfo == null) {
      logger.w('$logTag当前周期数为最大值，停止生成下一周期');
      return null;
    }
    return Course(super.getName, nextTimeInfo, courseID: _courseID, location: super.getLocation, description: super.getDescription);
  }

  // set函数
  @override
  set name(String name) {
    super.name = name;
  }
  set courseID(String courseID) {
    _courseID = courseID;
  }
  @override
  set timeInfo(TimeInfo timeInfo) {
    super.timeInfo = timeInfo;
  }
  @override
  set location(String location) {
    super.location = location;
  }
  set teacher(String teacher) {
    _teacher = teacher;
  }
  @override
  set description(String description) {
    super.description = description;
  }

  // get函数
  @override
  String get getName {
    return super.getName;
  }
  String get getCourseID {
    return _courseID;
  }
  @override
  TimeInfo get getTimeInfo {
    return super.getTimeInfo;
  }
  @override
  String get getLocation {
    return super.getLocation;
  }
  String get getTeacher {
    return _teacher;
  }
  @override
  String get getDescription {
    return super.getDescription;
  }
}