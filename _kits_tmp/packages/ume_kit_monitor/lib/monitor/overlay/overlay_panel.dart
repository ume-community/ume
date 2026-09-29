import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ume_kit_monitor/monitor/awesome_monitor.dart';
import 'package:ume_kit_monitor/monitor/page/curl_page.dart';
import 'package:ume_kit_monitor/monitor/page/error_page.dart';

/// @date 2020/12/17
/// describe:悬浮面板
class OverlayPane extends StatefulWidget {
  @override
  _OverlayPaneState createState() => _OverlayPaneState();
}

int _lastSelectPage = -1;

class _OverlayPaneState extends State<OverlayPane> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isFullScreen = false;

  double get _statusHeight => _isFullScreen ? MediaQuery.of(context).padding.top : 0;

  @override
  Widget build(BuildContext context) {
    List<String> tabs = Monitor.instance.tabs;
    if (_tabController == null || _tabController?.length != tabs.length) {
      if (_lastSelectPage < 0) {
        _lastSelectPage = tabs.indexOf('Curl');
        _lastSelectPage = _lastSelectPage >= 0 ? _lastSelectPage : 0;
      }
      _tabController = TabController(length: tabs.length, vsync: this, initialIndex: _lastSelectPage);
      _tabController?.addListener(() {
        _lastSelectPage = _tabController?.index ?? 0;
      });
    }
    double height = window.physicalSize.height / MediaQuery.of(context).devicePixelRatio;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            height: height / (_isFullScreen ? 1 : 2) - _statusHeight,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        labelPadding: EdgeInsets.symmetric(horizontal: 8),
                        isScrollable: true,
                        tabs: tabs.map((e) => Tab(text: e)).toList(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Monitor.instance.clear(tabs[_tabController?.index ?? 0]);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isFullScreen = !_isFullScreen);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: tabs.map(_buildPage).toList(),
                    controller: _tabController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(String tag) {
    if ('Error' == tag) {
      return ErrorPage(tag: tag);
    }
    return CurlPage(tag: tag);
  }
}
