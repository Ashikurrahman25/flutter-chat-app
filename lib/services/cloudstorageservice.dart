import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  static CloudStorageService instance = new CloudStorageService();

  FirebaseStorage _storage;
  StorageReference baseStorage;

  String profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    baseStorage = _storage.ref();
  }

  Future<StorageTaskSnapshot> uploadProfilePic(String uID, File _image) {
    try {
      return baseStorage
          .child(profileImages)
          .child(uID)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e);
    }
  }

  Future<StorageTaskSnapshot> mediaMessage(String uid, File _file) {
    var _timestamp = DateTime.now();
    var _fileName = basename(_file.path);
    _fileName += "_${_timestamp.toString()}";

    try {
      return baseStorage
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file)
          .onComplete;
    } catch (e) {
      print(e);
    }
  }
}
