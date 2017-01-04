//
//  PermissionsService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 03.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

class PermissionsService {
	
}

extension PermissionsService: PermissionsServiceProtocol {
	func authorizationStatusForVideo() -> AuthorizationStatus {
		let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
		switch authStatus {
		case .Authorized: return .authorized
		case .Denied: return .denied
		case .Restricted: return .denied
		case .NotDetermined: return .notDetermined
		}
	}
	
	func requestAccessForVideo(completion: (granted: Bool) -> Void) {
		AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: completion)
	}
}
