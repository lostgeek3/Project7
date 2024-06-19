import 'package:awesome_schedule/database/task_db.dart';
import 'package:awesome_schedule/models/task.dart';
import 'package:awesome_schedule/providers/CourseNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

export './taskWidget.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({super.key});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  late List<Task> _tasks;
  late CourseNotifier courseNotifier;

  @override
  Widget build(BuildContext context) {
    courseNotifier = context.watch<CourseNotifier>();
    // 获取任务列表
    _tasks = courseNotifier.getAllTasks();

    int totalTasks = _tasks.length;
    int completedTasks = _tasks.where((task) => task.getFinished).length;

    return Column(
      children: [
        // 圆形进度条
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                    strokeWidth: 6.0,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$completedTasks / $totalTasks',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('已完成任务'),
                  ],
                ),
              ],
            ),
          ),
        ),
        // 任务列表
        Expanded(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return Card(
                color: task.getFinished ? Colors.grey[300] : Colors.white,
                child: ListTile(
                  title: Row(
                    children: [
                      Icon(
                        _getTaskIcon(task.getTaskType),
                        color: task.getFinished ? Colors.grey : Color(0xffF2CDD2),
                        size: 50.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.getName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: task.getFinished ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          Text(
                            task.courseName,
                            style: TextStyle(
                              decoration: task.getFinished ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('截止日期: ${task.getDeadline.toString()}'),
                      Text('地点: ${task.getLocation}'),
                      Text('简介: ${task.getDescription}'),
                    ],
                  ),
                  trailing: Checkbox(
                    value: task.getFinished,
                    onChanged: (value) async {
                      setState(() {
                        task.getFinished ? task.setUnfinished() : task.setFinished();
                      });
                      TaskDB taskDB = TaskDB();
                      await taskDB.updateFinished(task);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getTaskIcon(TaskType taskType) {
    switch (taskType) {
      case TaskType.homework:
        return Icons.assignment;
      case TaskType.lab:
        return Icons.science;
      case TaskType.private:
        return Icons.person;
      default:
        return Icons.task;
    }
  }
}
