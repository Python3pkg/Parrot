import Foundation

/// Describe's a Person's reachability in the Service.
public enum Reachability {
	
	/// The Person is currently unavailable.
	case unavailable
	
	/// The Person is currently available on a mobile device.
	case mobile
	
	/// The Person is currently available on a mobile device.
	case tablet
	
	/// The Person is currently available on a desktop device.
	case desktop
}

public protocol Person /*: Hashable, Equatable*/ {
	
	/// The Person's unique identifier (specific to the Service).
	var identifier: String { get }
    
    // a handle...
    //var resource: String { get }
	
	/// The Person's name as an array of components.
	/// For example, the first element of the array provides the first name,
	/// and the last element provides the last name. Concatenation of all the elements
	/// in the array should produce the full name.
	var nameComponents: [String] { get }
	
	/// The Person's photo as a remote (internet) or file URL (on disk).
	/// If there is no photo, nil should be returned.
	var photoURL: String? { get }
	
	/// Any possible locations for the Person. These can be physical or virtual.
	/// For example, it may contain email addresses and phone numbers, and even
	/// twitter handles, real physical addresses or coordinates.
	var locations: [String] { get }
	
	/// Is this Person the one logged into the Service?
	var me: Bool { get }
	
	/// The timestamp the Person was last active on the Service.
	var lastSeen: Date { get }
	
	/// The Person's reachability (device), if they are reachable.
	var reachability: Reachability { get }
	
	/// The Person's mood or status message (a la XMPP or AIM).
	var mood: String { get }
	
	/// Block this person from contacting the logged in user.
	//func block()
	
	/// Unblock this person from contacting the logged in user.
	//func unblock()
}

public extension Person {
	
	/// Computes the full name by taking the name components like so:
	/// ["John", "Mark", "Smith"] => "John Mark Smith"
	/// Will return an empty string if there are no name components.
	public var fullName: String {
		return self.nameComponents.joined(separator: " ")
	}
	
	/// Computes the first name by taking the first of the name components:
	/// ["John", "Mark", "Smith"] => "John"
	/// Will return an empty string if there are no name components.
	public var firstName: String {
		return self.nameComponents.first ?? ""
	}
}

public protocol Directory: class /*: Collection*/ {
	
	/// Return the user currently logged into the Service.
	var me: Person { get }
	
	/// Return all users the current user can locate mapped by their unique ID.
	var people: [String: Person] { get }
	
	/// Returns all pending invitations requested to the current user.
	var invitations: [String: Person] { get }
	
	/// Returns all the people blocked by the current user.
	var blocked: [String: Person] { get }
    
    /// Return the Person identified the string provided.
    subscript(_ identifier: String) -> Person { get }
	
	/// Search for users given a set of identifiers.
	/// Identifiers can include anything including name components.
	/// Returns a set of users that could be possible matches.
    func lookup(by: [String]) -> [Person]
    func lookup(by: [String], limit: Int) -> [Person]
}
