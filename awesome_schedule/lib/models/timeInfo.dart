export 'timeInfo.dart';
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
  DateTime _beginTime;
  // 结束时间
  DateTime _endTime;
  // 周期数
  int _cycle = 1;
  // 当前周期
  int _currentCycle = 1;
  // 周期
  CyclePeriod _cyclePeriod = CyclePeriod.daily;

  TimeInfo(this._beginTime, this._endTime, {int cycle = 1, int currentCycle = 1, CyclePeriod cyclePeriod = CyclePeriod.daily}) {
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
  TimeInfo? getNext() {
    if (_currentCycle == _cycle) {
      logger.w('$logTag当前周期数为最大值，停止生成下一周期');
      return null;
    }
    return TimeInfo(_beginTime, _endTime, cycle: _cycle, currentCycle: _currentCycle + 1, cyclePeriod: _cyclePeriod);
  }

  // 打印信息
  void printTimeInfo() {
    logger.i('${logTag}beginTime: ${_beginTime.toString()}, '
    'endTime: ${_endTime.toString()}, '
    'cycle: $_cycle, '
    'currentCycle: $_currentCycle, '
    'cyclePeriod: ${_cyclePeriod.index}');
  }

  // set函数
  set beginTime(DateTime time) {
    _beginTime = time;
  }
  set endTime(DateTime time) {
    _endTime = time;
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
  DateTime get getBeginTime {
    return _beginTime;
  }
  DateTime get getEndTime {
    return _endTime;
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

/// 枚举：时间周期
/// 用法：表示事件（课程、任务等）的周期类型
enum CyclePeriod {
  daily,
  weekly,
  monthly,
  yearly
}