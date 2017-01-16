//
//  SettingsStorage.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 16.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

class SettingsStorage {
	
	var cacheService: CacheServiceProtocol!
	
	var fullHDVideoQualityEnabled: Bool {
		get {
			return cacheService.boolForKey("fullHDVideoQualityEnabled")
		}
		set {
			cacheService.setBool(fullHDVideoQualityEnabled, forKey: "fullHDVideoQualityEnabled")
		}
	}
	
}
