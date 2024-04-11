import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )),
        ),
        body: const Column(children: [
          Expanded(
            child: ScheduleColumnHeader(),
          ),
          Expanded(
            flex: 24,
            child: Schedule(),
          ),
        ]),
      ),
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

class ScheduleRowHeader extends StatelessWidget {
  const ScheduleRowHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(5),
      crossAxisCount: 1,
      children: const [
        Text("Mar",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.pink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
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
        ]);
  }
}

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

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 200,
      height: 60,
      margin: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        "Click here",
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
