//
//  ViewController.swift
//  GeoTestApp
//
//  Created by Admin on 9/26/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, FilterSheetDelegate, GMSMapViewDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet var mapView: GMSMapView!
    
    
    
    var geoObjectsToShow:[GeoTagObject] = []
    var markers:[GMSMarker] = []
    
    
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        container.layer.cornerRadius = 15
        container.layer.masksToBounds = true
        
        let camera = GMSCameraPosition.camera(withLatitude: InitData.KIEV_LATITUDE, longitude: InitData.KIEV_LONGITUDE, zoom: 12)
        mapView.camera = camera
        mapView.delegate = self
    }

    
    ///
    func showOnMap(objects:[GeoTagObject]) {
        geoObjectsToShow = objects
        mapView.clear()
        markers.removeAll()
        
        for object in geoObjectsToShow {
            let marker = GMSMarker(position: object.coordinate)
            marker.title = "Duration: \(object.duration.description)"
            marker.icon = GMSMarker.markerImage(with: object.getUIColor())
            marker.map = mapView
            markers.append(marker)
        }
    }
    

    
    // MARK: -- GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        var latitude  = position.target.latitude;
        var longitude = position.target.longitude;
        

        if (position.target.latitude > InitData.KIEV_BOUNDS_LIMIT.northEast.latitude) {
            latitude = InitData.KIEV_BOUNDS_LIMIT.northEast.latitude;
        }
        if (position.target.latitude < InitData.KIEV_BOUNDS_LIMIT.southWest.latitude) {
            latitude = InitData.KIEV_BOUNDS_LIMIT.southWest.latitude;
        }
        if (position.target.longitude > InitData.KIEV_BOUNDS_LIMIT.northEast.longitude) {
            longitude = InitData.KIEV_BOUNDS_LIMIT.northEast.longitude;
        }
        if (position.target.longitude < InitData.KIEV_BOUNDS_LIMIT.southWest.longitude) {
            longitude = InitData.KIEV_BOUNDS_LIMIT.southWest.longitude;
        }
        
        if (latitude != position.target.latitude || longitude != position.target.longitude) {
            var location = CLLocationCoordinate2D();
            location.latitude  = latitude;
            location.longitude = longitude;
            mapView.animate(toLocation: location);
        }
    }
    
    
    // MARK: -- FilterSheetDelegate
    func updateFilterSheet(frame: CGRect) {
        container.frame = frame
        backView.frame = self.view.frame.offsetBy(dx: 0, dy: 15 + container.frame.minY - self.view.frame.height)
        backView.backgroundColor = UIColor.black.withAlphaComponent(1 - (frame.minY)/200)
    }
    
    
    // MARK: -- Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? FilterSheetViewController{
            viewController.mapViewController = self
            viewController.filterSheetDelegate = self
            viewController.parentView = container
        }
    }
}

