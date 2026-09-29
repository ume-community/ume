import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'tab_template.dart';

class PackageTab extends TabTemplate {
  const PackageTab({super.key});

  @override
  Future<List<ListTileItem>> getItemList() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return [
      ListTileItem(
        title: 'App Name',
        subtitle: packageInfo.appName,
        icon: Icons.app_registration,
      ),
      ListTileItem(
        title: 'Package Name',
        subtitle: packageInfo.packageName,
        icon: Icons.app_registration,
      ),
      ListTileItem(
        title: 'Version',
        subtitle: packageInfo.version,
        icon: Icons.app_registration,
      ),
      ListTileItem(
        title: 'Build Number',
        subtitle: packageInfo.buildNumber,
        icon: Icons.app_registration,
      ),
      ListTileItem(
        title: 'Build Signature',
        subtitle: packageInfo.buildSignature,
        icon: Icons.app_registration,
      ),
      ListTileItem(
        title: 'Installer Store',
        subtitle: packageInfo.installerStore ?? 'Unknown',
        icon: Icons.app_registration,
      ),
    ];
  }
}
