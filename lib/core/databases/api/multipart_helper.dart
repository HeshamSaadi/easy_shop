import 'package:dio/dio.dart';

/// Builds a form-data file from a local path, or null when no file was picked.
/// Send the field only when it is not null, so the server keeps the old file.
Future<MultipartFile?> multipartFileOrNull(String? path) async {
  if (path == null) return null;
  return MultipartFile.fromFile(path);
}
