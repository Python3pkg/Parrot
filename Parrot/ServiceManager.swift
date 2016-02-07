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
	func applicationWillFinishLaunching(notification: NSNotification) {
		Authenticator.authenticateClient {
			_hangoutsClient = Client(configuration: $0)
			_hangoutsClient?.connect()
			
			NSNotificationCenter.defaultCenter()
				.addObserverForName(Client.didConnectNotification, object: _hangoutsClient!, queue: nil) { _ in
					_hangoutsClient!.buildUserConversationList { (userList, conversationList) in
						_REMOVE.forEach {
							$0(userList, conversationList)
						}
					}
			}
			
			// Instantiate storyboard and controller and begin the UI from here.
			Dispatch.main().add {
				let s = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				let vc = s.instantiateControllerWithIdentifier("Conversations") as! ConversationsViewController
				self.trans = WindowTransitionAnimator()
				self.trans!.displayViewController(vc)
				
				self.trans?.window?.titleVisibility = .Hidden;
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
	func applicationDockMenu(sender: NSApplication) -> NSMenu? {
		return nil
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
