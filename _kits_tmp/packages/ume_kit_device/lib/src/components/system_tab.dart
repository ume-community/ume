import 'package:device_info_plus/device_info_plus.dart';

import 'tab_template.dart';

class SystemTab extends TabTemplate {
  const SystemTab({super.key});
  @override
  Future<List<ListTileItem>> getItemList() async {
    final systemInfo = await DeviceInfoPlugin().deviceInfo;
    return _parseData(systemInfo.data);
  }

  List<ListTileItem> _parseData(Map<String, dynamic> data) {
    return data.entries
        .map((e) => ListTileItem(title: e.key, subtitle: e.value.toString()))
        .toList();
  }
}
