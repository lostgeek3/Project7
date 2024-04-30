// model测试文件

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled3/models/task.dart';
import 'package:untitled3/models/timeInfo.dart';
import 'package:untitled3/models/event.dart';
import 'package:untitled3/models/course.dart';

void main() {
  test('TimeInfo测试', () {
    DateTime begin = DateTime(2024, 1, 1);
    DateTime end = DateTime(2024, 1, 2);
    int cycle = 16;
    int currentCycle = 1;
    CyclePeriod cyclePeriod = CyclePeriod.weekly;
    TimeInfo timeInfo = TimeInfo(begin, end, cycle: cycle, currentCycle: currentCycle, cyclePeriod: cyclePeriod);
    expect(timeInfo.getBeginTime, begin);
    expect(timeInfo.getEndTime, end);
    expect(timeInfo.getCycle, cycle);
    expect(timeInfo.getCurrentCycle, currentCycle);
    expect(timeInfo.getCyclePeriod, cyclePeriod);

    TimeInfo? nextTimeInfo = timeInfo.getNext();
    for (int i = currentCycle; i < cycle; i++) {
      expect(true, nextTimeInfo != null);
      expect(i + 1, nextTimeInfo!.getCurrentCycle);
      nextTimeInfo = nextTimeInfo.getNext();
    }
    // 超过最大周期
    expect(null, nextTimeInfo);
  });

  test('Event/Course/Task测试', () {
    var events = <Event>[];
    Course? course = Course('课程', TimeInfo(DateTime.now(), DateTime.now()));
    Task? task = Task('任务', TimeInfo(DateTime.now(), DateTime.now()));
    events.add(course);
    events.add(task);
    expect(events.length, 2);
    expect(events[0] is Course, true);
    expect((events[0] as Course).getName, '课程');
    expect(events[1] is Task, true);

    expect(course.getNext(), null);

    course.addTask(task);
    expect(course.getTaskByName('任务'), task);
    course.getTaskByName('任务')!.setFinished();
    expect(course.getTaskByName('任务')!.getIfFinished, true);
  });
}