import 'package:awesome_schedule/database/note_db.dart';
import 'package:awesome_schedule/models/note.dart';
import 'package:awesome_schedule/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:signature/signature.dart';
import 'package:logger/logger.dart';

export './notePage.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late Note _note;
  late bool _isNewNote;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _titleEditingController = TextEditingController();
  bool _isEdited = false;
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textEditingController.text = _note.getContent;
      _titleEditingController.text = _note.getTitle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as NoteArguments;
    _note = args.note;
    _isNewNote = args.isNewNote;

    return WillPopScope(
      onWillPop: () async {
        return await _showSaveDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isEditingTitle ? _buildTitleEditor() : _buildTitleDisplay(),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveNote();
              },
            ),
          ],
        ),
        body: _buildTextEditor(),
      ),
    );
  }

  Widget _buildTitleEditor() {
    return TextField(
      controller: _titleEditingController,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      autofocus: true,
      onSubmitted: (newTitle) {
        setState(() {
          _note.setTitle = newTitle;
          _isEditingTitle = false;
          _isEdited = true;
        });
      },
    );
  }

  Widget _buildTitleDisplay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditingTitle = true;
        });
      },
      child: Text(_note.getTitle),
    );
  }

  Widget _buildTextEditor() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            controller: _textEditingController,
            maxLines: null,
            onChanged: (text) {
              _isEdited = true;
            },
          ),
        ],
      )
    );
  }

  Future<bool> _showSaveDialog() async {
    if (_isEdited) {
      return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('保存笔记'),
            content: const Text('是否保存笔记？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('否'),
              ),
              TextButton(
                onPressed: () {
                  _saveNote();
                  Navigator.of(context).pop(true);
                },
                child: const Text('是'),
              ),
            ],
          );
        },
      ) ?? false;
    }
    return true;
  }

  void _saveNote() async {
    _note.setContent = _textEditingController.text;
    _note.setTitle = _titleEditingController.text;
    NoteDB noteDB = NoteDB();
    _note.setUpdateTime = DateTime.now();
    if (_isNewNote) {
      // 保存新笔记
      await noteDB.addNote(_note);
    }
    else {
      // 更新内容
      await noteDB.updateNote(_note);
    }
    _isEdited = false;
  }
}
