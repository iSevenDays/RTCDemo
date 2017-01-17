//
//  SettingModel.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 16.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum SettingViewType {
	case subtitle(label: String, subLabel: String?, selected: Bool)
}

@objc class SettingModel: NSObject {
	var type: SettingViewType
	init(type: SettingViewType) {
		self.type = type
	}

}
