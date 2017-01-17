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
}

class SettingsStorage {
	
	var cacheService: CacheServiceProtocol!
	
	var videoSeting: VideoQualitySetting {
		get {
			if let str = cacheService.stringForKey(VideoQualitySetting.identifier.rawValue), let savedSetting = VideoQualitySetting(rawValue: str) {
				return savedSetting
			}
			return .medium
		}
		set {
			cacheService.setObject(videoSeting.rawValue, forKey: VideoQualitySetting.identifier.rawValue)
		}
	}
	
}
