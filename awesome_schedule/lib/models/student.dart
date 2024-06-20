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
  late int id;
  // 名称
  String _name = '';
  // 学生ID
  String _studentID = '';
  // 邮箱
  String _mail = '';
  // 头像
  String _avatar = '';

  Student({String name = '', String studentID = '', String mail = '', String avatar = ''}) {
    _name = name;
    _studentID = studentID;
    _mail = mail;
    _avatar = avatar;
  }

  // set函数
  set name(String name) {
    _name = name;
  }
  set studentID(String studentID) {
    _studentID = studentID;
  }
  set mail(String mail) {
    _mail = mail;
  }
  set avatar(String avatar) {
    _avatar = avatar;
  }

  // get函数
  get getName {
    return _name;
  }
  get getStudentID {
    return _studentID;
  }
  get getMail {
    return _mail;
  }
  get getAvatar {
    return _avatar;
  }
}