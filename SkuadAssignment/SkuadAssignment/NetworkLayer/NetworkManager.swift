//
//  NetworkManager.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-20.
//

import Foundation

class NetworkManager: NSObject {
    
    /**
     * Shared instance
     */
    static var sharedInstance = NetworkManager()
    var perPage = 50
    /**
     * Private constructor to ensure only sharedInstance can be used
     */
    override private init() {
        super.init()
    }
    
    func getImages(with queryString: String, _ pageNumber: Int, _ completion: @escaping ([SearchImageItem]?, Error?) ->Void) {
        let params: [String: Any] = [
            "key": "20346365-bbbaaf00b502449fd46b875d3",
            "image_type": "photo",
            "q": queryString,
            "page": pageNumber,
            "per_page": perPage
        ]
        
        var dataTask: URLSessionDataTask
        let basePath = "https://pixabay.com/api/"
        var items = [URLQueryItem]()
        guard var urlComponents = URLComponents(string: basePath) else {
            return
        }
        
        for (key,value) in params {
            if value is Int {
                let intValue = "\(value)"
                items.append(URLQueryItem(name: key, value: intValue))
            }
            else {
                items.append(URLQueryItem(name: key, value: value as? String))
            }
        }
        urlComponents.queryItems = items
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        dataTask = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            if let data = data {
                do {
                    let imageList = try JSONDecoder().decode(ImageData.self, from: data).hits
                    completion(imageList, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
        dataTask.resume()
    }
}
