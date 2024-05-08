export './schedule.dart';
import 'dart:math';

import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  List<Widget> _initGridViewData() {
    List<Widget> tempList = [];

    for (int i = 1; i <= 12; i++) {
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
              decoration: BoxDecoration(
                color: const Color(0xFFF2CDD2),
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
                      'Course $i',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ))),
        );
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