import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import '../constants/constants.dart';
import '../instances.dart';

int get _timestamp => DateTime.now().millisecondsSinceEpoch;

/// Main idea about this interceptor:
///  - Use [RequestOptions.extra] to store our timestamps.
///  - Add [GET_EXTRA_START_TIME] when a request was requested.
///  - Add [GET_EXTRA_END_TIME] when a response is respond or thrown an error.
///  - Deliver the [Response] to the container.
class UMEGetConnectInspector {
  static Request requestInterceptor(Request request) {
    request.headers[GET_EXTRA_START_TIME] = _timestamp.toString();
    return request;
  }

  static Response responseInterceptor(Request request, Response response) {
    request.headers[GET_EXTRA_END_TIME] = _timestamp.toString();
    InspectorInstance.httpContainer.addRequest(response);
    return response;
  }
}
