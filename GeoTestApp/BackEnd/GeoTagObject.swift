//
//  GeoTagObject.swift
//  GeoTestApp
//
//  Created by Admin on 9/28/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit
import CoreLocation

class GeoTagObject: NSObject {

    let type:String!
    let duration:Int!
    let color:String!
    let coordinate:CLLocationCoordinate2D!
    
    
    init(type:String, duration:Int, color:String, coordinate:CLLocationCoordinate2D) {
        self.type = type
        self.duration = duration
        self.color = color
        self.coordinate = coordinate
    }
    
    
    func getUIColor() -> UIColor {
        return UIColor.init(hex: self.color) ?? UIColor.white
    }

}
