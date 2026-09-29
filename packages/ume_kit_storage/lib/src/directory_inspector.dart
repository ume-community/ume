import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryInspectorPage extends StatelessWidget {
  const DirectoryInspectorPage({super.key, required this.directory});

  final Directory directory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(directory.path)),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: directory.list().toList(),
        builder: (context, snapshot) {
          return ListView.builder(itemBuilder: (context, index) {
            return ListTile(title: Text(snapshot.data?[index].path ?? ''));
          });
        },
      ),
    );
  }
}
