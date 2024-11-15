import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension FileExt on File {
  String get name {
    String path = this.path;
    int index = path.lastIndexOf(Platform.pathSeparator);
    String name = path.substring(index + 1, path.length);
    return name;
  }
}

class InnerUtils {
  // md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  static bool isEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 输入字符串是否是JSON
  static bool isJson(String? content) {
    if (content == null) return false;
    try {
      jsonDecode(content);
    } catch (error) {
      print("input is not json: ${error.toString()}");
      return false;
    }
    return true;
  }

  static void jumpLink(String? link) async {
    if (InnerUtils.isEmpty(link)) return;
    var url = link;
    if (!link!.startsWith("http") && !link.startsWith("https")) {
      url = "https://$link";
    }

    if (await canLaunchUrlString(url!)) {
      await launchUrlString(url);
    } else {
      showToast("url not exit!");
    }
  }
}
