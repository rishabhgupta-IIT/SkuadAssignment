//
//  ImageCacheManagerTests.swift
//  SkuadAssignmentTests
//
//  Created by Rishabh Gupta on 2021-03-06.
//

import XCTest
@testable import SkuadAssignment

class ImageCacheManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testImageCacheManager() {
        let mockNetworkManager = MockNetworkManager()
        let imageSearchResultVM = ImageSearchResultViewModel("cars", {}, mockNetworkManager)
        let imageURL = "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"
        var image = imageSearchResultVM.imageCache.getImage(imageURL)
        XCTAssertNil(image)
        imageSearchResultVM.imageCache.downloadAndSaveImage(imageURL)
        image = imageSearchResultVM.imageCache.getImage(imageURL)
        XCTAssertNotNil(image)
        
        let queue = imageSearchResultVM.imageCache.downloadQueue
        XCTAssertEqual(queue.name, "com.skuad.downloader")
        XCTAssertEqual(queue.qualityOfService, .userInteractive)
    }
}
