//
//  ImageSearchResultViewModel.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-03-05.
//

import Foundation

class ImageSearchResultViewModel {
    var listItems = [SearchImageItem]()
    var queryString = ""
    var currentPage = 1
    var addToLRU: (() -> Void) = {}
    let imageCache = ImageCacheManager.shared
    var reloadData: (() -> Void) = {}
    var stopAnimating: (() -> Void) = {}
    var onError: (() -> Void) = {}

    init(_ queryString: String, _ addToLRU: @escaping (() -> Void)) {
        self.queryString = queryString
        self.addToLRU = addToLRU
        prepareDataSource(queryString, currentPage)
    }
    
    func prepareDataSource(_ title: String, _ pageNumber: Int) {
        NetworkManager.sharedInstance.getImages(with: title, pageNumber) { [weak self] itemList, error in
            if let strongSelf = self {
                DispatchQueue.main.async {
                    strongSelf.stopAnimating()
                }
                if let itemList = itemList, itemList.count > 0 {
                    // success
                    strongSelf.listItems += itemList
                    DispatchQueue.main.async {
                        strongSelf.addToLRU()
                        strongSelf.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        strongSelf.onError()
                    }
                }
            }
        }
    }
}
