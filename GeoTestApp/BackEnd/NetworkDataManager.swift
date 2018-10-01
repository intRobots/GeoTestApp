//
//  NetworkDataManager.swift
//  GeoTestApp
//
//  Created by Admin on 9/27/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit

protocol NetworkDataManagerDelegate {
    func geoObjectsRecieved(objects: [NetworkDataManager.GeoObject])
    func errorReceivingGeoObjects(errorMsg:String)
}

class NetworkDataManager: NSObject {

    static let shared = NetworkDataManager()
    var delegate:NetworkDataManagerDelegate?
    
    struct GeoObject: Decodable {
        var type: String
        var duration: Int
        var color: String
    }
    

    ///
    private override init() { }
    
    /// Download geo objects
    func downloadGeoObjects() {
        let url = URL(string: InitData.URL.GEO_TAGS_LIST_URL)!
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let receivedString = try? String(contentsOf: localURL) {
                    do {
                        let jsonData = receivedString.data(using: .utf8)!
                        let geoTagsArray = try JSONDecoder().decode([GeoObject].self, from: jsonData)
                        self.delegate?.geoObjectsRecieved(objects: geoTagsArray)
                    } catch {
                        self.delegate?.errorReceivingGeoObjects(errorMsg: error.localizedDescription)
                    }
                } else {
                  self.delegate?.errorReceivingGeoObjects(errorMsg: "Error receiving data")
                }
            }
        }
        task.resume()
    }
    
    
}
