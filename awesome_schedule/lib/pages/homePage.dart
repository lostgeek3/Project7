export './homePage.dart';
import 'package:awesome_schedule/widgets/taskWidget.dart';
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

  static  final List<Widget> _widgetOptions = <Widget>[
    const TaskWidget(),
    const Schedule(),
    const UserWidget()
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
          resizeToAvoidBottomInset: false,
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.task_alt),
                label: '待办事项',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: '课程表',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '我的',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: _onItemTapped,
          ),
        )
      ),
    );
  }
}