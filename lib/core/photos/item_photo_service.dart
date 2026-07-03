import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ItemPhotoService {
  ItemPhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickPhoto(ImageSource source) {
    return _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
  }

  Future<String> saveItemPhoto({
    required String itemId,
    required XFile pickedFile,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(p.join(directory.path, 'item_photos'));
    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final extension = _safeExtension(p.extension(pickedFile.path));
    final filename =
        '${_safeFilePart(itemId)}_${DateTime.now().microsecondsSinceEpoch}$extension';
    final savedFile = File(p.join(photoDirectory.path, filename));
    await File(pickedFile.path).copy(savedFile.path);
    return savedFile.path;
  }

  String _safeExtension(String extension) {
    final normalized = extension.trim().toLowerCase();
    if (normalized.isEmpty || normalized.length > 8) {
      return '.jpg';
    }

    return normalized;
  }

  String _safeFilePart(String value) {
    final safeValue = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return safeValue.isEmpty ? 'item' : safeValue;
  }
}
