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
	
	weak var imagesOutput: ImageGalleryStoryInteractorImagesOutput!

	var callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>!
	
	var collectionViewConfigurationBlock: ((collectionView: ImageGalleryStoryCollectionView) -> Void)!
	
	func configureCollectionView(collectionView: ImageGalleryStoryCollectionView) {
		self.collectionViewConfigurationBlock(collectionView: collectionView)
	}
	
	func configureWithCallService(callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>) {
		self.callService = callService
		self.callService.addDataChannelDelegate(self)
	}
	
	func startSynchronizationImages() {
		guard callService != nil else {
			print("startSynchronizationImages: no call service")
			return
		}
		
		if self.callService.isInitiator() {
			self.output.didStartSynchronizationImages()
			
			self.fetchPhotos()
			
			self.output.didFinishSynchronizationImages()
		}
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
					let success = self.callService.sendData(imageDataUnwrapped)
					if success {
						print("Successfully sent image")
					} else {
						print("Error sending image")
					}
				}
			}
		}
	}
	
	///
	/// CallServiceDataChannelAdditionsDelegate
	///
	func callService(callService: CallServiceProtocol, didReceiveMessage message: String) {
		print("Received message \(message)")
	}
	
	func callService(callService: CallServiceProtocol, didReceiveData data: NSData) {
		print("Received data \(data)")
		
		if let image = UIImage(data: data) {
			self.imagesOutput.didReceiveImage(image)
		} else {
			print("Received data that is not convertible to UIImage")
		}
	}

}
