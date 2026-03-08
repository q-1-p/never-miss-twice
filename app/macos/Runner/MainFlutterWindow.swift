import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.setContentSize(NSSize(width: 480, height: 600))
    self.minSize = NSSize(width: 360, height: 400)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "io.github.q-1-p/dock_badge",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setBadgeLabel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let label = (call.arguments as? [String: String])?["label"] ?? ""
      NSApp.dockTile.badgeLabel = label.isEmpty ? nil : label
      result(nil)
    }

    super.awakeFromNib()
  }
}
