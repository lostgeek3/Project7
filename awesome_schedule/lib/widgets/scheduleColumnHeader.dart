export './scheduleColumnHeader.dart';
import 'package:flutter/material.dart';

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