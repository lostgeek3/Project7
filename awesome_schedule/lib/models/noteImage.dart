export './noteImage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// 笔记中的图片类
/// 存放笔记中的图片等信息
class NoteImage {
  late int id;
  // 笔记id
  late int noteId;
  // 图片名称
  String _name = '';
  // 图片内容
  Uint8List _image;

  NoteImage(this._name, this._image) {

  }

  set setName(String name) {
    _name = name;
  }
  set setImage(Uint8List image) {
    _image = image;
  }
  String get getName {
    return _name;
  }
  Uint8List get getImage {
    return _image;
  }
}