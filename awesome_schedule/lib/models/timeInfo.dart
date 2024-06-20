export 'timeInfo.dart';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]TimeInfo: ';

class TimeRange {
  int startHour;
  int startMinute;
  int endHour;
  int endMinute;

  TimeRange(this.startHour, this.startMinute, this.endHour, this.endMinute);
  set setStartHour(int startHour) {
    if (startHour < 0 || startHour > 23) {
      logger.e('$logTag开始小时数不合法');
      return;
    }
    this.startHour = startHour;
  }
  set setStartMinute(int startMinute) {
    if (startMinute < 0 || startMinute > 59) {
      logger.e('$logTag开始分钟数不合法');
      return;
    }
    this.startMinute = startMinute;
  }
  set setEndHour(int endHour) {
    if (endHour < 0 || endHour > 23) {
      logger.e('$logTag结束小时数不合法');
      return;
    }
    this.endHour = endHour;
  }
  set setEndMinute(int endMinute) {
    if (endMinute < 0 || endMinute > 59) {
      logger.e('$logTag结束分钟数不合法');
      return;
    }
    this.endMinute = endMinute;
  }
  int get getStartHour {
    return startHour;
  }
  int get getStartMinute {
    return startMinute;
  }
  int get getEndHour {
    return endHour;
  }
  int get getEndMinute {
    return endMinute;
  }
}

/// 类：时间信息
/// 用法：包含一个周期性事件的时间信息
class TimeInfo {
  // 开始时间
  int _startHour = 0;
  int _startMinute = 0;
  // 结束时间
  int _endHour = 0;
  int _endMinute = 0;

  TimeInfo(this._startHour, this._startMinute, this._endHour, this._endMinute) {

  }

  // 打印信息
  void printTimeInfo() {
    logger.i('${logTag}beginTime: $_startHour : $_startMinute, '
    'endTime: $_endHour : $_endMinute');
  }

  // set函数
  set startHour(int startHour) {
    if (startHour < 0 || startHour > 23) {
      logger.e('$logTag开始小时数不合法');
      return;
    }
    _startHour = startHour;
  }
  set startMinute(int startMinute) {
    if (startMinute < 0 || startMinute > 59) {
      logger.e('$logTag开始分钟数不合法');
      return;
    }
    _startMinute = startMinute;
  }
  set endHour(int endHour) {
    if (endHour < 0 || endHour > 23) {
      logger.e('$logTag结束小时数不合法');
      return;
    }
    _endHour = endHour;
  }
  set endMinute(int endMinute) {
    if (endMinute < 0 || endMinute > 59) {
      logger.e('$logTag结束分钟数不合法');
      return;
    }
    _endMinute = endMinute;
  }

  // get函数
  int get getStartHour {
    return _startHour;
  }
  int get getStartMinute {
    return _startMinute;
  }
  int get getEndHour {
    return _endHour;
  }
  int get getEndMinute {
    return _endMinute;
  }
}


/// 类：课程表的时间信息
/// 用法：包含课程表的时间信息
class CourseTimeInfo extends TimeInfo {
  late int id;
  // 课程Id
  late int courseId;
  // 结束周
  final int endWeek;

  /// 上课的周数
  /// 大小为endWeek
  /// weekList[i] = true表示第i周有课
  late List<bool> weekList;

  // 星期几
  int weekday = 1;

  // 起始节数
  int startSection = 1;
  // 结束节数
  int endSection = 12;

  CourseTimeInfo(
    super._startHour,
    super._startMinute,
    super._endHour,
    super._endMinute, {
    required this.endWeek,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required List<int> weeks}){
    weekList = List.filled(endWeek + 1, false);
    for (var week in weeks) {
      if (week < 1 || week > endWeek) {
        logger.e('$logTag周数不合法');
      } else {
        weekList[week] = true;
      }
    }
  }

  // 获取weekList字符串
  String getWeekListStr() {
    String result = '';
    for (int i = 0; i <= endWeek; i++) {
      result += weekList[i] ? '1' : '0';
    }
    return result;
  }

  set setWeekday(int weekday) {
    if (weekday < 1 || weekday > 7) {
      logger.e('$logTag星期数不合法');
      return;
    }
    this.weekday = weekday;
  }

  set setStartSection(int startSection) {
    this.startSection = startSection;
  }

  set setEndSection(int endSection) {
    this.endSection = endSection;
  }

  set setWeekList(List<int> weeks) {
    for (var week in weeks) {
      if (week < 1 || week > endWeek) {
        logger.e('$logTag周数不合法');
      } else {
        weekList[week] = true;
      }
    }
  }

  int get getWeekday {
    return weekday;
  }

  int get getStartSection {
    return startSection;
  }

  int get getEndSection {
    return endSection;
  }

  List<bool> get getWeekList {
    return weekList;
  }

  int get getEndWeek {
    return endWeek;
  }

  /// 格式化输出周数
  String get getWeekListStrFormat {
    List<int> selectedWeeks = [];
    for (int i = 1; i < weekList.length; i++) {
      if (weekList[i]) {
        selectedWeeks.add(i);
      }
    }

    String output = '';

    List<int> tmp = [];
    int start = 0;
    int end = -1;
    int diff = 0;
    for (int i = 0; i < selectedWeeks.length; i++) {
      if (start > end) {
        tmp.add(selectedWeeks[i]);
        start = selectedWeeks[i];
        end = selectedWeeks[i];
      } else if (start == end) {
        if (selectedWeeks[i] - end <= 2) {
          diff = selectedWeeks[i] - end;
          tmp.add(selectedWeeks[i]);
          end = selectedWeeks[i];
        } else {
          output += '第${tmp[0]}周, ';
          end = selectedWeeks[i];
          start = selectedWeeks[i];
          tmp.clear();
          tmp.add(selectedWeeks[i]);
        }
      } else {
        if (selectedWeeks[i] - end == diff) {
          tmp.add(selectedWeeks[i]);
          end = selectedWeeks[i];
        } else {
          if (diff == 1) {
            output += '第${start} - ${end}周, ';
          } else if (diff == 2) {
            if (end % 2 == 0) {
              output += '第${start} - ${end} 双周, ';
            } else {
              output += '第${start} - ${end} 单周, ';
            }
          }
          tmp.clear();
          tmp.add(selectedWeeks[i]);
          start = selectedWeeks[i];
          end = selectedWeeks[i];
        }
      }
    }

    if (!tmp.isEmpty) {
      if (diff == 1) {
        output += '第${start} - ${end}周';
      } else if (diff == 2) {
        if (end % 2 == 0) {
          output += '第${start} - ${end}周 双周';
        } else {
          output += '第${start} - ${end}周 单周';
        }
      }
    } else {
      output = output.substring(0, output.length - 2);
    }
    return output;
  }

}

// 解析weekList字符串
List<int> readWeekListStr(String str) {
  int length = str.length;
  if (length == 0) {
    logger.w('$logTag字符串不能为空');
    return [];
  }
  List<int> weeks = [];
  for (int i = 0; i < length; i++) {
    if (str[i] == '1') {
      weeks.add(i);
    }
  }
  return weeks;
}

/// 枚举：时间周期
/// 用法：表示事件（课程、任务等）的周期类型
enum CyclePeriod {
  daily,
  weekly,
  monthly,
  yearly
}