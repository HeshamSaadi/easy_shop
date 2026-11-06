import 'package:image_picker/image_picker.dart';

/// Lets a Cubit ask for an image without knowing about the plugin,
/// so tests can replace it with a fake.
abstract class ImagePickerService {
  /// Returns the file path, or null when the user cancels.
  Future<String?> pickImage();
}

class GalleryImagePickerService implements ImagePickerService {
  GalleryImagePickerService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  // Smaller files upload faster. The server's size limit is not tested yet.
  static const double _maxDimension = 1600;
  static const int _quality = 85;

  @override
  Future<String?> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _quality,
    );
    return file?.path;
  }
}
