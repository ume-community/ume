#import "UmeKitMemoryDetectorPlugin.h"
#if __has_include(<ume_kit_memory_detector/ume_kit_memory_detector-Swift.h>)
#import <ume_kit_memory_detector/ume_kit_memory_detector-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ume_kit_memory_detector-Swift.h"
#endif

@implementation UmeKitMemoryDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUmeKitMemoryDetectorPlugin registerWithRegistrar:registrar];
}
@end
