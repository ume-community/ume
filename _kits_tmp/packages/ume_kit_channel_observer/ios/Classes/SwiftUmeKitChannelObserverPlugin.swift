import Flutter
import UIKit

public class SwiftUmeKitChannelObserverPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ume_kit_channel_observer", binaryMessenger: registrar.messenger())
    let instance = SwiftUmeKitChannelObserverPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
