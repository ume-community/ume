import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<Directory> getAppDirectory() async {
    Directory tempDir;
    //web 居然isMacos为true
    debugPrint(
        'Platform.isIOS=${Platform.isIOS},Platform.isMacOS=${Platform.isMacOS}, GeneralPlatform.isWeb=${Platform.isWindows}');
    if (Platform.isIOS || Platform.isMacOS) {
      tempDir = await getApplicationDocumentsDirectory();
    } else {
      tempDir = (await getExternalStorageDirectory())!;
    }
    String tempPath = tempDir.path + "/";
    Directory file = new Directory(tempPath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  static Future<Directory> getAppApkDirectory() async {
    Directory tempDir;
    if (Platform.isIOS) {
      tempDir = await getApplicationDocumentsDirectory();
    } else {
      tempDir = (await getExternalStorageDirectory())!;
    }
    String tempPath = tempDir.path + "/apk";
    Directory file = new Directory(tempPath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  static Future<File> getImageFileFromAssets(ByteData byteData, {String? name, String? dirName = 'localImgs'}) async {
    // Store the picture in the temp directory.
    // Find the temp directory using the `path_provider` plugin.
    String path = (await getAppDirectory()).path + "$dirName/";
    Directory _dir = Directory(path);
    if (!_dir.existsSync()) _dir.createSync();
    final file = File("${_dir.path}" + '${name ?? DateTime.now().millisecond}.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  static Future<File> getImageFileFromUnit8list(Uint8List unit8list,
      {String? name, String? dirName = 'localImgs'}) async {
    // Store the picture in the temp directory.
    // Find the temp directory using the `path_provider` plugin.
    String path = (await getAppDirectory()).path + "$dirName/";
    Directory _dir = Directory(path);
    if (!_dir.existsSync()) _dir.createSync();
    final file = File("${_dir.path}" + '${name ?? DateTime.now().millisecond}.jpg');
    await file.writeAsBytes(unit8list);
    return file;
  }
}
