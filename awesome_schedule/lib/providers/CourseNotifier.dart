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

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void removeCourse(Course course) {
    _courses.remove(course);
    notifyListeners();
  }

  void initFromCurrentCourseList() {
    if (currentCourseList != null) {
      _courses = currentCourseList!.getAllCourse();
      notifyListeners();
    }
  }
}

/// 添加课程表单状态
class CourseFormProvider extends ChangeNotifier {
  List<bool> _selectedWeeks = List<bool>.filled(20, false);
  int _selectedDay = 1;
  int _selectedStartPeriod = 1;
  int _selectedEndPeriod = 1;
  List<CourseTimeInfo> _timeSelections = [];

  void clear() {
    _selectedWeeks = List<bool>.filled(20, false);
    _selectedDay = 1;
    _selectedStartPeriod = 1;
    _selectedEndPeriod = 1;
    _timeSelections = [];
    notifyListeners();
  }

  void toggleWeekSelection(int index) {
    selectedWeeks[index] = !selectedWeeks[index];
    notifyListeners(); // 通知听众状态已改变
  }

  void addTimeSelection(CourseTimeInfo timeSelection) {
    timeSelections.add(timeSelection);
    notifyListeners(); // 通知监听器数据已更改
  }

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
}