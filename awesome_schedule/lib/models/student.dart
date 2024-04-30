export './student.dart';
import 'package:logger/logger.dart';

// 日志信息
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[class]Student: ';

/// 类：学生
/// 用法：描述一个学生用户
class Student {
  // 名称
  String _name = '';
  // 学生ID
  String _studentID = '';

  Student({String name = '', String studentID = ''}) {
    _name = name;
    _studentID = studentID;
  }

  // set函数
  set name(String name) {
    _name = name;
  }
  set studentID(String studentID) {
    _studentID = studentID;
  }
  // get函数
  get getName {
    return _name;
  }
  get getStudentID {
    return _studentID;
  }
}