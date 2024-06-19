export './noteListPage.dart';
import 'package:awesome_schedule/database/note_db.dart';
import 'package:awesome_schedule/models/note.dart';
import 'package:awesome_schedule/utils/common.dart';
import 'package:flutter/material.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});
  
  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late Future<List<Note>> _notesFuture;
  
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as NoteListArguments;
    NoteDB noteDB = NoteDB();
    _notesFuture = noteDB.getNotesByCourseId(args.course.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("${args.course.getName}的课程笔记"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 进入笔记页，创建新笔记
              Note newNote = Note('新笔记', DateTime.now());
              newNote.courseId = args.course.id;
              Navigator.pushNamed(context, '/note', arguments: NoteArguments(newNote));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('没有笔记'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final note = snapshot.data![index];
                return ListTile(
                  title: Text(note.getTitle),
                  subtitle: Text(note.getUpdateTime.toString()),
                  onTap: () {
                    // 进入编辑对应笔记页
                    Navigator.pushNamed(context, '/note', arguments: NoteArguments(note));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}