//
//  SearchImageItem.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-20.
//

import Foundation

struct ImageData: Codable {
    var hits: [SearchImageItem]
}

struct SearchImageItem: Codable {
    var id: Int64
    var previewURL: String
    var webformatURL: String
}
