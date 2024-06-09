import 'dart:convert';
import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_schedule/models/course.dart';

/// 课程表状态
class CourseNotifier with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Course> _courses = [
    // Course("高等数学",
    //     [CourseTimeInfo(8, 0, 9, 40,
    //         endWeek: 20,
    //         weekday: 1,
    //         startSection: 1,
    //         endSection: 2,
    //         weeks: [1, 3, 5, 7, 9, 11, 13, 15]),],
    //     courseID: 'MATH001',
    //     location: '教1-101',
    //     teacher: '张三',
    //     description: '这是一门数学课'),
  ];

  List<Course> get courses => _courses;

  void refresh(String oldName, Course newCourse) async {
    CourseDB courseDB = CourseDB();
    int courseID = await courseDB.getIDByName(oldName, currentCourseListID);
    CourseListDB courseListDB = CourseListDB();
    await courseListDB.deleteCourseByNameAndCourseListId(oldName, currentCourseListID);
    await courseListDB.addCourseToCourseListByID(currentCourseListID, newCourse);
    notifyListeners();
  }

  void addCourse(Course course) async {
    _courses.add(course);
    CourseListDB courseListDB = CourseListDB();
    await courseListDB.addCourseToCourseListByID(currentCourseListID, course);
    notifyListeners();
  }

  void removeCourse(Course course) async {
    _courses.remove(course);
    CourseListDB courseListDB = CourseListDB();
    await courseListDB.deleteCourseByNameAndCourseListId(course.getName, currentCourseListID);
    notifyListeners();
  }

  void initFromCurrentCourseList() {
    if (currentCourseList != null) {
      _courses = currentCourseList!.getAllCourse();
      notifyListeners();
    }
  }
}

// 快捷选择周数
enum WeekPattern { all, odd, even, none }
/// 添加课程表单状态
class CourseFormProvider extends ChangeNotifier {
  List<bool> _selectedWeeks = List<bool>.filled(20, false);
  int _selectedDay = 1;
  int _selectedStartPeriod = 1;
  int _selectedEndPeriod = 1;

  WeekPattern _selectedWeekPattern = WeekPattern.none;
  List<CourseTimeInfo> _timeSelections = [];

  // 初始化状态
  void clear() {
    _selectedWeeks = List<bool>.filled(20, false);
    _selectedDay = 1;
    _selectedStartPeriod = 1;
    _selectedEndPeriod = 1;
    selectedWeekPattern = WeekPattern.none;
    _timeSelections = [];
    notifyListeners();
  }

  // 从课程时间信息初始化状态
  void initFromCourseTimeInfo(CourseTimeInfo timeInfo) {
    selectedDay = timeInfo.weekday;
    selectedStartPeriod = timeInfo.startSection;
    selectedEndPeriod = timeInfo.endSection;
    selectedWeeks = timeInfo.getWeekList.sublist(1);
    updateWeekPattern();
  }

  // 更新周数模式
  void updateWeekPattern() {
    bool isAll = selectedWeeks.every((element) => element);
    bool isOdd = selectedWeeks.asMap().entries.every((entry) => (entry.key % 2 == 0) == entry.value);
    bool isEven = selectedWeeks.asMap().entries.every((entry) => (entry.key % 2 != 0) == entry.value);
    if (isAll) {
      selectedWeekPattern = WeekPattern.all;
    } else if (isOdd) {
      selectedWeekPattern = WeekPattern.odd;
    } else if (isEven) {
      selectedWeekPattern = WeekPattern.even;
    } else {
      selectedWeekPattern = WeekPattern.none;
    }
    notifyListeners();
  }

  // 切换某周的选中状态
  void toggleWeekSelection(int index) {
    selectedWeeks[index] = !selectedWeeks[index];
    notifyListeners(); // 通知听众状态已改变
  }

  // 添加时间段
  void addTimeSelection(CourseTimeInfo timeSelection) {
    timeSelections.add(timeSelection);
    notifyListeners(); // 通知监听器数据已更改
  }

  // 删除时间段
  void removeTimeSelection(CourseTimeInfo timeSelection) {
    timeSelections.remove(timeSelection);
    notifyListeners();
  }

  List<bool> get selectedWeeks => _selectedWeeks;
  set selectedWeeks(List<bool> value) {
    _selectedWeeks = value;
    notifyListeners();
  }

  int get selectedDay => _selectedDay;
  set selectedDay(int value) {
    _selectedDay = value;
    notifyListeners();
  }

  int get selectedStartPeriod => _selectedStartPeriod;
  set selectedStartPeriod(int value) {
    _selectedStartPeriod = value;
    notifyListeners();
  }

  int get selectedEndPeriod => _selectedEndPeriod;
  set selectedEndPeriod(int value) {
    _selectedEndPeriod = value;
    notifyListeners();
  }

  List<CourseTimeInfo> get timeSelections => _timeSelections;
  set timeSelections(List<CourseTimeInfo> value) {
    _timeSelections = value;
    notifyListeners();
  }

  WeekPattern get selectedWeekPattern => _selectedWeekPattern;
  set selectedWeekPattern(WeekPattern value) {
    _selectedWeekPattern = value;
    notifyListeners();
  }
}