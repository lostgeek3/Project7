import 'dart:math';
import 'dart:ui';

import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:awesome_schedule/models/course.dart';
import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/utils/common.dart';
import 'package:awesome_schedule/utils/sharedPreference.dart';
import 'package:awesome_schedule/widgets/CourseInfoDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

import 'package:awesome_schedule/temp/scheduleDemo.dart';
import 'package:awesome_schedule/widgets/addCourseForm.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/CourseNotifier.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);
const String logTag = '[Widget]ScheduleWidget: ';

/// 滑块形状
class PolygonSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double sliderValue;
  const PolygonSliderThumb({
    required this.thumbRadius,
    required this.sliderValue,
  });
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    int sides = 4;
    double innerPolygonRadius = thumbRadius * 1.2;
    double outerPolygonRadius = thumbRadius * 1.4;
    double angle = (math.pi * 2) / sides;

    final outerPathColor = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    var outerPath = Path();

    Offset startPoint2 = Offset(
      outerPolygonRadius * math.cos(0.0),
      outerPolygonRadius * math.sin(0.0),
    );

    outerPath.moveTo(
      startPoint2.dx + center.dx,
      startPoint2.dy + center.dy,
    );

    for (int i = 1; i <= sides; i++) {
      double x = outerPolygonRadius * math.cos(angle * i) + center.dx;
      double y = outerPolygonRadius * math.sin(angle * i) + center.dy;
      outerPath.lineTo(x, y);
    }

    outerPath.close();
    canvas.drawPath(outerPath, outerPathColor);

    final innerPathColor = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.black
      ..style = PaintingStyle.fill;

    var innerPath = Path();

    Offset startPoint = Offset(
      innerPolygonRadius * math.cos(0.0),
      innerPolygonRadius * math.sin(0.0),
    );

    innerPath.moveTo(
      startPoint.dx + center.dx,
      startPoint.dy + center.dy,
    );

    for (int i = 1; i <= sides; i++) {
      double x = innerPolygonRadius * math.cos(angle * i) + center.dx;
      double y = innerPolygonRadius * math.sin(angle * i) + center.dy;
      innerPath.lineTo(x, y);
    }

    innerPath.close();
    canvas.drawPath(innerPath, innerPathColor);

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      text: sliderValue.round().toString(),
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    Offset textCenter = Offset(
      center.dx - (tp.width / 2),
      center.dy - (tp.height / 2),
    );

    tp.paint(canvas, textCenter);
  }
}

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
  var courseNum = 14;
  set setCourseNum(int num) {
    if (num < 1) {
      logger.w('Course number for a day should be greater than 0.');
    }
    courseNum = num;
  }

  // 一学期的周数
  var weekNum = defalutWeekNum;
  set setWeekNum(int num) {
    if (num < 1) {
      logger.w('Week number for a semester should be greater than 0.');
    }
    weekNum = num;
  }

  // 当前周
  var currentWeek = 1;
  set changeWeek(int week) {
    if (week < 1 || week > weekNum) {
      logger.w('Invalid week number');
    }
    currentWeek = week;
  }

  // 课程块的默认颜色
  // var blockColor = const Color(0xffF2CDD2);
  var blockColorSet = [
    const Color(0xffF2CDD2),
    const Color(0xffC2E0F9),
    const Color(0xffC2F9D6),
    const Color(0xffF9F2C2),
    const Color(0xffE0C2F9),
  ];
  // set setBlockColor(Color color) {
  //   blockColor = color;
  // }

  // 所有节课的时间区间
  List<TimeRange> timeRanges = [
    TimeRange(8, 0, 8, 45),
    TimeRange(8, 55, 9, 40),
    TimeRange(10, 0, 10, 45),
    TimeRange(10, 55, 11, 40),
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

  // 当前课程表
  late CourseNotifier courseNotifier;

  // 同屏显示的课程节数
  int courseNumVisible = 8;

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
  bool showWeekend = MySharedPreferences.showWeekend;
  // 启用切换动画
  bool enableSwitchAnimation = true;

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
        children: scheduleHeader,
    );
  }


  var colorIndex = 0;
  var blockColorMap = <String, Color>{};
  Widget _initScheduleContent(int index) {
    List<Widget> scheduleContent = [];

    int columnNum = showWeekend ? 7 : 5;
    // for (int i = 1; i <= courseNum; i++) {
    //   scheduleContent.add(Container(
    //     alignment: Alignment.center,
    //     child: FittedBox(
    //         fit: BoxFit.scaleDown,
    //         child: Padding(
    //           padding: const EdgeInsets.all(2),
    //           child: RichText(
    //             textAlign: TextAlign.center,
    //             text: TextSpan(
    //               children: [
    //                 TextSpan(
    //                   text: '$i\n',
    //                   style: const TextStyle(
    //                     color: Colors.black,
    //                     fontSize: 20,
    //                   ),
    //                 ),
    //                 TextSpan(
    //                   text: '${timeRanges[i - 1].startHour}:${(timeRanges[i - 1].startMinute == 0) ? '00' : timeRanges[i - 1].startMinute}\n${timeRanges[i - 1].endHour}:${(timeRanges[i - 1].endMinute == 0) ? '00' : timeRanges[i - 1].endMinute}',
    //                   style: const TextStyle(
    //                     color: Colors.black,
    //                     fontSize: 10,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         )),
    //   ));
    //   for (int j = 0; j < columnNum; j++) {
    //     scheduleContent.add(
    //       Container(),
    //     );
    //   }
    // }

    List<Course> courses = [];

    if (courseNotifier.courses.isEmpty) {
      if (currentCourseList != null) {
        courses = currentCourseList!.getAllCourse();
      }
    }
    else {
      courses = courseNotifier.courses;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double columnWidth = constraints.maxWidth / (columnNum + 1);
        double rowHeight = constraints.maxHeight / courseNumVisible;

        var gridChildren = <Widget>[];

        for (int i = 1; i <= courseNum; i++) {
          gridChildren.add(
            Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                width: columnWidth,
                height: rowHeight,
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
                  ),
                ),
              ),

            ).withGridPlacement(
              rowStart: i - 1,
              columnStart: 0,
            )
          );
        }

        Widget buildBlockGrid(int week) {
          for (var course in courses) {
            blockColorMap.putIfAbsent(course.getName, () => blockColorSet[(colorIndex++) % blockColorSet.length]);
            var blockColor = blockColorMap[course.getName]!;
            for (var timeInfo in course.getTimeInfo) {
              // 不显示周末且课程在周末
              if (!showWeekend && timeInfo.getWeekday > 5) {
                continue;
              }

              if (timeInfo.getWeekList[week] == false) {
                // print('第${week} 周不上${course.getName}');
                continue;
              }
              if (timeInfo.getStartSection > courseNum || timeInfo.getEndSection < 1) {
                continue;
              }
              int startSection = timeInfo.getStartSection;
              int endSection = timeInfo.getEndSection;
              int weekDay = timeInfo.getWeekday;

              /// 课程块
              int fontSizeIndex = endSection - startSection + 1;
              fontSizeIndex = fontSizeIndex > 3 ? 3 : fontSizeIndex;
              var fontSize = {
                1: 10.0,
                2: 15.0,
                3: 18.0,
              }[fontSizeIndex];

              var courseBlock =
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: InkWell(
                    onTap: () {
                      var courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);
                      courseFormProvider.initFromCourseTimeInfo(timeInfo);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CourseInfoDialog(course: course, timeInfo: timeInfo, courseNotifier: courseNotifier);
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: blockColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // double ratio = 1 / (showWeekend ? 7 : 5) * 5;
                            double textHeight = fontSize! * 1.2;

                            /// 一个课程块信息最多显示的行数
                            var maxNameLines = ((constraints.maxHeight/ 2).floor() / textHeight).floor();
                            var maxLocationLines = ((constraints.maxHeight / 2).floor() / textHeight).floor();
                            var maxLines = 2 * maxNameLines;
                            while (maxLines * textHeight > constraints.maxHeight - 12) {
                              textHeight -= 1;
                            }

                            fontSize = textHeight / 1.2;


                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  course.getName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSize,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: maxNameLines,
                                ),
                                if (course.getLocation.isNotEmpty)
                                  Text(
                                    "@${course.getLocation}",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: maxLocationLines,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );

              gridChildren.add(
                courseBlock.withGridPlacement(
                  rowStart: startSection - 1,
                  rowSpan: endSection - startSection + 1,
                  columnStart: weekDay,
                ),
              );
            }
          }
          return SingleChildScrollView(
            child: LayoutGrid(
              columnGap: 0,
              rowGap: 5,
              columnSizes: List.filled(columnNum + 1, columnWidth.px),
              rowSizes: List.filled(courseNum, (rowHeight - 5).px),
              children: gridChildren,
            ),
          );
        }


        return buildBlockGrid(index);
      },
    );
  }



  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      courseNotifier.initFromCurrentCourseList();
    });
  }

  PreloadPageController _pageController = PreloadPageController();

  @override
  Widget build(BuildContext context) {
    courseNotifier = context.watch<CourseNotifier>();

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
                                /// 初始化添加课程表单状态
                                var courseFormProvider = context.read<CourseFormProvider>();
                                courseFormProvider.clear();
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
                                      int localCourseNumVisible = courseNumVisible;
                                      bool localEnableSwitchAnimation = enableSwitchAnimation;
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return ListView(
                                            children: [
                                              /// 切换周数
                                              ListTile(
                                                title: const Text('周数'),
                                                subtitle: SliderTheme(
                                                  data: SliderTheme.of(context).copyWith(
                                                    trackShape: const RoundedRectSliderTrackShape(),
                                                    trackHeight: 12,
                                                    thumbShape: PolygonSliderThumb(thumbRadius: 16, sliderValue: localCurrentWeek.toDouble())
                                                  ),
                                                  child: Slider(
                                                    value: localCurrentWeek.toDouble(),
                                                    min: 1.0,
                                                    max: weekNum.toDouble(),
                                                    divisions: weekNum - 1,
                                                    onChanged: (double value) {
                                                      setState(() {
                                                        localCurrentWeek = value.round();
                                                      });
                                                    },
                                                    onChangeEnd: (double value) {
                                                      this.setState(() {
                                                        if (enableSwitchAnimation) {
                                                          _pageController.animateToPage(
                                                            value.round() - 1,
                                                            duration: const Duration(milliseconds: 1000),
                                                            curve: Curves.fastLinearToSlowEaseIn,
                                                          );
                                                        } else {
                                                          _pageController.jumpToPage(value.round() - 1);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                )
                                              ),
                                              /// 设置同屏显示的课程节数
                                              ListTile(
                                                  title: const Text('显示节数'),
                                                  subtitle: SliderTheme(
                                                    data: SliderTheme.of(context).copyWith(
                                                        trackShape: const RoundedRectSliderTrackShape(),
                                                        trackHeight: 12,
                                                        thumbShape: PolygonSliderThumb(thumbRadius: 16, sliderValue: localCourseNumVisible.toDouble())
                                                    ),
                                                    child: Slider(
                                                      value: localCourseNumVisible.toDouble(),
                                                      min: 8.0,
                                                      max: courseNum.toDouble(),
                                                      divisions: courseNum - 8,
                                                      onChanged: (double value) {
                                                        setState(() {
                                                          localCourseNumVisible = value.round();
                                                        });
                                                      },
                                                      onChangeEnd: (double value) {
                                                        this.setState(() {
                                                          courseNumVisible = value.round();
                                                        });
                                                      },
                                                    ),
                                                  )
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
                                                    MySharedPreferences.saveShowWeekend(value);
                                                  });
                                                },
                                              ),
                                              SwitchListTile(
                                                title: const Text('启用切换动画'),
                                                value: localEnableSwitchAnimation,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    localEnableSwitchAnimation = value;
                                                  });
                                                  this.setState(() {
                                                    enableSwitchAnimation = value;
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
                      ),
                      Positioned(
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
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: _initScheduleHeader(),
                ),
              ),
              Expanded(
                flex: 24,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: PreloadPageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        currentWeek = page + 1;
                      });
                    },
                    itemCount: weekNum,
                    preloadPagesCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      // 这里返回每周的课程表，你需要根据index（也就是周数）来生成课程表
                      // print(index);
                      return _initScheduleContent(index + 1);
                      // return Text('第${index + 1}周');
                    },
                  ),
                )

              ),
            ],
          ),
        ],
      );
  }
}