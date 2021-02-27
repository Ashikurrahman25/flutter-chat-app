import 'package:flutter/cupertino.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<File> getImage() {
    return ImagePicker.pickImage(source: ImageSource.gallery);
  }
}
