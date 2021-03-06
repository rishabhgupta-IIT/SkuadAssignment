//
//  ImageSearchResultViewModelTests.swift
//  SkuadAssignmentTests
//
//  Created by Rishabh Gupta on 2021-03-05.
//

import XCTest
@testable import SkuadAssignment

class ImageSearchResultViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testListItems() {
        let mockNetworkManager = MockNetworkManager()
        let imageSearchResultVM = ImageSearchResultViewModel("cars", {}, mockNetworkManager)
        XCTAssertEqual(imageSearchResultVM.listItems.count, 1)
    }
    
    func testPrepareDataSource() {
        let mockNetworkManager = MockNetworkManager()
        var reloadCount = 0
        var addToLRUCount = 0
        let imageSearchResultVM = ImageSearchResultViewModel("cars", {}, mockNetworkManager)
        DispatchQueue.main.async {
            imageSearchResultVM.addToLRU = {
                addToLRUCount = 1
            }
            imageSearchResultVM.reloadData = {
                reloadCount += 1
            }
            sleep(1)
            XCTAssertEqual(addToLRUCount, 1)
            XCTAssertEqual(reloadCount, 1)
        }
    }
    
    func testPrepareDataSourceError() {
        let mockNetworkManager = MockNetworkManager()
        var errorCount = 0
        mockNetworkManager.mimicErrorConditionFlag = true
        let imageSearchResultVM = ImageSearchResultViewModel("cars", {}, mockNetworkManager)
        DispatchQueue.main.async {
            imageSearchResultVM.onError = {
                errorCount += 1
            }
            sleep(1)
            XCTAssertEqual(errorCount, 1)
        }
    }
    
    func testPagination() {
        let mockNetworkManager = MockNetworkManager()
        let imageSearchResultVM = ImageSearchResultViewModel("cars", {}, mockNetworkManager)
        var indexPath = IndexPath(item: 10, section: 1)
        imageSearchResultVM.pagination(indexPath)
        XCTAssertEqual(imageSearchResultVM.currentPage, 1)
        indexPath = IndexPath(item: 30, section: 1)
        imageSearchResultVM.pagination(indexPath)
        XCTAssertEqual(imageSearchResultVM.currentPage, 2)
    }
}
