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
    
    /**
     * Private constructor to ensure only sharedInstance can be used
     */
    override private init() {
        super.init()
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    
    func getImage(_ imageURL: String) -> UIImage? {
        return imageCache.object(forKey: imageURL as NSString)
    }
    
    func saveImage(_ image: UIImage, _ imageURL: String) {
        imageCache.setObject(image, forKey: imageURL as NSString)
    }
}
