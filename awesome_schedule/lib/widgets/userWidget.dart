import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/database/database_util.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/providers/CourseNotifier.dart';
import 'package:awesome_schedule/utils/common.dart';
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/courseList.dart';
import '../service/course.dart';
import '../service/user.dart';
import '../pages/logInPage.dart';
import 'package:provider/provider.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({super.key});

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  String username = userStudent.getName;
  String mail = userStudent.getMail;
  String avatar = userStudent.getAvatar;

  late CourseNotifier courseNotifier;

  @override
  Widget build(BuildContext context) {
    courseNotifier = context.watch<CourseNotifier>();

    return Center(
      child: GestureDetector(
        onTap: () {
          // 处理头像点击事件，跳转到登录页面
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogInPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 主轴尺寸最小化，即垂直方向上尽可能小
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      width: 100, // 设置头像的宽度
                      height: 100, // 设置头像的高度
                      fit: BoxFit.cover, // 图片适配方式，保持比例填充
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          );
                        }
                      },
                    )
                  : const Icon(Icons.account_circle, size: 100), // 如果头像为空，则显示默认图标
              const SizedBox(height: 16.0), // 添加一些垂直间距

              Text(
                username,
                style: const TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0), // 添加一些垂直间距

              Text(
                mail,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0), // 添加一些垂直间距

              ElevatedButton(
                onPressed: () async {
                  CourseList? courseList = await loginAndFetchCourses(context);  // 获取到的CourseList
                  // 以下是debug输出所有课程的具体内容
                  List<Course>? courses = courseList?.getAllCourse();
                  // 更新当前课表并转存数据库
                  if (courseList != null) {
                    // 设置最大周数
                    defalutWeekNum = 16;
                    courseList.weekNum = defalutWeekNum;
                    await clearDatabase();
                    await initDatabase();
                    CourseListDB courseListDB = CourseListDB();
                    int id = await courseListDB.addCourseList(courseList);

                    for (int i = 0; i < courses!.length; i++) {
                      await courseListDB.addCourseToCourseListByID(id, courses![i]);
                    }
                    
                    currentCourseList = courseList;
                    currentCourseListID = id;
                    courseNotifier.clear();

                    // print("以下是课程列表信息:");
                    // for (Course course in courses!) {
                    //   print("课程：${course.getName}");
                    //   print("地点：${course.getLocation}");
                    //   print("教师：${course.getTeacher}");
                    //   List<CourseTimeInfo> timeInfoList = course.getTimeInfo;
                    //   for (CourseTimeInfo t in timeInfoList) {
                    //     print("上课时间：");
                    //     print("星期${t.weekday}");
                    //     print("第${t.startSection}节课开始");
                    //     print("第${t.endSection}节课结束");
                    //     print("周数：${t.getWeekListStr()}");
                    //   }
                    // }

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('提示'),
                          content: Text('成功导入课表。'),
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
                  }
                  
                },
                child: const Text('登录jAccount'),
              ),
            ],
          ),
        ),
      ),
    );
  }




}