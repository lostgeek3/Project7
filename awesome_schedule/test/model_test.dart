// model测试文件

import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_schedule/models/activity.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/note.dart';
import 'package:awesome_schedule/models/noteImage.dart';
import 'package:awesome_schedule/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_schedule/models/task.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/models/event.dart';
import 'package:awesome_schedule/models/course.dart';

void main() {
  test('activity test', () {
    Activity activity = Activity('1', DateTime.now(), DateTime.now(), location: '2', description: '3', activityType: ActivityType.leisure);
    
    String name = '1';
    DateTime startTime = DateTime(2024);
    DateTime endTime = DateTime(2024);
    String location = '2';
    String description = '3';
    ActivityType activityType = ActivityType.private;

    activity.name = name;
    activity.startTime = startTime;
    activity.endTime = endTime;
    activity.location = location;
    activity.description = description;
    activity.activityType = activityType;

    expect(activity.getName, name);
    expect(activity.getStartTime, startTime);
    expect(activity.getEndTime, endTime);
    expect(activity.getLocation, location);
    expect(activity.getDescription, description);
    expect(activity.getActivityType, activityType);
  });

  test('course test', () {
    Course course = Course(
      '高等数学',
      [
        CourseTimeInfo(8, 0, 9, 40,
          endWeek: 16,
          weekday: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 2, 3, 4])
      ],
      courseID: 'MATH001',
      location: '教1-101',
      teacher: '张三',
      description: '这是一门数学课'
    );
    int id = 1;
    int courseListId = 1;
    String courseId = 'MATH001';
    String name = '高等数学';
    List<CourseTimeInfo> timeInfo = [
      CourseTimeInfo(8, 0, 9, 40,
          endWeek: 16,
          weekday: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 2, 3, 4])
    ];
    String location = '教1-101';
    String description = '这是一门数学课';
    String teacher = '张三';

    course.id = 1;
    course.courseListId = courseListId;
    course.setCourseID = courseId;
    course.setDescription = description;
    course.setLocation = location;
    course.setName = name;
    course.setTeacher = teacher;
    course.setTimeInfo = timeInfo;

    expect(course.getName, name);
    expect(course.getCourseID, courseId);
    expect(course.getTimeInfo, timeInfo);
    expect(course.getLocation, location);
    expect(course.getTeacher, teacher);
    expect(course.getDescription, description);

    course.printCourse();
    String task1Name = '1';
    String task2Name = '2';
    Task task1 = Task(task1Name, DateTime.now());
    Task task2 = Task(task2Name, DateTime.now());
    course.getTaskByName(task1Name);
    course.addTask(task1);
    course.addTask(task1);
    course.getTaskByName(task1Name);
    course.getTaskByName(task2Name);
    course.updateTask(task1);
    course.updateTask(task2);
    course.addTask(task2);
    course.removeTaskByName(task1Name);
  });

  test('courseList test', () {
    CourseList courseList = CourseList();
    int id = 1;
    var courseSet = [
      Course('高等数学',
          [CourseTimeInfo(8, 0, 9, 40,
              endWeek: defalutWeekNum,
              weekday: 1,
              startSection: 1,
              endSection: 2,
              weeks: [1, 2, 3, 4])],
          courseID: 'MATH001',
          location: '教1-101',
          teacher: '张三',
          description: '这是一门数学课'),
      Course('线性代数',
          [CourseTimeInfo(14, 0, 15, 40,
              endWeek: defalutWeekNum,
              weekday: 3,
              startSection: 7,
              endSection: 8,
              weeks: [1, 2, 3, 4])],
          location: '教1-102',
          teacher: '李四',
          description: '这是一门代数课'),
    ];
    int currentWeek = 1;
    int weekNum = 20;
    String semester = '2024-1';
    courseList.currentWeek = 100;
    courseList.currentWeek = currentWeek;
    courseList.weekNum = weekNum;
    courseList.semester = semester;

    expect(courseList.getCurrentWeek, currentWeek);
    expect(courseList.getWeekNum, weekNum);
    expect(courseList.getSemester, semester);

    courseList.getCourseByName('1');
    courseList.updateCourse(courseSet[0]);
    courseList.removeCourseByName('1');
    courseList.addCourse(courseSet[0]);
    courseList.getCourseByName('高等数学');
    courseList.updateCourse(courseSet[0]);
    courseList.addCourse(courseSet[1]);
    courseList.removeCourseByName('高等数学');
    courseList.getAllCourse();
  });

  test('note test', () {
    Note note = Note('1', DateTime.now());
    int id = 1;
    int courseId = 1;
    NoteType noteType = NoteType.handwritten;
    String title = 'note';
    String content = '114514';
    DateTime updateTime = DateTime.now();

    note.setContent = content;
    note.setNoteType = noteType;
    note.setTitle = title;
    note.setUpdateTime = updateTime;

    expect(note.noteImages.isEmpty, true);
    expect(note.getContent, content);
    expect(note.getTitle, title);
    expect(note.getNoteType, noteType);
    expect(note.getUpdateTime, updateTime);
  });

  test('noteImage test', () {
    String name = '1';
    Uint8List image = Uint8List(10);
    NoteImage noteImage = NoteImage('1', image);
    noteImage.setName = name;
    noteImage.setImage = image;

    expect(noteImage.getName, name);
    expect(noteImage.getImage, image);
  });

  test('timeInfo test', () {
    final random = Random();
    // 测试CourseTimeInfo的构造正确性
    for (int i = 0; i < 100; i++) {
      List<int> weeks = [];
      for (int j = 0; j <= defalutWeekNum; j++) {
        int tmp = random.nextInt(defalutWeekNum);
        if (tmp == 0 || weeks.contains(tmp)) {
          continue;
        }
        weeks.add(tmp);
      }
      weeks.sort();
      CourseTimeInfo courseTimeInfo = CourseTimeInfo(0, 0, 1, 40, endWeek: defalutWeekNum, weekday: 1, startSection: 1, endSection: 2, weeks: weeks);
      String str = '0';
      for (int j = 1; j <= defalutWeekNum; j++) {
        if (weeks.contains(j)) {
          str += '1';
        }
        else {
          str += '0';
        }
      }
      expect(courseTimeInfo.getWeekListStr(), str);
      expect(readWeekListStr(str), weeks);
    }
  });
}