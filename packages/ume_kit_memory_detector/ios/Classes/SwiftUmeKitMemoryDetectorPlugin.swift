import Flutter
import UIKit

public class SwiftUmeKitMemoryDetectorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ume_kit_memory_detector", binaryMessenger: registrar.messenger())
    let instance = SwiftUmeKitMemoryDetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
