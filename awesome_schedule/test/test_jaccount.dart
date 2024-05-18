import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'models/courseList.dart';
import 'models/course.dart';
import 'models/timeInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? code;  // 授权码
  String? access_token;  // 身份令牌
  String? refresh_token;  // 刷新令牌

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => handleLoginInPressed(),
              child: Text('登录'),
            ),
            ElevatedButton(
              onPressed: () => handleGetIdentityPressed(),
              child: Text('获取身份令牌'),
            ),
            ElevatedButton(
                onPressed: () => handleShowPressed(),
                child: Text('显示信息'),
            ),
          ],
        ),
      ),
    );
  }

  void handleLoginInPressed() {  // 点击登录按钮
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(onCodeChanged: (String newCode) {
          setState(() {
            code = newCode;
            print(code);
          });
        }),
      ),
    );
  }

  void handleGetIdentityPressed() async{  // 点击导入按钮
    if (code == null) {
      print('code is null!');
      return;
    }
    await getIdentity();
  }

  Future<void> getIdentity() async {
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
      refresh_token = response.data['response_token'];
    } on DioError catch (e) {
      if (e.response != null) {
        // 请求失败，并且服务器返回了错误信息
        print('Error response status code: ${e.response!.statusCode}');
        print('Error response data: ${e.response!.data}');
      } else {
        // 请求失败，但服务器没有返回错误信息
        print('Error: ${e.message}');
      }
    }
  }

  void handleShowPressed() async {
    if (access_token == null) {
      print('access token is null!');
      return;
    }
    await getInfo();
  }

  Future<CourseList?> getInfo() async {
    try {
      var dio = Dio();
      var params = {
        'access_token': access_token,
      };
      var response = await dio.get(
        'https://api.sjtu.edu.cn/v1/me/lessons/2023-2024-2',
        queryParameters: params,
      );

      // 显示获取到的信息
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('获取到的信息'),
            content: Text(response.data.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('关闭'),
              ),
            ],
          );
        },
      );

      return parseCourseList(response.data);  // 返回CourseList信息

    } on DioError catch (e) {
      if (e.response != null) {
        // 请求失败，并且服务器返回了错误信息
        print('Error response status code: ${e.response!.statusCode}');
        print('Error response data: ${e.response!.data}');
      } else {
        // 请求失败，但服务器没有返回错误信息
        print('Error: ${e.message}');
      }
    }


  }
}

class WebViewPage extends StatelessWidget {
  var url = "https://jaccount.sjtu.edu.cn/oauth2/authorize?response_type=code&client_id=ov3SLrO4HyZSELxcHiqS&redirect_uri=a";
  String? newCode;

  final Function(String) onCodeChanged;
  WebViewPage({required this.onCodeChanged});

  Future<String?> getLoginURL() async {
    var dio = Dio();
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      // 如果请求成功，返回跳转的url
      var url = response.redirects.last.location.toString();
      return url;
    } else {
      // 如果请求失败，返回空字符串
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录jAccount'),
      ),
      body: FutureBuilder<String?>(
        future: getLoginURL(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 如果数据已经加载完成，显示WebView
            return WebView(
              initialUrl: snapshot.data!,
              javascriptMode: JavascriptMode.unrestricted, // 启用 JavaScript
              navigationDelegate: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                // 当页面开始加载时调用
                int codeIndex = url.indexOf('code=');
                if (codeIndex != -1) {
                  newCode = url.substring(codeIndex + 5);
                  onCodeChanged(newCode!);
                  Navigator.pop(context);
                }
              },
            );
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 显示加载中的提示
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
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
  print(name);
  print(courseId);
  print(teacher);
  print(location.toString());
   Course course = new Course(
     name, timeInfos,
     courseID: courseId,
     location: location.toString(),
     teacher: teacher,
   );
  return course;
}

//这里定义了一个类，拷贝代码时把这个类一起拷贝了
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

  for (int week = 0; week < 16; week++)
    for (int weekday = 0; weekday < 7; weekday++)
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
  for (CourseTimeInfo t in timeInfos) {
    print(t.weekday);
    print(t.startSection);
    print(t.endSection);
    print(t.getWeekListStr());
    print("\n");
  }
  return timeInfos;
}