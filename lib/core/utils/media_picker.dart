import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class MediaPicker {
  const MediaPicker();

  static const List<String> _documentExtensions = [
    'jpg',
    'jpeg',
    'png',
    'jfif',
  ];

  Future<String?> pickDocument() =>
      _pick(type: FileType.custom, extensions: _documentExtensions);

  Future<String?> pickPicture() => _pick(type: FileType.image);

  Future<String?> _pick({
    required FileType type,
    List<String>? extensions,
  }) async {
    try {
      final file = await FilePicker.pickFile(
        type: type,
        allowedExtensions: extensions,
      );
      return file?.path;
    } on PlatformException {
      return null;
    }
  }
}