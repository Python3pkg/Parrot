import AppKit

public class AboutViewController: NSViewController {
	
	@IBOutlet public var appIcon: NSImageView?
	@IBOutlet public var appName: NSTextField?
	@IBOutlet public var appVersion: NSTextField?
	@IBOutlet public var copyright: NSTextField?
	
	private func configureWindow(_ w: NSWindow) {
		w.styleMask = [.titled, .closable, .fullSizeContentView]
		w.collectionBehavior = [.moveToActiveSpace, .transient, .ignoresCycle, .fullScreenAuxiliary, .fullScreenDisallowsTiling]
		w.titleVisibility = .hidden
		w.titlebarAppearsTransparent = true
		w.isMovableByWindowBackground = true
		w.standardWindowButton(.miniaturizeButton)?.isHidden = true
		w.standardWindowButton(.zoomButton)?.isHidden = true
	}
	
	public override func viewWillAppear() {
		super.viewWillAppear()
		if let w = self.view.window {
			configureWindow(w)
			ParrotAppearance.registerAppearanceListener(observer: self, invokeImmediately: true) { appearance in
				w.appearance = appearance
			}
		}
		
		self.appIcon?.image = NSApp.applicationIconImage
		self.appName?.stringValue = Bundle.main().objectForInfoDictionaryKey("CFBundleName") as! String
		self.appVersion?.stringValue = Bundle.main().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
		self.copyright?.stringValue = Bundle.main().objectForInfoDictionaryKey("NSHumanReadableCopyright") as! String
	}
	
	public override func viewDidDisappear() {
		super.viewDidDisappear()
		ParrotAppearance.unregisterAppearanceListener(observer: self)
	}
}
