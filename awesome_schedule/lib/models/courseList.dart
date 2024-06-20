export './courseList.dart';
import 'package:logger/logger.dart';

import './course.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]CourseList: ';

/// 类：课程表
/// 用法：储存一个课程表结构
class CourseList {
  late int id;
  // 课程集合
  final _courseSet = <Course>[];
  // 当前周数
  int _currentWeek = 1;
  // 总周数
  int _weekNum = 1;
  // 学期名称
  String _semester = '';

  CourseList({String semester = ''}) {
    _semester = semester;
  }

  // 获取所有课程
  List<Course> getAllCourse() {
    return _courseSet;
  }

  // 根据名称获取课程
  Course? getCourseByName(String name) {
    for (var it in _courseSet) {
      if (it.getName == name) {
        return it;
      }
    }
    logger.w('$logTag课程 $name 不存在，无法获取');
    return null;
  }

  // 添加课程
  void addCourse(Course course) {
    String name = course.getName;
    for (var it in _courseSet) {
      if (it.getName == name) {
        logger.w('$logTag课程 $name 已存在，请选择覆盖');
        return;
      }
    }
    _courseSet.add(course);
  }

  // 覆盖课程
  void updateCourse(Course course) {
    String name = course.getName;
    for (var it in _courseSet) {
      if (it.getName == name) {
        it = course;
        return;
      }
    }
    logger.w('$logTag课程 $name 不存在，无法覆盖');
  }

  // 根据名称删除课程
  void removeCourseByName(String name) {
    int initialLength = _courseSet.length;

    _courseSet.retainWhere((element) => element.getName != name);

    if (initialLength == _courseSet.length) {
      logger.w('$logTag课程 $name 不存在，无法删除');
    }
  }

  // set函数
  set currentWeek(int currentWeek) {
    if (currentWeek > _weekNum) {
      logger.w('$logTag当前周数超过最大周数，无法增加');
      return;
    }
    _currentWeek = currentWeek;
  }
  set weekNum(int weekNum) {
    _weekNum = weekNum;
  }
  set semester(String semester) {
    _semester = semester;
  }

  // get函数
  get getCurrentWeek {
    return _currentWeek;
  }
  get getWeekNum {
    return _weekNum;
  }
  get getSemester {
    return _semester;
  }
}

// 当前的课程表
CourseList? currentCourseList = null;
int currentCourseListID = 0;
