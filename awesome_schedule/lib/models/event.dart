export 'event.dart';

/// 类：事件抽象类
/// 用法：作为所有事件的父类接口
abstract class Event {
  // 给出下一周期事件
  Event? getNext();
}