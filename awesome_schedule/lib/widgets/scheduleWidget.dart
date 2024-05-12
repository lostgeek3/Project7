import 'dart:math';

import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import 'package:awesome_schedule/temp/scheduleDemo.dart';
import 'package:awesome_schedule/widgets/addCourseForm.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);

class ScheduleColumnHeader extends StatelessWidget {
  const ScheduleColumnHeader({super.key});

  @override
  Widget build(BuildContext context) {
    Text buildDayText(String day) {
      return Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 8,
        childAspectRatio: 1,
        padding: const EdgeInsets.all(5),
        children: [
          const Text("Mar",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.pink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          buildDayText('Mon'),
          buildDayText('Tue'),
          buildDayText('Wed'),
          buildDayText('Thu'),
          buildDayText('Fri'),
          buildDayText('Sat'),
          buildDayText('Sun'),
        ]
    );
  }
}

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<StatefulWidget> createState() {
    return ScheduleState();
  }
}

class ScheduleState extends State<Schedule> {
  // 一天的课程节数
  var courseNum = 13;
  set setCourseNum(int num) {
    if (num < 1) {
      logger.w('Course number for a day should be greater than 0.');
    }
    courseNum = num;
  }

  // 一学期的周数
  int weekNum = 16;
  set setWeekNum(int num) {
    if (num < 1) {
      logger.w('Week number for a semester should be greater than 0.');
    }
    weekNum = num;
  }

  // 当前周
  int currentWeek = 1;
  set changeWeek(int week) {
    if (week < 1 || week > weekNum) {
      logger.w('Invalid week number');
    }
    currentWeek = week;
  }

  // 课程块的默认颜色
  var blockColor = const Color(0xffF2CDD2);
  set setBlockColor(Color color) {
    blockColor = color;
  }

  // 所有节课的时间区间
  List<TimeRange> timeRanges = [
    TimeRange(8, 0, 8, 45),
    TimeRange(8, 55, 9, 40),
    TimeRange(10, 0, 10, 45),
    TimeRange(10, 55, 11, 40),
    TimeRange(12, 0, 12, 45),
    TimeRange(12, 55, 13, 40),
    TimeRange(12, 0, 12, 45),
    TimeRange(12, 55, 13, 40),
    TimeRange(14, 0, 14, 45),
    TimeRange(14, 55, 15, 40),
    TimeRange(16, 0, 16, 45),
    TimeRange(16, 55, 17, 40),
    TimeRange(18, 0, 18, 45),
    TimeRange(18, 55, 19, 40),
    TimeRange(20, 0, 20, 45),
    TimeRange(20, 55, 21, 40),
  ];
  // 设置所有课程的时间区间
  set setTimeRange(List<TimeRange> timeRanges) {
    int length = min(timeRanges.length, courseNum);
    for (int i = 0; i < length; i++) {
      var timeRange = timeRanges[i];
      if (timeRange.startHour < 0 ||
          timeRange.startHour > 23 ||
          timeRange.startMinute < 0 ||
          timeRange.startMinute > 59 ||
          timeRange.endHour < 0 ||
          timeRange.endHour > 23 ||
          timeRange.endMinute < 0 ||
          timeRange.endMinute > 59) {
        logger.w('Invalid time range in course ${timeRanges.indexOf(timeRange) + 1}');
        return;
      }
    }
    this.timeRanges = timeRanges.sublist(0, length);
  }
  // 设置某一节课的时间区间
  bool setCourseTimeRange(TimeRange timeRange, int courseSection) {
    if (courseSection < 1 || courseSection > courseNum) {
      logger.w('Invalid course section');
      return false;
    }
    if (timeRange.startHour < 0 ||
        timeRange.startHour > 23 ||
        timeRange.startMinute < 0 ||
        timeRange.startMinute > 59 ||
        timeRange.endHour < 0 ||
        timeRange.endHour > 23 ||
        timeRange.endMinute < 0 ||
        timeRange.endMinute > 59) {
      logger.w('Invalid time range');
      return false;
    }
    timeRanges[courseSection - 1] = timeRange;
    return true;
  }

  // 是否显示周末
  bool showWeekend = false;
  // 设置是否显示周末
  set setShowWeekend(bool show) {
    showWeekend = show;
  }

  // 月份缩写
  final List<String> monthAbbreviations = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];


  Widget _initScheduleHeader() {
    List<Widget> scheduleHeader = [];
    final String currentMonth = monthAbbreviations[DateTime.now().month - 1];
    scheduleHeader.add(Text(currentMonth,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.pink,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        )
    ));
    Text buildDayText(String day) {
      return Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    scheduleHeader.add(buildDayText('Mon'));
    scheduleHeader.add(buildDayText('Tue'));
    scheduleHeader.add(buildDayText('Wed'));
    scheduleHeader.add(buildDayText('Thu'));
    scheduleHeader.add(buildDayText('Fri'));
    if (showWeekend) {
      scheduleHeader.add(buildDayText('Sat'));
      scheduleHeader.add(buildDayText('Sun'));
    }
    return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: (showWeekend ? 8 : 6),
        childAspectRatio: 1,
        padding: const EdgeInsets.all(5),
        children: scheduleHeader,
    );
  }

  Widget _initScheduleContent() {
    List<Widget> scheduleContent = [];

    int columnNum = showWeekend ? 7 : 5;
    for (int i = 1; i <= courseNum; i++) {
      scheduleContent.add(Container(
        alignment: Alignment.center,
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$i\n',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: '${timeRanges[i - 1].startHour}:${(timeRanges[i - 1].startMinute == 0) ? '00' : timeRanges[i - 1].startMinute}\n${timeRanges[i - 1].endHour}:${(timeRanges[i - 1].endMinute == 0) ? '00' : timeRanges[i - 1].endMinute}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ));
      for (int j = 0; j < columnNum; j++) {
        scheduleContent.add(
          Container(
            alignment: Alignment.center,
          ),
        );
      }
    }
    for (var course in courseSet) {
      for (var timeInfo in course.getTimeInfo) {
        if (timeInfo.getWeekList[currentWeek] == false) {
          continue;
        }
        if (timeInfo.getStartSection > courseNum || timeInfo.getEndSection < 1) {
          continue;
        }
        int startSection = timeInfo.getStartSection;
        int endSection = timeInfo.getEndSection;
        int weekDay = timeInfo.getWeekday;

        var courseBlock = Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: blockColor,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  course.getName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              )),
        );
        scheduleContent[(startSection - 1) * (columnNum + 1) + weekDay] = courseBlock;
        scheduleContent[(endSection - 1) * (columnNum + 1) + weekDay] = courseBlock;
      }
    }

    return GridView.count(
      padding: const EdgeInsets.all(5),
      crossAxisCount: (showWeekend ? 8 : 6),
      crossAxisSpacing: (showWeekend ? 5 : 7),
      mainAxisSpacing: 5,
      childAspectRatio: (showWeekend ? 0.6 : 0.8),
      children: scheduleContent,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                    children: [
                      // 右上角一排按钮
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Row(
                          children: [
                            /// 添加课程
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddCourseDialog();
                                  },
                                );
                              },
                            ),
                            /// 更多
                            PopupMenuButton<int>(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text("设置"),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 1) {
                                  /// 设置
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      bool localShowWeekend = showWeekend;
                                      int localCurrentWeek = currentWeek;
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return ListView(
                                            children: [
                                              /// 切换周数
                                              ListTile(
                                                title: const Text('周数'),
                                                subtitle: Slider(
                                                  value: localCurrentWeek.toDouble(),
                                                  min: 1.0,
                                                  max: weekNum.toDouble(),
                                                  divisions: weekNum - 1,
                                                  label: '第$localCurrentWeek周',
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      localCurrentWeek = value.round();
                                                    });
                                                    this.setState(() {
                                                      currentWeek = value.round();
                                                    });
                                                  },
                                                ),
                                              ),
                                              /// 是否显示周末
                                              SwitchListTile(
                                                title: const Text('是否显示周六、周日'),
                                                value: localShowWeekend,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    localShowWeekend = value;
                                                  });
                                                  this.setState(() {
                                                    showWeekend = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),                      Positioned(
                        top: 0,
                        left: 18,
                        child: Text(
                          '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}\n'
                              '第$currentWeek周',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )])
              ),

              Expanded(
                child: _initScheduleHeader(),
              ),
              Expanded(
                flex: 24,
                child: _initScheduleContent(),
              ),
            ],
          ),
        ],
      );
  }
}