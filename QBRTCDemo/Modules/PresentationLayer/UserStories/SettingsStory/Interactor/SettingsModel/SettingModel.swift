//
//  SettingModel.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 16.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum SettingType {
	case switcher(enabled: Bool)
}

@objc class SettingModel: NSObject {
	var label: String
	var type: SettingType
	init(label: String, type: SettingType) {
		self.label = label
		self.type = type
	}

}
