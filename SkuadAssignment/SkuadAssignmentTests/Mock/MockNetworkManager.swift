//
//  MockNetworkManager.swift
//  SkuadAssignmentTests
//
//  Created by Rishabh Gupta on 2021-03-05.
//

import Foundation
@testable import SkuadAssignment

class MockNetworkManager: NetworkManagerProtocol {
    var perPage: Int = 50
    var mimicErrorConditionFlag = false
    
    func getImages(with queryString: String, _ pageNumber: Int, _ completion: @escaping ([SearchImageItem]?, Error?) ->Void) {
        let item = SearchImageItem(id: 100, previewURL: "previewURL", webformatURL: "webformatURL")
        let error = NSError(domain: "Domain", code: 200, userInfo: nil)
        if mimicErrorConditionFlag {
            completion(nil, error)
        }
        else {
            completion([item], nil)
        }
    }
}
