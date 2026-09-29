import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ume_core/ume_core.dart';
import 'package:ume_kit_monitor/monitor/overlay/overlay_panel.dart';

import 'monitor/overlay/overlay_action_panel.dart';

const String _pluginName = 'Monitor';
const String _pluginActionName = 'Actions';
const String _icon =
    r"iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAA3xJREFUeF7tm09IFFEcx79viQwJ3Pag0MH+6SEqO9SpUoNCKHS0P+5KmLNghw5pJEEE5b+CCMJIO3RQ2DUJd63UVQqkILU62SErOtj/Q6SHbYWQjNgXY806o6szO+3s7M68OSg8fu/9ft/P+73fe293h+Dfw3POfgA7AawV20z6/yuAMW/AXyroI8IfnnNSk4pdVpY34Cekiiv3E5ByKwKgoD2E55zfAGRZEQCASQGALP1veK6ZmsVp91mZPgaAZQBbAqwGpFwRDAa/4NfsTKSYrUxLh8ORrap4m6IIpiSAhUEL0xXLzKmaXhVGhmWA5QGomJyEmBiWAQlRp8IJA8COwuwuYI3LULRdR1B+5Xw7AyAloOo6nCx7uIoir2iiaRewPABFrClkoCkDUkifYqhJCUBYYsKj9kqrqHIZAwaAnQTZSdAcByHp1hzLBytJWQO0FDXLA9ACTehjmgxgADQSiHsGLHXtlMYXS5HSqEt1NwaAHYTYQcgcByHVi36BYdxrgNZAjOrHACgVQaNmxii/iz4UNSoQo/wuAlBZWWRULAnx29U1tPwuoAQgc0Mm0tJXRQaZnfmJqY9TMQf/cvw9piaDc/0ysxzYnrcp5jG0dEgaAIODzxEK/ZjTYLevRnHxLi16sHBCxEGWmpj/BqApyiidLA8gZZdAvDLAqHGiLQFr/1ja8j+XF1LR0i9MiGvR0q/MJKIgSbMsY00Gmq9flLmtP3MJ09+nI23C6yyJiCshTqq58pzfIBOioHUbs1FXXyvT19Lcis8f/n5JKjwrQHM7Aj3v9IaQEABVJa4DhNAHopi8HdtQXcPLtHW0eTH+4lWkjVJysHPA99AUANwlrhpKaKsoJn/fbhw9fkim7e7tXow+fhZpI5TUegZ8baYAwJc4e0FQJoo5UlmGgv17ZNpGHj3Fva6++TaKPu+AX05JBxq6LwF3aUU+peERaexNLRdgd9hlckLBEBrqLsvaCLEVePq7R3XQPZ9peg4ujM1zrnaAVot+cjfn4NS5k1Hd3rx6CxNvpXWPdHgDvhN6xqhbBrjLKtaHw2E3ARqkAg4fK0VhUX5UTcNDo7h/R3iDV7oS0GSz2Tyevu5PeoCIG4AqztlIKC0EIXv1CFSyPTyhhAx3BvyN8fATNwA853oN0C3xCEp5DPLGG/BtVbZTtmAAlBmps0jVJfAHffYC409RGhUAAAAASUVORK5CYII=";
final _iconMemory = base64Decode(_icon);

class MonitorPlugin implements Pluggable {
  const MonitorPlugin();

  @override
  String get displayName => _pluginName;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(_iconMemory);

  @override
  String get name => _pluginName;

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: OverlayPane(),
        )
      ],
    );
  }
}

class MonitorActionsPlugin implements Pluggable {
  const MonitorActionsPlugin();

  @override
  String get displayName => _pluginActionName;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(_iconMemory);

  @override
  String get name => _pluginActionName;

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) {
    return OverlayActionPanel();
  }
}
