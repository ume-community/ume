import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// import 'package:platform/platform.dart';

import 'tab_template.dart';

class PlatformTab extends TabTemplate {
  const PlatformTab({super.key});

  @override
  Future<List<ListTileItem>> getItemList() async {
    return [
      ListTileItem(
        title: 'Hostname',
        subtitle: Platform.localHostname,
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Locale',
        subtitle: Platform.localeName,
        icon: Icons.language,
      ),
      ListTileItem(
        title: 'Platform',
        subtitle: Platform.operatingSystem,
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Platform Version',
        subtitle: Platform.operatingSystemVersion,
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Version',
        subtitle: Platform.version,
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Environment',
        subtitle: Platform.environment.toString().replaceAll('\n', '\n\n'),
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Executable Arguments',
        subtitle: Platform.executableArguments.join('\n'),
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Processor Count',
        subtitle: Platform.numberOfProcessors.toString(),
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Script',
        subtitle: Platform.script.toString(),
        icon: Icons.computer,
      ),
      ListTileItem(
        title: 'Package Config',
        subtitle: Platform.packageConfig.toString(),
        icon: Icons.computer,
      ),
    ];
  }
}
