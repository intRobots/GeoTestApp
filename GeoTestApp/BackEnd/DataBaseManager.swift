//
//  DataBaseManager.swift
//  GeoTestApp
//
//  Created by Admin on 9/27/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class DataBaseManager: NSObject {

    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let shared = DataBaseManager()

    let FILTER_FIELDS = ["type", "duration", "color"]
    
    var filters:[String:Any] = [:]
    

    private override init() { }

    ///
    func getGeoObjects(filters:[String:Any]) -> [GeoTagObject] {
        var resultArray:[GeoTagObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GeoObjects")
        
        var predicateArray:[NSPredicate] = []

        let filtersArray = filters.keys
        for filterName in filtersArray {
            if filterName == "duration" {
                let valuesDictionary = filters[filterName] as! [Int:Bool]
                let valuesKeys = valuesDictionary.keys

                var valuesForFiltration:[Int] = []
                for value in valuesKeys {
                    if valuesDictionary[value]! {
                        valuesForFiltration.append(value)
                    }
                }
                if valuesForFiltration.count > 0 {
                    predicateArray.append(NSPredicate(format: "\(filterName) IN %@", valuesForFiltration))
                }
            } else {
                let valuesDictionary = filters[filterName] as! [String:Bool]
                let valuesKeys = valuesDictionary.keys

                var valuesForFiltration:[String] = []
                for value in valuesKeys {
                    if valuesDictionary[value]! {
                        valuesForFiltration.append(value)
                    }
                }
                if valuesForFiltration.count > 0 {
                    predicateArray.append(NSPredicate(format: "\(filterName) IN %@", valuesForFiltration))
                }
            }
        }

        if predicateArray.count > 0 {
            fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: predicateArray)
        }
        
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                let geoTagObject = GeoTagObject(type: object.value(forKey: "type") as! String,
                                                duration: object.value(forKey: "duration") as! Int,
                                                color: object.value(forKey: "color") as! String,
                                                coordinate: CLLocationCoordinate2D(latitude: object.value(forKey: "cLatitude") as! Double,
                                                                                   longitude: object.value(forKey: "cLongitude") as! Double))
                
                resultArray.append(geoTagObject)
            }
        }
        
        return resultArray
    }
    
    
    ///
    func insertGeoTag(object: GeoTagObject) {
        let entity = NSEntityDescription.entity(forEntityName: "GeoObjects", in: managedContext)
        let geoObject = NSManagedObject(entity: entity!, insertInto: managedContext)

        geoObject.setValue(object.type, forKey: "type")
        geoObject.setValue(object.duration, forKey: "duration")
        geoObject.setValue(object.color, forKey: "color")
        geoObject.setValue(object.coordinate.latitude, forKey: "cLatitude")
        geoObject.setValue(object.coordinate.longitude, forKey: "cLongitude")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    

    ///
    func getFilters() -> [String:Any] {
        filters.removeAll()

        for filterName in FILTER_FIELDS {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GeoObjects")
            fetchRequest.propertiesToFetch = [filterName]
            fetchRequest.returnsDistinctResults = true
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: filterName, ascending: true)]
            fetchRequest.resultType = .dictionaryResultType

            let filterValues = try? managedContext.fetch(fetchRequest) as! [[String: Any]]


            if filterName == "duration" {
                var valuesArray:[Int:Bool] = [:]
                for item in filterValues! {
                    if let value = item[filterName] {
                        valuesArray[value as! Int] = true
                    }
                }
                filters[filterName] = valuesArray
            } else {
                var valuesArray:[String:Bool] = [:]
                for item in filterValues! {
                    if let value = item[filterName] {
                        valuesArray[value as! String] = true
                    }
                }
                filters[filterName] = valuesArray
            }

        }

        return filters
    }
    
    
    ///
    func geoObjectsExists() -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GeoObjects")
        
        do {
            let count = try managedContext.count(for: fetchRequest)
            return count > 0
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
    
    ///
    func removeAllObjects() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GeoObjects")
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                managedContext.delete(object)
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
        }
    }
    
}
