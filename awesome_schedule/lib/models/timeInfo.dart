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

/// 类：时间信息
/// 用法：包含一个周期性事件的时间信息
class TimeInfo {
  // 开始时间
  int _startHour = 0;
  int _startMinute = 0;
  // 结束时间
  int _endHour = 0;
  int _endMinute = 0;
  // 周期数
  int _cycle = 1;
  // 当前周期
  int _currentCycle = 1;
  // 周期
  CyclePeriod _cyclePeriod = CyclePeriod.daily;

  TimeInfo(this._startHour, this._startMinute, this._endHour, this._endMinute, {int cycle = 1, int currentCycle = 1, CyclePeriod cyclePeriod = CyclePeriod.daily}) {
    if (cycle <= 0) {
      logger.e('$logTag周期数必须为正数');
      _cycle = 1;
    }
    _cycle = cycle;
    if (currentCycle <= 0 || currentCycle > _cycle) {
      _currentCycle = 1;
    }
    _currentCycle = currentCycle;
    _cyclePeriod = cyclePeriod;
  }

  // 生成下一周期的时间信息
  // TimeInfo? getNext() {
  //   if (_currentCycle == _cycle) {
  //     logger.w('$logTag当前周期数为最大值，停止生成下一周期');
  //     return null;
  //   }
  //   return TimeInfo(_startHour, _startMinute, _endHour, _endMinute, cycle: _cycle, currentCycle: _currentCycle + 1, cyclePeriod: _cyclePeriod);
  // }

  // 打印信息
  void printTimeInfo() {
    logger.i('${logTag}beginTime: $_startHour : $_startMinute, '
    'endTime: $_endHour : $_endMinute, '
    'cycle: $_cycle, '
    'currentCycle: $_currentCycle, '
    'cyclePeriod: ${_cyclePeriod.index}');
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
  set cycle(int cycle) {
    if (cycle <= 0) {
      logger.e('$logTag周期数不合法');
      return;
    }
    _cycle = cycle;
  }
  set currentCycle(int currentCycle) {
    if (currentCycle <= 0 || currentCycle > _cycle) {
      logger.e('$logTag当前周期数超出范围');
      return;
    }
    _currentCycle = currentCycle;
  }
  set cyclePeriod(CyclePeriod cyclePeriod) {
    _cyclePeriod = cyclePeriod;
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
  int get getCycle {
    return _cycle;
  }
  int get getCurrentCycle {
    return _currentCycle;
  }
  CyclePeriod get getCyclePeriod {
    return _cyclePeriod;
  }
}

/// 类：课程表的时间信息
/// 用法：包含课程表的时间信息
class CourseTimeInfo extends TimeInfo {
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


}




/// 枚举：时间周期
/// 用法：表示事件（课程、任务等）的周期类型
enum CyclePeriod {
  daily,
  weekly,
  monthly,
  yearly
}