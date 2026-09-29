import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import 'tab_template.dart';

class BatteryTab extends TabTemplate {
  const BatteryTab({super.key});

  @override
  Future<List<ListTileItem>> getItemList() async {
    final battery = Battery();

    return [
      ListTileItem(
        title: 'Level',
        subtitle: '${await battery.batteryLevel}%',
        icon: Icons.battery_std,
      ),
      ListTileItem(
        title: 'State',
        subtitle: '${await battery.batteryState}',
        icon: Icons.battery_charging_full,
      ),
      ListTileItem(
        title: 'Save Mode',
        subtitle: '${await battery.isInBatterySaveMode}',
        icon: Icons.battery_saver,
      ),
    ];
  }
}
