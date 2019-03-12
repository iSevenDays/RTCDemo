//
//  CallServiceProtocol.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol CallServiceProtocol: class {
	var isConnected: Bool { get }
	var isConnecting: Bool { get }
	var currentUser: SVUser? { get }
	var hasActiveCall: Bool { get }
	
	var observers: MulticastDelegate<CallServiceObserver> { get }
	
	func addObserver(_ observer: CallServiceObserver)
	func removeObserver(_ observer: CallServiceObserver)
	func connectWithUser(_ user: SVUser, completion: ((_ error: Error?) -> Void)?)
	func disconnectWithCompletion(_ completion: ((_ error: Error?) -> Void)?)
	func startCallWithOpponent(_ user: SVUser) throws
	func acceptCallFromOpponent(_ opponent: SVUser) throws
	func hangup()
	func sendRejectCallToOpponent(_ user: SVUser) throws
	func sendMessageCurrentUserEnteredChatRoom(_ chatRoomName: String, toUser: SVUser)
}

protocol CallServiceCameraSwitcherProtocol: class {
	func switchCamera(forActivePeerConnectionWithLocalVideoTrack localVideoTrack: RTCVideoTrack, renderer: RenderableView) -> AVCaptureDevice.Position?
	func setCamera(forActivePeerConnectionWithLocalVideoTrack localVideoTrack: RTCVideoTrack, renderer: RenderableView, position: AVCaptureDevice.Position) -> AVCaptureDevice.Position?
}
