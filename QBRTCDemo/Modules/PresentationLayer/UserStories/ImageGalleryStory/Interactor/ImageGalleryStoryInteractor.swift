//
//  ImageGalleryStoryInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Photos

class ImageGalleryStoryInteractor: NSObject, CallServiceDataChannelAdditionsDelegate, ImageGalleryStoryInteractorInput {

    weak var output: ImageGalleryStoryInteractorOutput!

	var callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>!
	
	func configureWithCallService(callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>) {
		self.callService = callService
	}
	
	func startSynchronizationImages() {
		self.output.didStartSynchronizationImages()
		
		self.callService?.sendText("Sender")
		
		self.output.didFinishSynchronizationImages()
	}
	
	func requestCallerRole() {
		if self.callService.isInitiator() {
			self.output.didReceiveRoleSender()
		} else {
			self.output.didReceiveRoleReceiver()
		}
	}
	
	func fetchPhotos(){
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
		
		if let lastAsset: PHAsset = fetchResult.lastObject as? PHAsset {
			let manager = PHImageManager.defaultManager()
			let imageRequestOptions = PHImageRequestOptions()
			
			manager.requestImageDataForAsset(lastAsset, options: imageRequestOptions) {
				(let imageData: NSData?, let dataUTI: String?,
				let orientation: UIImageOrientation,
				let info: [NSObject : AnyObject]?) -> Void in
				
				if let imageDataUnwrapped = imageData {
					self.callService.sendData(imageDataUnwrapped)
				}
			}
		}
	}
}
