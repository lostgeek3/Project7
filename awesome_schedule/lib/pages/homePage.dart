export './homePage.dart';
import 'package:flutter/material.dart';
import 'package:awesome_schedule/widgets/scheduleWidget.dart';
import 'package:awesome_schedule/widgets/userWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 导航栏状态
  int _selectedIndex = 1;

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      '任务',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    ),
    Column(children: [
          // Expanded(
          //   child: ScheduleColumnHeader(),
          // ),
          Expanded(
            child: Schedule(),
          ),
        ]
    ),
    UserWidget()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Task',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: _onItemTapped,
          ),
        )
      ),
    );
  }
}