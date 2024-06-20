import 'package:awesome_schedule/models/course.dart';
import 'package:awesome_schedule/models/timeInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_schedule/widgets/addCourseForm.dart';
import 'package:provider/provider.dart';
import 'package:awesome_schedule/providers/CourseNotifier.dart';

class MockCourseNotifier with ChangeNotifier implements CourseNotifier {
  List<Course> _courses= [
    Course("高等数学",
        [CourseTimeInfo(8, 0, 9, 40,
            endWeek: 20,
            weekday: 1,
            startSection: 1,
            endSection: 2,
            weeks: [1, 3, 5, 7, 9, 11, 13, 15]),],
        courseID: 'MATH001',
        location: '教1-101',
        teacher: '张三',
        description: '这是一门数学课'),
  ];

  @override
  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }


  @override
  void initFromCurrentCourseList() {
    // TODO: implement initFromCurrentCourseList
  }

  @override
  void refresh(String oldName, Course newCourse) {
    // TODO: implement refresh
  }

  @override
  void removeCourse(Course course) {
    // TODO: implement removeCourse
  }

  @override
  List<Course> get courses => _courses;
}

void main() {
  var mockCourseNotifier = MockCourseNotifier();
  group('添加课程表单', () {
    testWidgets('添加课程测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      final context = tester.element(find.byType(MaterialApp));
      final courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);

      // Verify that the AddCourseDialog has the correct UI elements.
      expect(find.text('添加课程'), findsOneWidget);
      expect(find.text('必填'), findsOneWidget);
      expect(find.text('课程名称'), findsOneWidget);
      expect(find.text('选择周数'), findsOneWidget);
      expect(find.text('选择时间'), findsOneWidget);
      expect(find.text('添加时间'), findsOneWidget);
      expect(find.text('选填'), findsOneWidget);
      expect(find.text('老师'), findsOneWidget);
      expect(find.text('地点'), findsOneWidget);
      expect(find.text('备注'), findsOneWidget);
      expect(find.text('清空'), findsOneWidget);
      expect(find.text('添加'), findsOneWidget);

      // 输入课程名称
      await tester.enterText(find.byKey(InputTitleKey), '测试课程');
      expect(find.text('测试课程'), findsOneWidget);

      void expectWeekNotSelected(WidgetTester tester, int i) {
        expect(
          find.byWidgetPredicate(
                (Widget widget) =>
            widget is AnimatedContainer &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color == Colors.transparent &&
                (widget.decoration as BoxDecoration).boxShadow == null &&
                widget.child is Text &&
                (widget.child as Text).data == i.toString(),
          ),
          findsOneWidget,
        );
        // expect(courseFormProvider.selectedWeeks[i - 1], isFalse);
      }
      void expectWeekSelected(WidgetTester tester, int i) {
        expect(
          find.byWidgetPredicate(
                (Widget widget) =>
            widget is AnimatedContainer &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color != Colors.transparent &&
                (widget.decoration as BoxDecoration).boxShadow != null &&
                widget.child is Text &&
                (widget.child as Text).data == i.toString(),
          ),
          findsOneWidget,
        );
        // expect(courseFormProvider.selectedWeeks[i - 1], isTrue);
      }
      // 选中周数
      for (int i = 1; i <= 20; i++) {
        // 此时应该是未选中状态
        expectWeekNotSelected(tester, i);
        // 点击周数
        await tester.tap(find.text(i.toString()));
        await tester.pumpAndSettle();
        // 此时应该是选中状态
        expectWeekSelected(tester, i);
        // 再次点击周数
        await tester.tap(find.text(i.toString()));
        await tester.pumpAndSettle();
        // 此时应该是未选中状态
        expectWeekNotSelected(tester, i);
      }


      // 快捷选择周数
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.none);
      await tester.dragUntilVisible(
        find.text('全部'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('全部'));
      await tester.pumpAndSettle();
      for (int i = 1; i <= 20; i++) {
        expectWeekSelected(tester, i);
      }
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.all);
      await tester.tap(find.text('全部'));
      await tester.pumpAndSettle();
      for (int i = 1; i <= 20; i++) {
        expectWeekNotSelected(tester, i);
      }

      await tester.tap(find.text('单周'));
      await tester.pumpAndSettle();
      for (int i = 1; i <= 20; i++) {
        if (i % 2 == 0) {
          expectWeekNotSelected(tester, i);
        } else {
          expectWeekSelected(tester, i);
        }
      }
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.odd);

      await tester.tap(find.text('双周'));
      await tester.pumpAndSettle();
      for (int i = 1; i <= 20; i++) {
        if (i % 2 == 0) {
          expectWeekSelected(tester, i);
        } else {
          expectWeekNotSelected(tester, i);
        }
      }
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.even);

      // 选择周几
      expect(courseFormProvider.selectedDay, 1);
      await tester.dragUntilVisible(
        find.text('周一'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('周二'));
      await tester.pumpAndSettle();
      expect(courseFormProvider.selectedDay, 2);

      // 选择课程节数
      await tester.dragUntilVisible(
        find.byKey(PickerKey1),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      expect(courseFormProvider.selectedStartPeriod, 1);
      await tester.drag(find.byKey(PickerKey1), const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(courseFormProvider.selectedStartPeriod, 3);
      expect(courseFormProvider.selectedEndPeriod, 1);
      await tester.drag(find.byKey(PickerKey2), const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(courseFormProvider.selectedEndPeriod, 3);

      // 添加时间
      await tester.dragUntilVisible(
        find.text('添加时间'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('添加时间'));
      await tester.pumpAndSettle();

      // 添加课程
      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();
    });
    testWidgets('未输入课程名称', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      // 添加课程
      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();
      expect(find.text('此项为必填项'), findsOneWidget);
    });
    testWidgets('未选择周数', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      final context = tester.element(find.byType(MaterialApp));
      final courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);
      // 未选择周数直接点击添加时间
      await tester.dragUntilVisible(
        find.text('添加时间'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.none);
      await tester.tap(find.text('添加时间'));
      await tester.pumpAndSettle();
      expect(find.text('请选择周数'), findsOneWidget);
      // 关闭提示框
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.text('请选择周数'), findsNothing);
    });
    testWidgets('开始节数大于结束节数', (WidgetTester tester) async{
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      // 选择周数
      await tester.dragUntilVisible(
        find.text('全部'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('全部'));
      await tester.pumpAndSettle();
      // 将开始节数设为3，结束节数设为1
      await tester.dragUntilVisible(
        find.byKey(PickerKey1),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      final context = tester.element(find.byType(MaterialApp));
      final courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);
      await tester.drag(find.byKey(PickerKey1), const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(courseFormProvider.selectedStartPeriod, 3);
      expect(courseFormProvider.selectedEndPeriod, 1);
      // 点击添加时间
      await tester.dragUntilVisible(
        find.text('添加时间'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('添加时间'));
      await tester.pumpAndSettle();
      expect(find.text('开始节数不能大于结束节数'), findsOneWidget);
    });
    testWidgets('清空表单', (WidgetTester tester) async{
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      final context = tester.element(find.byType(MaterialApp));
      final courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);

      await tester.enterText(find.byKey(InputTitleKey), '测试课程');
      await tester.dragUntilVisible(
        find.text('全部'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('全部'));
      await tester.dragUntilVisible(
        find.text('添加时间'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('添加时间'));
      await tester.pumpAndSettle();
      expect(find.text('测试课程'), findsOneWidget);
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.all);

      await tester.tap(find.text('清空'));
      await tester.pumpAndSettle();
      expect(find.text('测试课程'), findsNothing);
      expect(courseFormProvider.selectedWeekPattern, WeekPattern.none);
    });
    testWidgets('删除时间段', (WidgetTester tester) async{
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      final context = tester.element(find.byType(MaterialApp));
      final courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);


      await tester.dragUntilVisible(
        find.text('全部'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('全部'));
      await tester.dragUntilVisible(
        find.text('添加时间'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('添加时间'));
      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsNothing);
    });
    testWidgets('时间冲突', (WidgetTester tester) async{
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CourseFormProvider())
          ],
          child: MaterialApp(
            home: AddCourseDialog(courseNotifier: mockCourseNotifier,),
          ),
        ),
      );
      final context = tester.element(find.byType(MaterialApp));
      final courseFormProvider = Provider.of<CourseFormProvider>(context, listen: false);

      await tester.enterText(find.byKey(InputTitleKey), '测试课程');
      await tester.dragUntilVisible(
        find.text('全部'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('全部'));
      await tester.dragUntilVisible(
        find.text('添加时间'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      await tester.tap(find.text('添加时间'));
      await tester.pumpAndSettle();

      // 点击添加
      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();
      expect(find.text('课程时间冲突'), findsOneWidget);
    });
  });
}