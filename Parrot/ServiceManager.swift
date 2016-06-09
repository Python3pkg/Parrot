import Cocoa
import Hangouts

// Existing Parrot Settings keys.
public class Parrot {
	public static let AutoEmoji = "Parrot.AutoEmoji"
	public static let DarkAppearance = "Parrot.DarkAppearance"
	public static let InvertChatStyle = "Parrot.InvertChatStyle"
	public static let ShowSidebar = "Parrot.ShowSidebar"
}

@NSApplicationMain
class ServiceManager: NSObject, NSApplicationDelegate {
	
	private var trans: WindowTransitionAnimator? = nil
	
	// First begin authentication and setup for any services.
	func applicationWillFinishLaunching(_ notification: NSNotification) {
		Authenticator.authenticateClient {
			_hangoutsClient = Client(configuration: $0)
			_hangoutsClient?.connect()
			
			NSNotificationCenter.default()
				.addObserver(forName: Client.didConnectNotification, object: _hangoutsClient!, queue: nil) { _ in
					_hangoutsClient!.buildUserConversationList { (userList, conversationList) in
						_REMOVE.forEach {
							$0(userList, conversationList)
						}
					}
			}
			
			// Instantiate storyboard and controller and begin the UI from here.
			Dispatch.main().add {
				let s = NSStoryboard(name: "Main", bundle: NSBundle.main())
				let vc = s.instantiateController(withIdentifier: "Conversations") as! ConversationsViewController
				vc.selectionProvider = { row in
					let vc2 = s.instantiateController(withIdentifier: "Conversation") as! ConversationViewController
					vc2.representedObject = vc.conversationList?.conversations[row]
					vc.present(vc2, animator: WindowTransitionAnimator())
				}
				self.trans = WindowTransitionAnimator()
				self.trans!.displayViewController(viewController: vc)
				
				self.trans?.window?.titleVisibility = .hidden;
				self.trans?.window?.titlebarAppearsTransparent = true;
				
				let dark = Settings()[Parrot.DarkAppearance] as? Bool ?? false
				let appearance = (dark ? NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight)
				self.trans?.window?.appearance = NSAppearance(named: appearance)
			}
		}
	}
	
	// So clicking on the dock icon actually shows the window again.
	func applicationShouldHandleReopen(sender: NSApplication, flag: Bool) -> Bool {
		self.trans?.showWindow(nil)
		return true
	}
	
	// We need to provide a useful dock menu.
	/* TODO: Provide a dock menu for options. */
	func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
		return nil
	}
	
	@IBAction func logoutSelected(_ sender: AnyObject) {
		let cookieStorage = NSHTTPCookieStorage.shared()
		if let cookies = cookieStorage.cookies {
			for cookie in cookies {
				cookieStorage.deleteCookie(cookie)
			}
		}
		Authenticator.clearTokens();
		NSApplication.shared().terminate(self)
	}
}

// Private service points go here:
private var _hangoutsClient: Client? = nil

/* TODO: SHOULD NOT BE USED. */
public typealias _RM2 = (UserList, ConversationList) -> Void
public var _REMOVE = [_RM2]()

// In the future, this will be an extensible service point for all services.
public extension NSApplication {
	
	// Provides a global Hangouts.Client service point.
	public var hangoutsClient: Hangouts.Client? {
		get {
			return _hangoutsClient
		}
	}
}
