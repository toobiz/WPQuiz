//
//  ImageCache.swift
//  WPQuiz
//
//  Created by Michał Tubis on 12.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class ImageCache {
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ImageCache {
        struct Singleton {
            static var sharedInstance = ImageCache()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    fileprivate var inMemoryCache = NSCache<AnyObject, AnyObject>()
    
    // MARK: Saving images
    
    func storeImage(_ image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        if image == nil {
            inMemoryCache.removeObject(forKey: path as AnyObject)
            
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch _ {}
            
            return
        }
        inMemoryCache.setObject(image!, forKey: path as AnyObject)
        
        let data = UIImagePNGRepresentation(image!)!
        try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
    }
    
    // MARK: Retrieving images
    
    func imageWithIdentifier(_ identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.object(forKey: path as AnyObject) as? UIImage {
            return image
        }
        
        // Next try the hard drive
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: Helper
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        
        return fullURL.path
    }
}
