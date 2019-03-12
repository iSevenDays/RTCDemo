//
//  SettingsStorage.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 16.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum VideoQualitySetting: String {
	case identifier = "VideoQualitySetting"
	case low = "Low"
	case medium = "Medium"
	case high = "High"
	
	static var allValues: [VideoQualitySetting] {
		return [.low, .medium, .high]
	}
}

class SettingsStorage {
	
	var cacheService: CacheServiceProtocol!
	
	var videoSetting: VideoQualitySetting {
		get {
			if let str = cacheService.string(forKey: VideoQualitySetting.identifier.rawValue), let savedSetting = VideoQualitySetting(rawValue: str) {
				return savedSetting
			}
			return .medium
		}
		set {
			
			cacheService.set(newValue.rawValue, forKey: VideoQualitySetting.identifier.rawValue)
		}
	}
}
