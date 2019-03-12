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
		let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
		switch authStatus {
		case .authorized: return .authorized
		case .denied: return .denied
		case .restricted: return .denied
		case .notDetermined: return .notDetermined
		}
	}
	
	func authorizationStatusForMicrophone() -> AuthorizationStatus {
		let authStatus = AVAudioSession.sharedInstance().recordPermission
		switch authStatus {
		case AVAudioSession.RecordPermission.granted: return .authorized
		case AVAudioSession.RecordPermission.denied: return .denied
		case AVAudioSession.RecordPermission.undetermined: return .notDetermined
		default:
			return .notDetermined
		}
	}
	
	func requestAccessForVideo(_ completion: @escaping (_ granted: Bool) -> Void) {
		AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: completion)
	}
	
	func requestAccessForMicrophone(_ completion: @escaping (_ granted: Bool) -> Void) {
		AVAudioSession.sharedInstance().requestRecordPermission(completion)
	}
}
