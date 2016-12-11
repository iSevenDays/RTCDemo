//
//  ServicesProvider.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 14/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

class ServicesProvider: NSObject {
	
	enum Zone {
		case Development
		case Production
	}
	
	static let currentProvider = ServicesProvider(zone: Zone.Production)
	
	
	private(set) var callService: protocol<CallServiceProtocol>!
	private(set) var restService: protocol<RESTServiceProtocol>!
	
	init(zone: Zone) {
		super.init()
		
		switch zone {
		case .Development:
			fatalError("Error: zone is not configured")
			
			break
			
		case .Production:
			let signalingChannel = QBSignalingChannel()
			let callService = CallService()
			callService.signalingChannel = signalingChannel
			callService.signalingProcessor.observer = callService
			signalingChannel.addObserver(callService.signalingProcessor)
			let restService = QBRESTService()
			
			ServicesConfigurator().configureCallService(callService)
			ServicesConfigurator().configureRESTService(restService)
			
			self.callService = callService
			self.restService = restService
			
			break
		}
	}
	
}

class ServicesConfigurator {
	
	func configureCallService(callService: CallService) {
		callService.cacheService = NSUserDefaults.standardUserDefaults()
		callService.defaultOfferConstraints = WebRTCHelpers.defaultOfferConstraints()
		callService.defaultAnswerConstraints = WebRTCHelpers.defaultAnswerConstraints()
		callService.defaultPeerConnectionConstraints = WebRTCHelpers.defaultPeerConnectionConstraints()
		callService.defaultMediaStreamConstraints = WebRTCHelpers.defaultMediaStreamConstraints()
		callService.ICEServers = WebRTCHelpers.defaultIceServers()
		callService.defaultConfigurationWithCurrentICEServers = WebRTCHelpers.defaultConfigurationWithCurrentICEServers()
	}
	
	func configureRESTService(restService: QBRESTService) {
		QBSettings.setApplicationID(31016)
		QBSettings.setAuthKey("aqsHa2AhDO5Z9Th")
		QBSettings.setAuthSecret("825Bv-3ByACjD4O")
		QBSettings.setAccountKey("ZsFuaKozyNC3yLzvN3Xa")
	}
}
