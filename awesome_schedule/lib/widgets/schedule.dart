export './schedule.dart';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:untitled3/temp/scheduleDemo.dart';

// 一天的课程节数
var courseNum = 12;

int currentWeek = 1;

var blockColor = const Color(0xffF2CDD2);

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  List<Widget> _initGridViewData() {
    List<Widget> tempList = [];

    for (int i = 1; i <= courseNum; i++) {
      tempList.add(Container(
        alignment: Alignment.center,
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                '$i\ntime',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            )),
      ));
      for (int j = 0; j < 7; j++) {
        tempList.add(
          Container(
              alignment: Alignment.center,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 1,
              //   ),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              // child: FittedBox(
              //     fit: BoxFit.scaleDown,
              //     child: Padding(
              //       padding: const EdgeInsets.all(2),
              //       child: Text(
              //         'Course $i',
              //         textAlign: TextAlign.center,
              //         style: const TextStyle(
              //           color: Colors.black,
              //           fontSize: 20,
              //         ),
              //       ),
              //     )),
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
              width: 3,
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
        tempList[(startSection - 1) * 8 + weekDay] = courseBlock;
        tempList[(endSection - 1) * 8 + weekDay] = courseBlock;
      }
    }

    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(5),
      crossAxisCount: 8,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 0.5,
      children: _initGridViewData(),
    );
  }
}

Color getRandomColor() {
  return Color.fromRGBO(
    Random().nextInt(256),
    Random().nextInt(256),
    Random().nextInt(256),
    1,
  );
}