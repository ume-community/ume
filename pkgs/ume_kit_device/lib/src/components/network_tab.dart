import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'tab_template.dart';

class NetworkTab extends TabTemplate {
  const NetworkTab({super.key});

  @override
  Future<List<ListTileItem>> getItemList() async {
    return [
      ListTileItem(
        title: 'Connectivity',
        subtitle: '${await Connectivity().checkConnectivity()}',
        icon: Icons.network_check,
      ),
      ListTileItem(
        title: 'Network name',
        subtitle: '${await NetworkInfo().getWifiName()}',
        icon: Icons.text_fields,
      ),
      ListTileItem(
        title: 'BSSID',
        subtitle: '${await NetworkInfo().getWifiBSSID()}',
        icon: Icons.text_fields,
      ),
      ListTileItem(
        title: 'IP address',
        subtitle: '${await NetworkInfo().getWifiIP()}',
        icon: Icons.label,
      ),
      ListTileItem(
        title: 'MAC address',
        subtitle: '${await NetworkInfo().getWifiIPv6()}',
        icon: Icons.network_check,
      ),
      ListTileItem(
        title: 'Submask',
        subtitle: '${await NetworkInfo().getWifiSubmask()}',
        icon: Icons.network_check,
      ),
      ListTileItem(
        title: 'Broadcast',
        subtitle: '${await NetworkInfo().getWifiBroadcast()}',
        icon: Icons.podcasts,
      ),
      ListTileItem(
        title: 'Gateway',
        subtitle: '${await NetworkInfo().getWifiGatewayIP()}',
        icon: Icons.router,
      ),
    ];
  }
}
