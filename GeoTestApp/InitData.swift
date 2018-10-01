//
//  InitData.swift
//

import CoreLocation
import GoogleMaps


struct InitData {
    
    static let GOOGLE_MAPS_API_KEY = "AIzaSyB2OOFumbIClZSXMRTDPpEtBjLYIP36FZo"
    
    
    static let KIEV_LATITUDE = Double(50.449433)
    static let KIEV_LONGITUDE = Double(30.524135)
    
    
    struct URL {
        static let GEO_TAGS_LIST_URL = "https://pastebin.com/raw/DiB5wDpA"
    }
    
    static let KIEV_BOUNDS_LIMIT = GMSCoordinateBounds.init(coordinate: CLLocationCoordinate2D(latitude: 50.551404, longitude: 30.296022),
                                                    coordinate: CLLocationCoordinate2D(latitude: 50.316276, longitude: 30.767509))
    
    static let coordinates = [
        CLLocationCoordinate2D(latitude: 50.414488, longitude: 30.562967),
        CLLocationCoordinate2D(latitude: 50.427649, longitude: 30.564482),
        CLLocationCoordinate2D(latitude: 50.418518, longitude: 30.507523),
        CLLocationCoordinate2D(latitude: 50.443363, longitude: 30.505168),
        CLLocationCoordinate2D(latitude: 50.426191, longitude: 30.486151),
        CLLocationCoordinate2D(latitude: 50.445692, longitude: 30.541077),
        CLLocationCoordinate2D(latitude: 50.498852, longitude: 30.522659),
        CLLocationCoordinate2D(latitude: 50.497013, longitude: 30.545433),
        CLLocationCoordinate2D(latitude: 50.443447, longitude: 30.576596),
        CLLocationCoordinate2D(latitude: 50.441806, longitude: 30.513187)
    ]

    
}
