//
//  ServicesProvider.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 14/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation
import Quickblox
import SendBirdSDK

class ServicesProvider: NSObject {
	
	enum Zone {
		case development
		case production
	}
	
	static let currentProvider = ServicesProvider(zone: Zone.production)
	
	
	fileprivate(set) var callService: (CallServiceProtocol & CallServiceCameraSwitcherProtocol & CallServiceChatRoomProtocol)!
	fileprivate(set) var restService: RESTServiceProtocol!
	fileprivate(set) var pushService: PushNotificationsServiceProtocol!
	fileprivate(set) var permissionsService: PermissionsServiceProtocol!
	fileprivate(set) var settingsStorage: SettingsStorage!
	
	init(zone: Zone) {
		super.init()
		
		switch zone {
		case .development:
			fatalError("Error: zone is not configured")
			
			break
			
		case .production:
			// QBSignalingChannel()
			let signalingChannel = SendBirdSignalingChannel()
			let callService = CallService()
				
			let serviceConfigurator = ServicesConfigurator()
			serviceConfigurator.configureCallService(callService)
			
			callService.signalingChannel = signalingChannel
			serviceConfigurator.configureSignalingChannel(channel: callService.signalingChannel)
			callService.signalingProcessor.observer = callService
			
			
			let restService = QBRESTService()
			serviceConfigurator.configureRESTService(restService)
			
			self.callService = callService
			self.restService = restService
			
			let pushService = QBPushNotificationsService()
			pushService.cacheService = UserDefaults.standard as CacheServiceProtocol
			self.pushService = pushService
			
			self.permissionsService = PermissionsService()
			
			let settingsStorage = SettingsStorage()
			settingsStorage.cacheService = UserDefaults.standard as CacheServiceProtocol
			self.settingsStorage = settingsStorage
			
			break
		}
	}
}

class ServicesConfigurator {
	
	func configureCallService(_ callService: CallService) {
		callService.cacheService = UserDefaults.standard as CacheServiceProtocol
		callService.defaultOfferConstraints = WebRTCHelpers.defaultOfferConstraints()
		callService.defaultAnswerConstraints = WebRTCHelpers.defaultAnswerConstraints()
		callService.defaultPeerConnectionConstraints = WebRTCHelpers.defaultPeerConnectionConstraints()
		callService.defaultMediaStreamConstraints = WebRTCHelpers.defaultMediaStreamConstraints()
		callService.ICEServers = WebRTCHelpers.defaultIceServers()
		callService.defaultConfigurationWithCurrentICEServers = WebRTCHelpers.defaultConfigurationWithCurrentICEServers()
		callService.signalingProcessor = SignalingProcessor()
		callService.timersFactory = TimersFactory()
	}
	
	func configureRESTService(_ restService: QBRESTService) {
		QBSettings.setApplicationID(31016)
		QBSettings.setAuthKey("aqsHa2AhDO5Z9Th")
		QBSettings.setAuthSecret("825Bv-3ByACjD4O")
		QBSettings.setAccountKey("ZsFuaKozyNC3yLzvN3Xa")
	}

	func configureSignalingChannel(channel: SignalingChannelProtocol) {
		if channel is SendBirdSignalingChannel {
			SBDMain.initWithApplicationId("B83FDA6D-A534-4C73-ABFD-34EBF59DE86C")
		} else if channel is QBSignalingChannel {
			// nothing to configure

		} else {
			fatalError()
		}

	}
}
