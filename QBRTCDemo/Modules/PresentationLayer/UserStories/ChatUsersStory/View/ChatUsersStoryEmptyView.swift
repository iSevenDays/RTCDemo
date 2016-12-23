//
//  ChatUsersStoryEmptyView.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 23.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

class ChatUsersStoryEmptyView: UIView {
	class func instanceFromNib() -> UIView? {
		return UINib(nibName: "ChatUsersStoryEmptyView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? UIView
	}
}
