import 'package:awesome_schedule/utils/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/courseList_db.dart';
import '../models/course.dart';
import '../models/timeInfo.dart';
import '../providers/CourseNotifier.dart';



/// 课程信息弹窗
class CourseInfoDialog extends StatefulWidget {
  final Course course;
  final CourseTimeInfo timeInfo;
  final CourseNotifier courseNotifier;

  CourseInfoDialog({
    required this.course,
    required this.timeInfo,
    required this.courseNotifier,
  });

  @override
  _CourseInfoDialogState createState() => _CourseInfoDialogState();
}

class _CourseInfoDialogState extends State<CourseInfoDialog> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course.getName);
    _teacherController = TextEditingController(text: widget.course.getTeacher);
    _locationController = TextEditingController(text: widget.course.getLocation);
    _descriptionController = TextEditingController(text: widget.course.getDescription);


  }

  /// 选择周数
  /// 5 * 4 的矩阵
  Widget buildWeekSelection() {
    return Column(
      children: List.generate(4, (rowIndex) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (colIndex) {
            int index = rowIndex * 5 + colIndex;
            var courseFormProvider = context.watch<CourseFormProvider>();
            return GestureDetector(
              onTap: () {
                /// 点击后切换选中状态
                courseFormProvider.toggleWeekSelection(index);
                /// 如果选中周数符合某种模式，则更新选中的周数模式
                bool isAll = courseFormProvider.selectedWeeks.every((week) => week);
                bool isOdd = courseFormProvider.selectedWeeks.asMap().entries.every((entry) => (entry.key % 2 == 0) == entry.value);
                bool isEven = courseFormProvider.selectedWeeks.asMap().entries.every((entry) => (entry.key % 2 != 0) == entry.value);
                if (isAll) {
                  courseFormProvider.selectedWeekPattern = WeekPattern.all;
                } else if (isOdd) {
                  courseFormProvider.selectedWeekPattern = WeekPattern.odd;
                } else if (isEven) {
                  courseFormProvider.selectedWeekPattern = WeekPattern.even;
                } else {
                  courseFormProvider.selectedWeekPattern = WeekPattern.none;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOut,
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: courseFormProvider.selectedWeeks[index]
                      ? CupertinoTheme.of(context).primaryColor
                      : Colors.transparent,
                  boxShadow: courseFormProvider.selectedWeeks[index]
                      ? [
                    BoxShadow(
                      color: CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: courseFormProvider.selectedWeeks[index]
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
              ),
            );
          }),
        ),
      )),
    );
  }
  /// 快捷选择按钮
  Widget buildShortcutButtons() {
    var courseFormProvider = context.watch<CourseFormProvider>();
    List<bool> _selectedWeeks = courseFormProvider.selectedWeeks;
    WeekPattern _selectedWeekPattern = courseFormProvider.selectedWeekPattern;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ToggleButtons(
          isSelected: [
            _selectedWeekPattern == WeekPattern.all,
            _selectedWeekPattern == WeekPattern.odd,
            _selectedWeekPattern == WeekPattern.even,
          ],
          onPressed: (int index) {
            setState(() {
              WeekPattern newPattern;
              switch (index) {
                case 0:
                  newPattern = WeekPattern.all;
                  break;
                case 1:
                  newPattern = WeekPattern.odd;
                  break;
                case 2:
                  newPattern = WeekPattern.even;
                  break;
                default:
                  newPattern = WeekPattern.none;
              }
              if (_selectedWeekPattern == newPattern) {
                _selectedWeekPattern = WeekPattern.none;
                courseFormProvider.selectedWeekPattern = WeekPattern.none;
                for (int i = 0; i < 20; i++) {
                  _selectedWeeks[i] = false;
                }
              } else {
                _selectedWeekPattern = newPattern;
                courseFormProvider.selectedWeekPattern = newPattern;
                for (int i = 0; i < 20; i++) {
                  _selectedWeeks[i] = (newPattern == WeekPattern.all) || ((i % 2 == 0) == (newPattern == WeekPattern.odd));
                }
              }
            });
          },
          children: const <Widget>[
            Text('全部'),
            Text('单周'),
            Text('双周'),
          ],
        ),
      ],
    );
  }
  /// 选择周几+节数
  final List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];
  Widget buildTimeSelection() {
    var courseFormProvider = context.watch<CourseFormProvider>();
    int _selectedDay = courseFormProvider.selectedDay;
    return Column(
      children: [
        CupertinoSegmentedControl<int>(
          children: { for (var index in List.generate(7, (index) => index + 1))
            index : Padding(
              padding: const EdgeInsets.all(7.0),
              child: Text("周\n${weekdays[index - 1]}"),
            ),
          },
          groupValue: _selectedDay,
          onValueChanged: (int? newValue) {
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
                  scrollController: FixedExtentScrollController(initialItem: courseFormProvider.selectedStartPeriod - 1),
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
                  scrollController: FixedExtentScrollController(initialItem: courseFormProvider.selectedEndPeriod - 1),
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
      title: const Text('课程信息'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child:  ListBody(
            children: [
              const SizedBox(height: 10),
              if (_isEditing)
                buildInputField(
                  title: '课程名称',
                  isRequired: true,
                  controller: _nameController,
                )
              else
                ListTile(
                  title: const Text('课程名称'),
                  subtitle: Text(widget.course.getName),
                ),
              const SizedBox(height: 10),
              if (_isEditing)
                buildInputField(
                  title: '教师',
                  isRequired: false,
                  controller: _teacherController,
                )
              else
                ListTile(
                  title: const Text('教师'),
                  subtitle: Text(widget.course.getTeacher),
                ),
              const SizedBox(height: 10),
              if (_isEditing)
                buildInputField(
                  title: '地点',
                  isRequired: false,
                  controller: _locationController,
                )
              else
                ListTile(
                  title: const Text('地点'),
                  subtitle: Text(widget.course.getLocation),
                ),
              const SizedBox(height: 10),
              if (_isEditing)
                buildInputField(
                  title: '简介',
                  isRequired: false,
                  controller: _descriptionController,
                )
              else
                ListTile(
                  title: const Text('简介'),
                  subtitle: Text(widget.course.getDescription),
                ),
              const SizedBox(height: 10),
              if (!_isEditing)
                ListBody(
                  children: [
                    ListTile(
                      title: const Text('时间'),
                      subtitle: Text('周${weekdays[widget.timeInfo.getWeekday - 1]} 第${widget.timeInfo.getStartSection} - ${widget.timeInfo.getEndSection}节'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              if (_isEditing)
                ListBody(
                  children: [
                    const Text('选择周数'),
                    buildWeekSelection(),
                    const SizedBox(height: 10,),
                    buildShortcutButtons(),
                    const SizedBox(height: 10,),
                    const Text('选择时间'),
                    const SizedBox(height: 10,),
                    buildTimeSelection(),
                  ],
                )
              else
                ListTile(
                  title: const Text('周数'),
                  subtitle: Text(widget.timeInfo.getWeekListStrFormat),
                ),
            ],
          ),
        )
      ),
      actions: <Widget>[
        if (!_isEditing)
          // 编辑笔记按钮
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/noteList', arguments: NoteListArguments(widget.course));
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            child: const Text('课程笔记')
          ),
        if (_isEditing)
        /// 取消按钮
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
              var courseFormProvider = context.read<CourseFormProvider>();
              courseFormProvider.initFromCourseTimeInfo(widget.timeInfo);
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.grey),
            ),
            child: const Text('取消')
          )
        else
        /// 删除按钮
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('你确定要删除这个课程吗？'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Colors.red),
                        ),
                        onPressed: () {
                          widget.courseNotifier.removeCourse(widget.course);
                          Navigator.of(context).pop(); // 关闭确认删除对话框
                          Navigator.of(context).pop(); // 关闭课程信息对话框
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.red),
            ),
            child: const Text('删除'),
          ),
        if (_isEditing)
          /// 保存按钮
          TextButton(
            child: const Text('保存'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String oldName = widget.course.getName;
                widget.course.setName = _nameController.text;
                widget.course.setTeacher = _teacherController.text;
                widget.course.setLocation = _locationController.text;
                widget.course.setDescription = _descriptionController.text;
                widget.timeInfo.setWeekday = context.read<CourseFormProvider>().selectedDay;
                widget.timeInfo.setStartSection = context.read<CourseFormProvider>().selectedStartPeriod;
                widget.timeInfo.setEndSection = context.read<CourseFormProvider>().selectedEndPeriod;
                setState(() {
                  _isEditing = false;
                });
                widget.courseNotifier.refresh(widget.course);
              }
            },
          )
        else
          /// 编辑按钮
          TextButton(
            child: const Text('编辑'),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),

      ],
    );
  }
}