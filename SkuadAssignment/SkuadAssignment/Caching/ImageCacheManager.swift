//
//  ImageCacheManager.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-21.
//

import Foundation
import UIKit

class ImageCacheManager: NSObject {
    
    /**
     * Shared instance
     */
    static var shared = ImageCacheManager()
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.skuad.downloader"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    /**
     * Private constructor to ensure only sharedInstance can be used
     */
    override private init() {
        super.init()
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    
    /**
     * Get the saved image from cache
     */
    func getImage(_ imageURL: String) -> UIImage? {
        return imageCache.object(forKey: imageURL as NSString)
    }
    
    /**
     * Download the image and save to the cache 
     */
    func downloadAndSaveImage(_ imageURL: String) {
        if let url = URL(string: imageURL),
           let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: imageURL as NSString)
            }
        }
    }
}
