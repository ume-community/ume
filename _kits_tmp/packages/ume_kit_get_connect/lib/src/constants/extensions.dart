/*
 * @Author: zdd
 * @Date: 2023-12-21 09:38:24
 * @LastEditors: zdd dongdong@grizzlychina.com
 * @LastEditTime: 2023-12-21 09:42:19
 * @FilePath: extensions.dart
 */
///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 13:58
///
import 'package:get/get.dart' show Response;

import 'constants.dart';

extension ResponseExtension on Response<dynamic> {
  int get startTimeMilliseconds =>
      int.parse((request?.headers[GET_EXTRA_START_TIME] ?? '0'));

  int get endTimeMilliseconds =>
      int.parse(request?.headers[GET_EXTRA_END_TIME] ?? '0');

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimeMilliseconds);

  DateTime get endTime =>
      DateTime.fromMillisecondsSinceEpoch(endTimeMilliseconds);
}
