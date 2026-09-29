#import "UmeKitChannelObserverPlugin.h"
#if __has_include(<ume_kit_channel_observer/ume_kit_channel_observer-Swift.h>)
#import <ume_kit_channel_observer/ume_kit_channel_observer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ume_kit_channel_observer-Swift.h"
#endif

@implementation UmeKitChannelObserverPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUmeKitChannelObserverPlugin registerWithRegistrar:registrar];
}
@end
