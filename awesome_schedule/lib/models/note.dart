export './note.dart';
import 'package:logger/logger.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Note: ';

/// 类：笔记
/// 用法：组成一个课程的笔记内容
class Note {
  
}