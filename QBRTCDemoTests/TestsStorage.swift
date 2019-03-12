//
//  TestsStorage.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 16.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation
#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class TestsStorage {
	
	class var svuserRealUser1: SVUser {
		return SVUser(id: 6942802, login: "UUID_CUSTOM", fullName: "rtcuser1_fullname", password: "rtcuser1", tags: ["tag1"])
	}
	
	class var svuserRealUser2: SVUser {
		return SVUser(id: 6942803, login: "UUID_CUSTOM2", fullName: "rtcuser2_fullname", password: "rtcuser2", tags: ["tag2"])
	}
	
	class var svuserTest: SVUser {
		return SVUser(id: 123, login: "svlogin", fullName: "full_name_sv", password: "svpass", tags: ["svtag"])
	}
	
	class var qbuserTest: QBUUser {
		let qbuser = QBUUser()
		qbuser.login = "testlogin"
		qbuser.id = 777
		qbuser.password = "testpass"
		qbuser.fullName = "full_name"
		qbuser.tags = ["tag"]
		return qbuser
	}
	
}
