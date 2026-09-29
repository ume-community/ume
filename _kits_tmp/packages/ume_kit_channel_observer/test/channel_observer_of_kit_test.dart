import 'package:ume_kit_channel_observer/ume_kit_channel_observer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const OptionalMethodChannel channel =
      OptionalMethodChannel('ume_kit_channel_observer');

  ChannelObserverBinding.ensureInitialized() as ChannelObserverBinding;

  channel.invokeMethod('getPlatformVersion');

  test('testCustomChannelBinding', () async {
    expect(
        UmeKitChannelObserver.getBindingInstance()
            ?.popChannelRecorders()
            .length,
        inInclusiveRange(1, 20));
  });
}
