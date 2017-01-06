//
//  PermissionsServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 03.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum AuthorizationStatus {
	case notDetermined
	case authorized
	case denied
}

protocol PermissionsServiceProtocol: class {
	func authorizationStatusForVideo() -> AuthorizationStatus
	func authorizationStatusForMicrophone() -> AuthorizationStatus
	
	func requestAccessForVideo(completion: (granted: Bool) -> Void)
	func requestAccessForMicrophone(completion: (granted: Bool) -> Void)
}
