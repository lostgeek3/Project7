import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_schedule/temp/scheduleDemo.dart';
import 'package:awesome_schedule/models/course.dart';

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

  // 课程的周数
  List<bool> _selectedWeeks = List<bool>.filled(20, false);
  // 周几
  int _selectedDay = 1;
  // 开始节数
  int _selectedStartPeriod = 1;
  // 结束节数
  int _selectedEndPeriod = 1;
  Widget buildWeekSelection() {
    return Column(
      children: List.generate(4, (rowIndex) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (colIndex) {
          int index = rowIndex * 5 + colIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWeeks[index] = !_selectedWeeks[index];
              });
            },
            child: Container(
              width: 40, // 设置元素的宽度
              height: 40, // 设置元素的高度
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _selectedWeeks[index] ? Colors.blue : Colors.transparent,
                border: Border.all(
                  color: _selectedWeeks[index] ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text('${index + 1}', style: TextStyle(color: _selectedWeeks[index] ? Colors.white : Colors.black)), // 只显示数字
            ),
          );
        }),
      )),
    );
  }
  Row buildShortcutButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          child: Text('全部'),
          onPressed: () {
            setState(() {
              _selectedWeeks = List<bool>.filled(20, true);
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

  Widget buildTimeSelection() {
    List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
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
              _selectedDay = newValue!;
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
                      _selectedStartPeriod = index + 1;
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
                      _selectedEndPeriod = index + 1;
                    });
                  },
                  children: List.generate(12, (index) => Text('第${index + 1}节')),
                ),
              ),
            ),
          ],
        ),      ],
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加课程'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: [
              const SizedBox(height: 10),
              const Text('必填'),
              const SizedBox(height: 10),
              buildInputField(title: '课程名称', isRequired: true, controller: _courseNameController),
              const SizedBox(height: 10),
              const Text('选择周数'),
              const SizedBox(height: 10),
              buildWeekSelection(),
              buildShortcutButtons(),
              const SizedBox(height: 10),
              const Text('选择时间'),
              const SizedBox(height: 10),
              buildTimeSelection(),
              const SizedBox(height: 10),
              const Text('选填'),
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
          },
          child: const Text('清空'),
        ),
        TextButton(
          child: const Text('添加'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // 在这里添加添加课程的代码
              var newCourse = Course(_courseNameController.text, [], location: _locationController.text, teacher: _teacherController.text, description: _noteController.text);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}