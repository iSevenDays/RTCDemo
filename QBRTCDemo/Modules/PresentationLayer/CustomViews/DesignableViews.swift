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
class DesignableImageView: UIImageView {
}


@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
	@IBInspectable var normalBackgroundColor: UIColor? {
		didSet {
			layer.backgroundColor = normalBackgroundColor?.CGColor
			updateSelectedBackgrounColor()
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var selectedBackgroundColor: UIColor = UIColor.blackColor() {
		didSet {
			updateSelectedBackgrounColor()
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var highlightedBackgroundColor: UIColor? {
		didSet {
			setNeedsDisplay()
		}
	}
	
	override var highlighted: Bool {
		didSet {
			guard highlightedBackgroundColor != nil else { return }
			if highlighted {
				layer.backgroundColor = highlightedBackgroundColor?.CGColor
			} else {
				layer.backgroundColor = normalBackgroundColor?.CGColor
			}
			setNeedsDisplay()
		}
	}
	
	override var selected: Bool {
		didSet {
			updateSelectedBackgrounColor()
			setNeedsDisplay()
		}
	}
	
	func updateSelectedBackgrounColor() {
		if selected {
			layer.backgroundColor = selectedBackgroundColor.CGColor
		} else {
			layer.backgroundColor = normalBackgroundColor?.CGColor
		}
	}
}
