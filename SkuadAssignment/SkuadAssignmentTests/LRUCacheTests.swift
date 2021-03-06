//
//  LRUCacheTests.swift
//  SkuadAssignmentTests
//
//  Created by Rishabh Gupta on 2021-03-06.
//

import XCTest
@testable import SkuadAssignment

class LRUCacheTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        LRUCache.sharedInstance.resetLRUCache()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLRUCache() {
        let cache = LRUCache.sharedInstance
        cache.put("cars", "cars")
        cache.put("dogs", "dogs")
        cache.put("cats", "cats")
        
        let arr = ["cats", "dogs", "cars"]
        XCTAssertEqual(cache.get(), arr)
    }
    
    func testFullCapacityOfLRUCache() {
        let cache = LRUCache.sharedInstance
        
        cache.put("cars", "cars")
        cache.put("dogs", "dogs")
        cache.put("cats", "cats")
        
        cache.put("rats", "rats")
        cache.put("laptop", "laptop")
        cache.put("mouse", "mouse")
        
        cache.put("bottle", "bottle")
        cache.put("iPhone", "iPhone")
        cache.put("books", "books")
        
        cache.put("paper", "paper")
        cache.put("pillow", "pillow")
        cache.put("table", "table")
    
        let arr = ["table", "pillow", "paper", "books", "iPhone", "bottle", "mouse", "laptop", "rats", "cats"]
        XCTAssertEqual(cache.get(), arr)
    }
    
    func testResetLRUCache() {
        let cache = LRUCache.sharedInstance
        cache.resetLRUCache()
        
        XCTAssertEqual(cache.get(), [])
    }
    
    func testOveridingKeyCase() {
        let cache = LRUCache.sharedInstance
        cache.put("cars", "cars")
        cache.put("dogs", "dogs")
        cache.put("cars", "cats")
        
        let arr = ["cars", "dogs"]
        XCTAssertEqual(cache.get(), arr)
    }
}
