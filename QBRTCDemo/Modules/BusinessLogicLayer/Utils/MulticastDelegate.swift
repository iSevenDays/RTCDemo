//
//  MulticastDelegate.swift
//  MulticastDelegate
//
//  Created by Thong Nguyen on 31/03/2016.
//  Copyright © 2016 King Street Apps Limited. All rights reserved.
//

import Foundation

public func += <T> (inout left: MulticastDelegate<T>?, right: T)
{
	if left != nil
	{
		left = MulticastDelegate<T>.addDelegate(left!, delegate: right)
	}
	else
	{
		left = MulticastDelegate<T>(delegate: right as! AnyObject)
	}
}

public func -= <T> (inout left: MulticastDelegate<T>?, right: T)
{
	if left != nil
	{
		left = MulticastDelegate<T>.removeDelegate(left!, delegate: right)
	}
}

infix operator => {}

public func => <T> (inout left: MulticastDelegate<T>?, invocation: (T) -> ())
{
	if let originalleft = left
	{
		let cleaned = MulticastDelegate<T>.invoke(originalleft, invocation: invocation)
		
		if let currentleft = left where originalleft === currentleft
		{
			left = cleaned
		}
	}
}

private struct WeakRef: Equatable
{
	weak var value: AnyObject?
	
	init(value: AnyObject)
	{
		self.value = value
	}
}

private func ==(lhs: WeakRef, rhs: WeakRef) -> Bool
{
	return lhs.value === rhs.value
}

public class MulticastDelegate<T>
{
	private var delegates: [WeakRef]
	
	private init(delegate: AnyObject)
	{
		self.delegates = [WeakRef(value: delegate)]
	}
	
	private init(delegates: Array<WeakRef>)
	{
		self.delegates = delegates
	}
	
	private init(delegates: Array<WeakRef>, delegate: AnyObject)
	{
		var copy = delegates
		let weakDelegate = WeakRef(value: delegate)
		if !copy.contains(weakDelegate) {
			copy.append(weakDelegate)
		}
		
		self.delegates = copy
	}
	
	static func addDelegate(multicastDelegate: MulticastDelegate<T>, delegate: T) -> MulticastDelegate<T>?
	{
		if let delegate = delegate as? AnyObject
		{
			return MulticastDelegate<T>(delegates: multicastDelegate.delegates, delegate: delegate)
		}
		
		return multicastDelegate
	}
	
	static func removeDelegate(multicastDelegate: MulticastDelegate<T>, delegate: T) -> MulticastDelegate<T>?
	{
		for (index, ref) in multicastDelegate.delegates.enumerate()
		{
			if ref.value === delegate as? AnyObject
			{
				if multicastDelegate.delegates.count == 1
				{
					return nil
				}
				
				var newDelegates = Array<WeakRef>(multicastDelegate.delegates[0..<index])
				
				if multicastDelegate.delegates.count - index - 1 > 0
				{
					newDelegates.appendContentsOf(multicastDelegate.delegates[index + 1..<multicastDelegate.delegates.count])
				}
				
				return MulticastDelegate<T>(delegates: newDelegates)
			}
		}
		
		return multicastDelegate
	}
	
	static func invoke(multicastDelegate: MulticastDelegate<T>, invocation: (T) -> ()) -> MulticastDelegate<T>?
	{
		var hasNewDelegates = false
		var newDelegates: Array<WeakRef>? = nil
		
		for (index, ref) in multicastDelegate.delegates.enumerate()
		{
			if let delegate = ref.value
			{
				invocation(delegate as! T)
				
				if var newDelegates = newDelegates
				{
					newDelegates.append(ref)
				}
				else if hasNewDelegates
				{
					newDelegates = Array.init(arrayLiteral: ref)
				}
			}
			else
			{
				if newDelegates == nil
				{
					hasNewDelegates = true
					
					if index > 0
					{
						newDelegates = multicastDelegate.delegates.filter({$0.value != nil})
					}
				}
			}
		}
		
		if let newDelegates = newDelegates
		{
			return MulticastDelegate<T>(delegates: newDelegates)
		}
		else if hasNewDelegates
		{
			return nil
		}
		
		return multicastDelegate
	}
}
