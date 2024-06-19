import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/courseList.dart';
import '../models/timeInfo.dart';
import '../pages/jAccountPage.dart';

export './course.dart';

/// 从canvas获取课程等等

Future<CourseList?> loginAndFetchCourses(BuildContext context) async {  // 处理登录
  String? code;
  code = await Navigator.push(  // 首先等待用户输入登录信息，并获取授权码
    context as BuildContext,
    MaterialPageRoute(
      builder: (context) => jAccountPage(),
    ),
  );
  if (code == null) {
    // 弹出提示对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('错误'),
          content: Text('登陆失败，请重试。'),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();  // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  } else {
    return await getIdentityAndCourses(context, code);
  }
}

Future<CourseList?> getIdentityAndCourses(BuildContext context, String code) async {
  var params = {
    'grant_type': 'authorization_code',
    'code': code,
    'scope': 'openid basic essential lessons classes',
    'redirect_uri': 'a',
  };

  var clientId = 'ov3SLrO4HyZSELxcHiqS';
  var clientSecret = 'B9919DDA3BD9FBF7ADB9F84F67920D8CB6528620B9586D1C';

  var credentials = '$clientId:$clientSecret';
  var base64Credentials = 'Basic ${base64Encode(utf8.encode(credentials))}';

  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': base64Credentials,
  };

  String access_token;  // 身份令牌
  String refresh_token; // 刷新令牌

  try {
    var dio = Dio();
    var response = await dio.post(
      'https://jaccount.sjtu.edu.cn/oauth2/token',
      data: params,
      options: Options(
          headers: headers
      ),
    );
    access_token = response.data['access_token'];
    refresh_token = response.data['refresh_token'];

    return await getCourses(context, access_token);
  } on DioError catch (e) {
    if (e.response != null) {
      print('Error response status code: ${e.response!.statusCode}');
      print('Error response data: ${e.response!.data}');
      return null;
    } else {
      print('Error: ${e.message}');
      return null;
    }
  }
}

Future<CourseList?> getCourses(BuildContext context, String access_token) async {
  try {
    var dio = Dio();
    var params = {
      'access_token': access_token,
    };
    var response = await dio.get(
      'https://api.sjtu.edu.cn/v1/me/lessons/2023-2024-2',
      queryParameters: params,
    );

    CourseList courseList = parseCourseList(response.data); // 返回CourseList信息

    

    return courseList;

  } on DioError catch (e) {
    if (e.response != null) {
      print('Error response status code: ${e.response!.statusCode}');
      print('Error response data: ${e.response!.data}');
      return null;
    } else {
      print('Error: ${e.message}');
      return null;
    }
  }
}


CourseList parseCourseList(Map<String, dynamic> jsonData) {
  final List<dynamic> entities = jsonData['entities'];
  CourseList courseList = new CourseList(semester: '2023-2024-2');
  for (dynamic entity in entities) {
    courseList.addCourse(parseCourse(entity));
  }
  return courseList;
}

Course parseCourse(Map<String, dynamic> jsonData) {
  Map<String, dynamic> courseInfo = jsonData['course'];
  List<dynamic> teachers = jsonData['teachers'];
  String name = courseInfo['name'];  // 课程名字
  String courseId = courseInfo['code'];  // 如SE2321
  String teacher = teachers[0]['name'];  // 老师名字
  StringBuffer location = StringBuffer();

  List<CourseTimeInfo> timeInfos = parseTimeInfo(jsonData['classes'], location);

  Course course = Course(
    name, timeInfos,
    courseID: courseId,
    location: location.toString(),
    teacher: teacher,
  );
  return course;
}

class TimePeriod {
  int weekday;
  int begin;
  int end;
  List<int> weeks = [];

  TimePeriod(this.weekday, this.begin, this.end);

  void addWeek(int week) {
    weeks.add(week);
  }
}

List<CourseTimeInfo> parseTimeInfo(List<dynamic> jsonData, StringBuffer location) {
  List<TimePeriod> timePeriods = [];
  List<List<List<bool>>> schedule = List.generate(16, (xIndex) {
    return List.generate(7, (yIndex) {
      return List.generate(20, (zIndex) {
        return false;
      });
    });
  });

  for (dynamic info in jsonData) {
    int week = info['schedule']['week'];
    int day = info['schedule']['day'];
    int period = info['schedule']['period'];
    String loc = info['classroom']['name'];
    if (location.length == 0 && loc != '不排教室') {
      location.write(loc);
    }
    schedule[week][day][period] = true;
  }
  if (location.length == 0) {
    location.write("不排教室");
  }

  for (int week = 0; week < 16; week++)
    for (int weekday = 0; weekday < 7; weekday++) {
      for (int begin = 0; begin < 20; begin++) {
        if (schedule[week][weekday][begin]) {
          int end = begin;
          while (end + 1 < 20 && schedule[week][weekday][end + 1]) {
            end++;
          }
          int i;
          for (i = 0; i < timePeriods.length; i++) {
            TimePeriod t = timePeriods[i];
            if (t.weekday == weekday && t.begin == begin && t.end == end) {
              break;
            }
          }
          if (i < timePeriods.length) {
            timePeriods[i].addWeek(week + 1);
          } else {
            timePeriods.add(TimePeriod(weekday, begin, end));
            timePeriods[i].addWeek(week + 1);
          }
          begin = end;
        }
      }
    }

  List<CourseTimeInfo> timeInfos = [];
  for (TimePeriod t in timePeriods) {
    timeInfos.add(CourseTimeInfo(
        0, 0, 0, 0,
        endWeek: 16,
        weekday: t.weekday + 1,
        startSection: t.begin + 1,
        endSection: t.end + 1,
        weeks: t.weeks
    ));
  }

  return timeInfos;
}