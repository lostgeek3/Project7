// model测试文件

import 'dart:math';

import 'package:awesome_schedule/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_schedule/models/task.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/models/event.dart';
import 'package:awesome_schedule/models/course.dart';

void main() {
  test('正确性测试', () {
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