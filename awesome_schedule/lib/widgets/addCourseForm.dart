import 'package:awesome_schedule/models/courseList.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:awesome_schedule/database/courseList_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_schedule/models/course.dart';
import 'package:awesome_schedule/providers/CourseNotifier.dart';
import 'package:provider/provider.dart';

class AddCourseDialog extends StatefulWidget {
  @override
  _AddCourseDialogState createState() => _AddCourseDialogState();
}


class _AddCourseDialogState extends State<AddCourseDialog> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// 选择周数
  /// 5 * 4 的矩阵
  Widget buildWeekSelection() {

    return Column(
      children: List.generate(4, (rowIndex) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (colIndex) {
          int index = rowIndex * 5 + colIndex;
          var courseFormProvider = context.watch<CourseFormProvider>();
          return GestureDetector(
            onTap: () {
              courseFormProvider.toggleWeekSelection(index);
            },
            child: Container(
              width: 40, // 设置元素的宽度
              height: 40, // 设置元素的高度
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: courseFormProvider.selectedWeeks[index] ? Colors.blue : Colors.transparent,
                border: Border.all(
                  color: courseFormProvider.selectedWeeks[index] ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text('${index + 1}', style: TextStyle(color: courseFormProvider.selectedWeeks[index] ? Colors.white : Colors.black)), // 只显示数字
            ),
          );
        }),
      )),
    );
  }
  /// 快捷选择按钮
  Row buildShortcutButtons() {
    var courseFormProvider = context.read<CourseFormProvider>();
    List<bool> _selectedWeeks = courseFormProvider.selectedWeeks;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          child: Text('全部'),
          onPressed: () {
            setState(() {
              for (int i = 0; i < 20; i++) {
                _selectedWeeks[i] = true;
              }
            });
          },
        ),
        ElevatedButton(
          child: Text('单周'),
          onPressed: () {
            setState(() {
              for (int i = 0; i < 20; i++) {
                _selectedWeeks[i] = (i % 2 == 0);
              }
            });
          },
        ),
        ElevatedButton(
          child: Text('双周'),
          onPressed: () {
            setState(() {
              for (int i = 0; i < 20; i++) {
                _selectedWeeks[i] = (i % 2 != 0);
              }
            });
          },
        ),
      ],
    );
  }

  /// 选择周几+节数
  final List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  Widget buildTimeSelection() {
    var courseFormProvider = context.read<CourseFormProvider>();
    int _selectedDay = courseFormProvider.selectedDay;
    return Column(
      children: [
        DropdownButton<int>(
          value: _selectedDay,
          items: List.generate(7, (index) => DropdownMenuItem<int>(
            value: index + 1,
            child: Text(weekdays[index]),
          )),
          onChanged: (int? newValue) {
            setState(() {
              courseFormProvider.selectedDay = newValue!;
            });
          },
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 150, // 设置CupertinoPicker的高度
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  useMagnifier: true,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      courseFormProvider.selectedStartPeriod = index + 1;
                    });
                  },
                  children: List.generate(12, (index) => Text('第${index + 1}节')),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 150, // 设置CupertinoPicker的高度
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      courseFormProvider.selectedEndPeriod = index + 1;
                    });
                  },
                  children: List.generate(12, (index) => Text('第${index + 1}节')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 创建输入框
  Widget buildInputField({required String title, required bool isRequired, required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        labelText: title,
      ),
      validator: (value) {
        if (isRequired && value!.isEmpty) {
          return '此项为必填项';
        }
        return null;
      },
    );
  }

  /// 创建错误弹窗
  AlertDialog createAlertDialog(BuildContext context, String content) {
    return AlertDialog(
      title: const Text('错误'),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text('确定'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  late CourseNotifier courseNotifier;

  @override
  Widget build(BuildContext context) {
    /// 判断添加的课程是否与已有课程时间冲突
    courseNotifier = Provider.of<CourseNotifier>(context);
    var courseSet = courseNotifier.courses;

    bool isTimeConflict(Course newCourse) {
      for (var course in courseSet) {
        for (var existingTimeInfo in course.getCourseTimeInfo) {
          for (var newTimeInfo in newCourse.getCourseTimeInfo) {
            if (newTimeInfo.getWeekList.asMap().entries.any((entry) => entry.value && existingTimeInfo.getWeekList[entry.key]) &&
                newTimeInfo.weekday == existingTimeInfo.weekday &&
                ((newTimeInfo.startSection >= existingTimeInfo.startSection && newTimeInfo.startSection <= existingTimeInfo.endSection) ||
                    (newTimeInfo.endSection >= existingTimeInfo.startSection && newTimeInfo.endSection <= existingTimeInfo.endSection))) {
              return true;
            }
          }
        }
      }
      return false;
    }

    return AlertDialog(
      title: const Text('添加课程'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: [
              const SizedBox(height: 10),
              const Text('必填', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              buildInputField(title: '课程名称', isRequired: true, controller: _courseNameController),
              const SizedBox(height: 10),

              const Text('选择周数'),
              buildWeekSelection(),
              buildShortcutButtons(),
              const SizedBox(height: 10),
              const Text('选择时间'),
              const SizedBox(height: 10),
              buildTimeSelection(),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  var courseFormProvider = context.read<CourseFormProvider>();
                  List<int> selectedWeeksIndices = courseFormProvider.selectedWeeks.asMap().entries.where((entry) => entry.value).map((entry) => entry.key + 1).toList();
                  /// 周数不能为空
                  if (selectedWeeksIndices.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return createAlertDialog(context, '请选择周数');
                      },
                    );
                    return;
                  }
                  if (courseFormProvider.selectedStartPeriod > courseFormProvider.selectedEndPeriod) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return createAlertDialog(context, '开始节数不能大于结束节数');
                      },
                    );
                  }
                  else {
                    var newTimeSelection = CourseTimeInfo(
                      0,
                      0,
                      0,
                      0,
                      endWeek: 20,
                      weeks: selectedWeeksIndices,
                      weekday: courseFormProvider.selectedDay,
                      startSection: courseFormProvider.selectedStartPeriod,
                      endSection: courseFormProvider.selectedEndPeriod,
                    );
                    courseFormProvider.addTimeSelection(newTimeSelection);
                  }
                },
                child: const Text('添加时间'),
              ),
              const SizedBox(height: 10),
              Column(
                children: context.watch<CourseFormProvider>().timeSelections.map((timeSelection) {
                  int index = context.watch<CourseFormProvider>().timeSelections.indexOf(timeSelection);
                  return ListTile(
                    title: (timeSelection.startSection == timeSelection.endSection)
                        ? Text('${weekdays[timeSelection.weekday - 1]}, 第${timeSelection.startSection}节')
                        : Text('${weekdays[timeSelection.weekday - 1]}, 第${timeSelection.startSection} - ${timeSelection.endSection}节'),
                    subtitle: Text('${timeSelection.getWeekListStrFormat}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        var courseFormProvider = context.read<CourseFormProvider>();
                        courseFormProvider.removeTimeSelection(timeSelection);
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),
              const Text('选填', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              buildInputField(title: '老师', isRequired: false, controller: _teacherController),
              const SizedBox(height: 10),
              buildInputField(title: '地点', isRequired: false, controller: _locationController),
              const SizedBox(height: 10),
              buildInputField(title: '备注', isRequired: false, controller: _noteController),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.red),
          ),
          onPressed: () {
            _courseNameController.clear();
            _teacherController.clear();
            _locationController.clear();
            _noteController.clear();
            var courseFormProvider = context.read<CourseFormProvider>();
            courseFormProvider.clear();
          },
          child: const Text('清空'),
        ),
        TextButton(
          child: const Text('添加'),
          onPressed: () {
              if (_formKey.currentState!.validate()) {
              /// 创建新课程
              var courseFormProvider = context.read<CourseFormProvider>();
              List<bool> _selectedWeeks = courseFormProvider.selectedWeeks;
              int _selectedDay = courseFormProvider.selectedDay;
              int _selectedStartPeriod = courseFormProvider.selectedStartPeriod;
              int _selectedEndPeriod = courseFormProvider.selectedEndPeriod;
                print(courseFormProvider.timeSelections[0].getWeekListStrFormat);
                var newCourse = Course(
                    _courseNameController.text,
                    courseFormProvider.timeSelections,
                    location: _locationController.text,
                    teacher: _teacherController.text,
                    description: _noteController.text);
                if (!isTimeConflict(newCourse)) {
                  courseNotifier.addCourse(newCourse);
                  CourseListDB courseListDB = CourseListDB();
                  courseListDB.addCourseToCourseListByID(currentCourseListID, newCourse);
                  Navigator.of(context).pop();
                }
                else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return createAlertDialog(context, "课程时间冲突");
                    },
                  );
                }
              }
            }
        ),
      ],
    );
  }
}