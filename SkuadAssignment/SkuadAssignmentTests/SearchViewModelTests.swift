//
//  SearchViewModelTests.swift
//  SkuadAssignmentTests
//
//  Created by Rishabh Gupta on 2021-03-05.
//

import XCTest
@testable import SkuadAssignment

class SearchViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        LRUCache.sharedInstance.resetLRUCache()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchViewModel() {
        let searchViewModel = SearchViewModel()
        searchViewModel.addToLRU("cars")
        searchViewModel.addToLRU("dogs")
        searchViewModel.addToLRU("cats")
        
        searchViewModel.addToLRU("rats")
        searchViewModel.addToLRU("laptop")
        searchViewModel.addToLRU("mouse")
        
        searchViewModel.addToLRU("bottle")
        searchViewModel.addToLRU("iPhone")
        searchViewModel.addToLRU("books")
        
        searchViewModel.addToLRU("paper")
        searchViewModel.addToLRU("pillow")
        searchViewModel.addToLRU("table")
        let arr = ["table", "pillow", "paper", "books", "iPhone", "bottle", "mouse", "laptop", "rats", "cats"]
        XCTAssertEqual(searchViewModel.getFromLRU(), arr)
        searchViewModel.textFieldDidChange()
        XCTAssertEqual(searchViewModel.queries,arr)
    }
    
    func testHeaderTitle() {
        let searchViewModel = SearchViewModel()
        XCTAssertEqual(searchViewModel.headerTitle, "")
        searchViewModel.addToLRU("cars")
        searchViewModel.addToLRU("dogs")
        searchViewModel.addToLRU("cats")
        XCTAssertEqual(searchViewModel.headerTitle, "Recent Searches")
    }
    
    func testQueries() {
        var count = 0
        let searchViewModel = SearchViewModel()
        searchViewModel.reloadTableView = {
            count += 1
        }
        searchViewModel.queries = ["cats", "dogs"]
        XCTAssertEqual(count, 1)
    }
    
    func testDidTextFieldChange() {
        let searchViewModel = SearchViewModel()
        searchViewModel.textFieldDidChange()
        XCTAssertEqual(searchViewModel.queries,[])
    }
}
