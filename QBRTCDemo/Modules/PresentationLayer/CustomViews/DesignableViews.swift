//
//  DesignableView.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 17.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

extension UIView {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
}


@IBDesignable
class DesignableView: UIView {
	
}

@IBDesignable
class DesignableButton: UIButton {
	@IBInspectable var normalBackgroundColor: UIColor? {
		didSet {
			backgroundColor = normalBackgroundColor
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var selectedBackgroundColor: UIColor = UIColor.blackColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var highlightedBackgroundColor: UIColor = UIColor.blackColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	
	override var highlighted: Bool {
		didSet {
			if highlighted {
				layer.backgroundColor = highlightedBackgroundColor.CGColor
			} else {
				layer.backgroundColor = normalBackgroundColor?.CGColor
			}
		}
	}
	
	override var selected: Bool {
		didSet {
			if selected {
				layer.backgroundColor = selectedBackgroundColor.CGColor
			} else {
				layer.backgroundColor = normalBackgroundColor?.CGColor
			}
			setNeedsDisplay()
		}
	}
}
