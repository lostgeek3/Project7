export 'course.dart';
import 'package:logger/logger.dart';
import 'package:awesome_schedule/models/note.dart';
import 'package:awesome_schedule/models/task.dart';
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
  @override
  late int id;
  // 课程表ID
  late int courseListId;
  // 课程ID
  String _courseID = '';
  // 课程名称
  String _name = '';
  /// 课程时间信息
  /// 时间有一个数组表示
  /// 每个元素表示一周中某天的连续时间
  /// 假设课程时间为周一第一节课，周二第三节课
  /// 则数组包含两个元素
  /// 假设课程时间为周一第一节课，周二第一节课、第五节课
  /// 则数组包含三个元素
  List<CourseTimeInfo> _timeInfo;
  // 课程地点
  String _location = '';
  // 课程简介
  String _description = '';
  // 教师名称
  String _teacher = '';

  // 课程任务
  List<Task> tasks = <Task>[];
  // 课程笔记
  List<Note> notes = <Note>[];

  Course(this._name, this._timeInfo, {String courseID = '', String location = '', String teacher = '', String description = ''}) {
    _courseID = courseID;
    _location = location;
    _teacher = teacher;
    _description = description;
  }

  // 打印信息
  void printCourse() {
    logger.i('${logTag}courseID: $_courseID, '
    'name: $_name, '
    'location: $_location, '
    'description: $_description, '
    'teacher: $_teacher');
  }

  // 根据名称获取任务
  Task? getTaskByName(String name) {
    for (var it in tasks) {
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
    for (var it in tasks) {
      if (it.getName == name) {
        logger.w('$logTag任务 $name 已存在，请选择覆盖');
        return;
      }
    }
    tasks.add(task);
  }

  // 覆盖任务
  void updateTask(Task task) {
    String name = task.getName;
    for (var it in tasks) {
      if (it.getName == name) {
        it = task;
        return;
      }
    }
    logger.w('$logTag任务 $name 不存在，无法覆盖');
  }

  // 根据名称删除任务
  void removeTaskByName(String name) {
    int initialLength = tasks.length;
  
    tasks.retainWhere((task) => task.getName != name);
    
    if (initialLength == tasks.length) {
      logger.w('$logTag任务 $name 不存在，无法删除');
    }
  }

  // set函数
  set setName(String name) {
    _name = name;
  }
  set setCourseID(String courseID) {
    _courseID = courseID;
  }
  set setTimeInfo(List<CourseTimeInfo> timeInfo) {
    _timeInfo = timeInfo;
  }
  set setLocation(String location) {
    _location = location;
  }
  set setTeacher(String teacher) {
    _teacher = teacher;
  }
  set setDescription(String description) {
    _description = description;
  }

  // get函数
  String get getName {
    return _name;
  }
  String get getCourseID {
    return _courseID;
  }
  List<CourseTimeInfo> get getTimeInfo {
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
}