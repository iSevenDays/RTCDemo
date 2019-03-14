//
//  SVUser+QBUUser.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation
import Quickblox

extension SVUser {
	class func fromQBUUser(_ qbuuser: QBUUser) -> SVUser {
		let user = SVUser(ID: Int(qbuuser.id), login: qbuuser.login, fullName: qbuuser.fullName ?? "", password: qbuuser.password, tags: qbuuser.tags as? [String])
		return user
	}
}
