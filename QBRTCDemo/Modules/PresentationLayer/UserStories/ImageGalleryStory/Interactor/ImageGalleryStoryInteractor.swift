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
			
			let assets = self.allAssets()
			
			for asset in assets {
				
				guard let image = self.imageWithAsset(asset) else {
					print("can not retrieve image from asset")
					continue
				}
				
				guard let imageData = self.dataWithUIImage(image) else {
					continue
				}
				
				self.sendData(imageData)
			}
			
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
	
	func allImages() -> [UIImage] {
		let fetchOptions = PHFetchOptions()

		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		var images: [UIImage] = []
		
		let assets = self.allAssets()
		
		for asset in assets {
			
			if let image = imageWithAsset(asset) {
			
				images.append(image)
			}
		}
		
		return images
	}
	
	func allAssets() -> [PHAsset] {
		let fetchOptions = PHFetchOptions()
		
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		var assets: [PHAsset] = []
		
		let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
		
		fetchResult.enumerateObjectsUsingBlock { (object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
		
			if let asset = object as? PHAsset {
				assets.append(asset)
			}
			
		}
		return assets
	}
	
	func imageWithAsset(asset: PHAsset) -> UIImage? {
		
		let manager = PHImageManager.defaultManager()
		
		var finalImage: UIImage?
		
		let imageRequestOptions = PHImageRequestOptions()
		imageRequestOptions.synchronous = true
		
		manager.requestImageForAsset(asset, targetSize: CGSizeMake(128, 128), contentMode: PHImageContentMode.Default, options: imageRequestOptions, resultHandler: {(
			let image: UIImage?,
			let info: [NSObject : AnyObject]?) -> Void in
			
			guard let imageUnwrapped = image else {
				print("Retrieved image is nil")
				return;
			}
			
			finalImage = imageUnwrapped
		})
		
		return finalImage
	}
	
	func dataWithUIImage(image: UIImage) -> NSData? {
		guard let imageDataUnwrapped = UIImageJPEGRepresentation(image, 0.9) else {
			print("Cannot create image JPEG representation")
			return nil;
		}
		
		return imageDataUnwrapped
	}
	
	func dataWithUIImages(images: [UIImage]) -> [NSData] {
		var data: [NSData] = []
		
		for image in images {
			if let unwrappedImageData = dataWithUIImage(image) {
				data.append(unwrappedImageData)
			}
		}
		return data
	}
	
	func sendData(data: NSData) -> Bool {
		let success = self.callService.sendData(data)
		if success {
			print("Successfully sent image data")
		} else {
			print("Error sending image data")
		}
		return success
	}
	
	func sendDataObjects(data: [NSData]) {
		for dataObject in data {
			self.callService.sendData(dataObject)
		}
	}
	
	///
	/// CallServiceDataChannelAdditionsDelegate
	///
	func callService(callService: CallServiceProtocol, didReceiveMessage message: String) {
		print("Received message \(message)")
	}
	
	func callService(callService: CallServiceProtocol, didReceiveData data: NSData) {
		print("Received data, size in bytes \(data.length)")
		
		if let image = UIImage(data: data) {
			print("Received data is UIImage")
			self.imagesOutput.didReceiveImage(image)
		} else {
			print("Received data that is not convertible to UIImage")
		}
	}

}
