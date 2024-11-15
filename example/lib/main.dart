import 'package:dio/dio.dart';
import 'package:example/custom_router_pluggable.dart';
import 'package:example/detail_page.dart';
import 'package:example/home_page.dart';
import 'package:example/ume_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ume/ume.dart';
import 'package:ume_kit_channel_monitor/ume_kit_channel_monitor.dart';
import 'package:ume_kit_channel_observer/ume_kit_channel_observer.dart';
import 'package:ume_kit_clean_local_data/ume_kit_clean_local_data.dart';
import 'package:ume_kit_console/ume_kit_console.dart';
import 'package:ume_kit_database_kit/ume_kit_database_kit.dart';
import 'package:ume_kit_designer_check/ume_kit_designer_check.dart';
import 'package:ume_kit_device/ume_kit_device.dart';
import 'package:ume_kit_dio/ume_kit_dio.dart';
import 'package:ume_kit_get_connect/ume_kit_get_connect.dart';
import 'package:ume_kit_memory_detector/ume_kit_memory_detector.dart';
import 'package:ume_kit_monitor/ume_kit_monitor.dart';
import 'package:ume_kit_perf/ume_kit_perf.dart';
import 'package:ume_kit_shared_preferences/ume_kit_shared_preferences.dart';
import 'package:ume_kit_show_code/ume_kit_show_code.dart';
import 'package:ume_kit_slow_animation/ume_kit_slow_animation.dart';
import 'package:ume_kit_ui/ume_kit_ui.dart';

final Dio dio = Dio()..options = BaseOptions(connectTimeout: 10000);
final GetConnect get_connect = GetConnect();

final navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const UMEApp());

class UMEApp extends StatefulWidget {
  const UMEApp({Key? key}) : super(key: key);

  @override
  State<UMEApp> createState() => _UMEAppState();
}

class _UMEAppState extends State<UMEApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomRouterPluggable().navKey = navigatorKey;
    });
    if (kDebugMode) {
      PluginManager.instance
        // Channel monitor
        ..register(ChannelMonitor())

        // Channel observer
        ..register(ChannelObserver())

        // Clean local data
        ..register(DataCleanPanel())

        // Console
        ..register(Console())

        // Database
        ..register(DatabasePanel(databases: []))

        // Designer check
        ..register(DesignerCheck())

        // Device
        ..register(CpuInfoPage())
        ..register(DeviceInfoPanel())

        // Dio
        ..register(DioInspector(dio: dio))

        // GetConnect
        ..register(GetConnectInspector(connect: get_connect))

        // Memory detector
        ..register(MemoryDetectorButton())

        // Monitor
        ..register(MonitorPlugin())

        // Perf
        ..register(Performance())
        ..register(MemoryInfoPage())

        // SharedPreferences
        ..register(SharedPreferencesInspector())

        // Show code
        ..register(ShowCode())

        // Slow animation
        ..register(SlowAnimation())
        // UI inspector
        ..register(WidgetInfoInspector())
        ..register(WidgetDetailInspector())
        ..register(ColorSucker())
        ..register(AlignRuler())
        ..register(ColorPicker())
        ..register(TouchIndicator())

        // Custom router
        ..register(CustomRouterPluggable());
    }
  }

  Widget _buildApp(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'UME Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(title: 'UME Demo Home Page'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'detail':
            return MaterialPageRoute(builder: (_) => const DetailPage());
          default:
            return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = _buildApp(context);
    if (kDebugMode) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UMESwitch()),
        ],
        builder: (BuildContext context, _) => UMEWidget(
          enable: context.watch<UMESwitch>().enable,
          child: body,
        ),
      );
    }
    return body;
  }
}
