//
//  SearchViewModel.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-03-05.
//

import Foundation

class SearchViewModel {
    
    var reloadTableView: (() -> Void)?
    
    var queries = [String]() {
        didSet {
            reloadTableView?()
        }
    }
    
    func addToLRU(_ text: String) {
        LRUCache.sharedInstance.put(text, text)
    }
    
    func getFromLRU() -> [String] {
        return LRUCache.sharedInstance.get()
    }
    
    func textFieldDidChange() {
        let arr = getFromLRU()
        queries = arr
    }
}
