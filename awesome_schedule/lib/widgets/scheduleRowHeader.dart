export './scheduleRowHeader.dart';
import 'package:flutter/material.dart';

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