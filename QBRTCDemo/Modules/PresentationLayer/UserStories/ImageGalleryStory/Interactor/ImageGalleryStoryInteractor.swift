//
//  ImageGalleryStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Photos

class ImageGalleryStoryInteractor: NSObject, ImageGalleryStoryInteractorInput {

    weak var output: ImageGalleryStoryInteractorOutput!
	
	weak var imagesOutput: ImageGalleryStoryInteractorImagesOutput!

	private weak var _callService: protocol<CallServiceProtocol>!
	
	var callService: protocol<CallServiceProtocol>! {
		get {
			return _callService
		}
		set (value){
			_callService = value
			//_callService.addDataChannelDelegate(self)
		}
	}
	
	var collectionViewConfigurationBlock: ((collectionView: ImageGalleryStoryCollectionView) -> Void)!
	
	func configureCollectionView(collectionView: ImageGalleryStoryCollectionView) {
		collectionViewConfigurationBlock(collectionView: collectionView)
	}
	
	func startSynchronizationImages() {
		guard callService != nil else {
			print("startSynchronizationImages: no call service")
			return
		}
		
//		if callService.isInitiator() {
//			output.didStartSynchronizationImages()
//			
//			let assets = allAssets()
//			
//			for asset in assets {
//				
//				guard let image = imageWithAsset(asset) else {
//					print("can not retrieve image from asset")
//					continue
//				}
//				
//				guard let imageData = dataWithUIImage(image) else {
//					continue
//				}
//				
//				guard sendData(imageData) else {
//					output.didFinishSynchronizationImages()
//					return
//				}
//			}
//			
//			output.didFinishSynchronizationImages()
//		}
	}
	
	func requestCallerRole() {
//		if callService.isInitiator() {
//			output.didReceiveRoleSender()
//		} else {
//			output.didReceiveRoleReceiver()
//		}
	}
	
	/**
	Creates [UIImage] from all assets in image galler
	
	- returns: array of UIImage instances
	*/
	func allImages() -> [UIImage] {
		let fetchOptions = PHFetchOptions()

		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		var images: [UIImage] = []
		
		let assets = allAssets()
		
		for asset in assets {
			
			if let image = imageWithAsset(asset) {
			
				images.append(image)
			}
		}
		
		return images
	}
	
	/**
	Retrieves all assets from image gallery
	
	- returns: array of PHAsset instances
	*/
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
		return false
//		let success = callService.sendData(data)
//		if success {
//			print("Successfully sent image data")
//		} else {
//			print("Error sending image data")
//		}
//		return success
	}
	
	func sendDataObjects(data: [NSData]) {
//		for dataObject in data {
//			callService.sendData(dataObject)
//		}
	}
	
	///
	/// CallServiceDataChannelAdditionsDelegate
	///
//	func callService(callService: CallServiceProtocol, didReceiveMessage message: String) {
//		print("Received message \(message)")
//	}
	
//	func callService(callService: CallServiceProtocol, didReceiveData data: NSData) {
//		print("Received data, size in bytes \(data.length)")
//		
//		if let image = UIImage(data: data) {
//			print("Received data is UIImage")
//			imagesOutput.didReceiveImage(image)
//		} else {
//			print("Received data that is not convertible to UIImage")
//		}
//	}

}
