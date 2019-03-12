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
	
	func authorizationStatusForMicrophone() -> AuthorizationStatus {
		return authStatus
	}
	
	func requestAccessForVideo(_ completion: @escaping (_ granted: Bool) -> Void) {
		switch authStatus {
		case .authorized:
			completion(true)
		case .notDetermined:
			completion(false)
		case .denied:
			completion(false)
		}	
	}
	
	func requestAccessForMicrophone(_ completion: @escaping (_ granted: Bool) -> Void) {
		switch authStatus {
		case .authorized:
			completion(true)
		case .notDetermined:
			completion(false)
		case .denied:
			completion(false)
		}
	}
}
