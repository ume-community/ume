import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ume_kit_monitor/monitor/page/log_recorder_detail_page.dart';
import 'package:ume_kit_monitor/monitor/telegram_bot.dart';
import 'package:ume_kit_monitor/monitor/utils/file_utils.dart';
import 'package:ume_kit_monitor/monitor/utils/inner_utils.dart';
import 'package:ume_kit_monitor/monitor/utils/navigator_util.dart';

/// @date 10/9/21
/// describe:

class ExceptionRecorderPage extends StatefulWidget {
  @override
  _ExceptionRecorderPageState createState() => _ExceptionRecorderPageState();
}

class _ExceptionRecorderPageState extends State<ExceptionRecorderPage> {
  List<FileSystemEntity>? _files = null;

  Directory? dir;

  @override
  void initState() {
    super.initState();
    TelegramBot.init('2030982018:AAFA94f4DKMFy_zFU1pEhAcJsVvVTdmUx1E', /*-1001157361480*/ -552609753);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FileUtils.getAppDirectory().then((dirs) {
        dir = Directory("${dirs.path}error/");
        if (dir!.existsSync()) {
          _files = dir!.listSync();
          if (_files != null && _files!.isNotEmpty) {
            setState(() {});
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exception Recorder"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete_forever, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              var file = mergeFiles(_files);
            },
            icon: Icon(Icons.send, color: Colors.black),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return ListView.separated(
      itemBuilder: (_, index) => _buildItem(_files![index] as File),
      separatorBuilder: _sepratorItem,
      itemCount: _files?.length ?? 0,
    );
  }

  Widget _sepratorItem(BuildContext context, int index) =>
      Divider(thickness: 1, height: 1, color: Theme.of(context).primaryColor);

  _buildItem(File file) {
    return InkWell(
      onTap: () => NavigatorUtil.pushPage(context, LogRecorderDetailPage(file)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        height: 100,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${file.name}", style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    child: Text("${file.path}", style: TextStyle(fontSize: 10)),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: file.path));
                      showToast("复制成功");
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                file.delete();
                _files?.remove(file);
                setState(() {});
              },
              icon: Icon(Icons.delete_forever, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                TelegramBot.instance.sendFile(file);
              },
              icon: Icon(Icons.send, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    TelegramBot.instance.dispose();
  }

  File? mergeFiles(List<FileSystemEntity>? files) {
    if (dir == null || files == null || files.isEmpty) return null;
    File mergeFile = File("${dir!.path}error/mergefile.txt");
    for (FileSystemEntity file in files) {
      if (file is File) {
        String data = file.readAsStringSync();
        mergeFile.writeAsString(data + "\n" + "=" * 60, mode: FileMode.append);
      }
    }
    return mergeFile;
  }
}
