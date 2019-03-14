//
//  QBUUser+SVUser.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation
import Quickblox

extension QBUUser {
	class func fromSVUser(svuser: SVUser) -> QBUUser {
		let qbuser = QBUUser()
		if let svuserID = svuser.ID {
			qbuser.id = UInt(svuserID)
		}
		qbuser.login = svuser.login
		qbuser.password = svuser.password
		qbuser.tags = NSMutableArray(array: svuser.tags ?? [])
		qbuser.fullName = svuser.fullName
		return qbuser
	}
}
