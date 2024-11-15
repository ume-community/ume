import 'dart:io';

import 'package:oktoast/oktoast.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

/// @date 18/9/21
/// describe:
class TelegramBot {
  static TelegramBot? _instance;

  factory TelegramBot() => _getInstance();

  static TelegramBot get instance => _getInstance();

  static TeleDart? teledart;
  static int? chatId;

  TelegramBot._internal() {}

  static void init(String token, int chatID) async {
    if (teledart == null) {
      TelegramBot.chatId = chatID;
      final username = (await Telegram(token).getMe()).username;
      var event = Event(username ?? "");
      teledart = TeleDart(token, event);
      teledart!.start();
    }
  }

  static TelegramBot _getInstance() {
    if (_instance == null) {
      _instance = TelegramBot._internal();
    }
    return _instance!;
  }

  void sendMessage(String message, {int? chatId}) {
    teledart?.sendMessage(chatId ?? TelegramBot.chatId, message).whenComplete(() {
      showToast("send success");
    }).catchError((error) {
      showToast(error.toString());
    });
  }

  void sendFile(File file, {String? caption}) {
    teledart?.sendDocument(chatId ?? TelegramBot.chatId, file, caption: caption).whenComplete(() {
      showToast("send success");
    }).catchError((error) {
      showToast(error.toString());
    });
  }

  void dispose() {
    teledart?.stop();
  }
}
