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
  final TextEditingController _markdownController = TextEditingController();
  final SignatureController _signatureController = SignatureController();
  bool _isHandwritten = false;
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_note.getNoteType == NoteType.Unedited) {
        _showEditModeDialog();
      }
      else {
        _isHandwritten = _note.getNoteType == NoteType.handwritten ? true : false;
      }
    });
  }

  void _showEditModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择编辑模式'),
          content: const Text('请选择笔记模式：'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _note.setNoteType = NoteType.markdown;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Markdown'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _note.setNoteType = NoteType.handwritten;
                });
                Navigator.of(context).pop();
              },
              child: const Text('手写'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as NoteArguments;
    _note = args.note;

    if (_note.getNoteType == NoteType.markdown) {
      _markdownController.text = _note.getContent;
    }

    return WillPopScope(
      onWillPop: () async {
        return await _showSaveDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_note.getTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveNote();
              },
            ),
          ],
        ),
        body: _isHandwritten ? Text('1') : Text('2'),
      ),
    );
  }

  Widget _buildMarkdownEditor() {
    return Column(
      children: [
        Expanded(
          child: Markdown(data: _markdownController.text),
        ),
        TextField(
          controller: _markdownController,
          maxLines: null,
          onChanged: (text) {
            _isEdited = true;
          },
        ),
      ],
    );
  }

  Widget _buildHandwrittenEditor() {
    return Column(
      children: [
        Expanded(
          child: Signature(
            controller: _signatureController,
            backgroundColor: Colors.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _signatureController.clear();
                _isEdited = true;
              },
              child: const Text('清除'),
            ),
          ],
        ),
      ],
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

  void _saveNote() {
    if (_isHandwritten) {
      // 手写模式下保存逻辑
      // 这里你可以添加保存手写笔记的逻辑
    } else {
      _note.setContent = _markdownController.text;
      // Markdown模式下保存逻辑
      // 这里你可以添加保存Markdown笔记的逻辑
    }
    _isEdited = false;
  }
}
