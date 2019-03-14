//
//  SVUser.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation

class SVUser: NSObject, Codable {
	static var supportsSecureCoding: Bool {
		return true
	}

	var ID: Int?
	var login: String?
	var fullName: String
	var password: String?
	var tags: [String]?

	enum Key: String {
		case ID
		case login
		case fullName
		case password
		case tags
	}

	init(ID: Int?, login: String?, fullName: String, password: String?, tags: [String]?) {
		self.ID = ID
		self.login = login
		self.fullName = fullName
		self.password = password
		self.tags = tags
	}

	override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? SVUser {
			return object.ID == self.ID
		}
		return false
	}
	override var hash: Int {
		return ID?.hashValue ?? login.hashValue
	}
}

//extension SVUser: Equatable {
//	public static func == (lhs: SVUser, rhs: SVUser) -> Bool {
//		return lhs.ID == rhs.ID
//	}
//}
//extension SVUser: Hashable {
//	var hashValue: Int {
//		return ID?.hashValue ?? login.hashValue
//	}
//}
