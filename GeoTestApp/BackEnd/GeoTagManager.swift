//
//  GeoTagManager.swift
//  GeoTestApp
//
//  Created by Admin on 9/27/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit

protocol GeoTagManagerDelegate {
    func geoObjectsRecieved()
}

class GeoTagManager: NSObject, NetworkDataManagerDelegate {

    static let shared = GeoTagManager()
    var delegate:GeoTagManagerDelegate? = nil
    
    let networkDataManager = NetworkDataManager.shared
    let dataBaseManager = DataBaseManager.shared

    
    ///
    private override init() {
        super.init()
        networkDataManager.delegate = self
        
        if dataBaseManager.geoObjectsExists() == false {
            networkDataManager.downloadGeoObjects()
        }
    }
    
    ///
    func getObjectsArray(filters:[String:Any]) -> [GeoTagObject] {
        return dataBaseManager.getGeoObjects(filters: filters)
    }
    
    ///
    func getFilters() -> [String:Any] {
        return dataBaseManager.getFilters()
    }
    
    // request tags from server
    func requestGeoTags() {
        dataBaseManager.removeAllObjects()
        networkDataManager.downloadGeoObjects()
    }

    

    // MARK: -- NetworkDataManagerDelegate methods
    func geoObjectsRecieved(objects: [NetworkDataManager.GeoObject]) {
        var index = 0
        
        for object in objects {
            let geoTagObject = GeoTagObject(type: object.type,
                                            duration: object.duration,
                                            color: object.color,
                                            coordinate: InitData.coordinates[index])
            dataBaseManager.insertGeoTag(object: geoTagObject)

            index += 1
            if index >= objects.count {
                index = 0
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.geoObjectsRecieved()
        }
    }
    
    ///
    func errorReceivingGeoObjects(errorMsg: String) {
        print("errorReceivingGeoObjects")
    }
}
