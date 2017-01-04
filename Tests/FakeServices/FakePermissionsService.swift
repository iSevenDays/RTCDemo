//
//  FakePermissionsService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 04.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class FakePermissionsService: PermissionsServiceProtocol {
	
	var authStatus = AuthorizationStatus.authorized
	
	func authorizationStatusForVideo() -> AuthorizationStatus {
		return authStatus
	}
	
	func requestAccessForVideo(completion: (granted: Bool) -> Void) {
		switch authStatus {
		case .authorized:
			completion(granted: true)
		case .notDetermined:
			completion(granted: false)
		case .denied:
			completion(granted: false)
		}	
	}
}
