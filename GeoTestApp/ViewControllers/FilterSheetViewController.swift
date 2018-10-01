//
//  FilterSheetViewController.swift
//  GeoTestApp
//
//  Created by Admin on 9/28/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit

enum SheetLevel {
    case top, bottom, middle
}



/// Delegate Description
protocol FilterSheetDelegate {
    func updateFilterSheet(frame: CGRect)
}


///
class FilterSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GeoTagManagerDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var gripperView: UIView!
    @IBOutlet var buttonDownload: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var lastY: CGFloat = 0
    var panGesture: UIPanGestureRecognizer!
    
    var filterSheetDelegate: FilterSheetDelegate?
    var mapViewController: MapViewController!
    var parentView: UIView!
    var initalFrame: CGRect!
    let topY: CGFloat = 80
    var middleY: CGFloat = 400
    var bottomY: CGFloat = 600
    let bottomOffset: CGFloat = 64
    var lastLevel: SheetLevel = .middle
    var disableTableScroll = false
    

    let geoTagManager = GeoTagManager.shared
    var filters:[String:Any] = [:]

    
    ///
    @IBAction func buttonDownloadAction(_ sender: Any) {
        geoTagManager.requestGeoTags()
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        geoTagManager.delegate = self

        gripperView.layer.cornerRadius = 2.5
        buttonDownload.layer.borderWidth = 1.0
        buttonDownload.layer.cornerRadius = 5
        buttonDownload.layer.borderColor = buttonDownload.titleColor(for: .normal)?.cgColor

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        self.mainView.addGestureRecognizer(panGesture)
        self.tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        
        filters = geoTagManager.dataBaseManager.getFilters()
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initalFrame = UIScreen.main.bounds
        self.middleY = initalFrame.height * 0.6
        self.bottomY = initalFrame.height - bottomOffset
        self.lastY = self.middleY
        
        filterSheetDelegate?.updateFilterSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
    }

    ///
    override func viewDidAppear(_ animated: Bool) {
        updateTagsOnMap()
    }
    
    
    ///
    func updateTagsOnMap() {
        let geoObjectsArray = geoTagManager.getObjectsArray(filters: [:])
        mapViewController.showOnMap(objects: geoObjectsArray)
    }
    

    
    
    
    
    
    // MARK: -- GeoTagManagerDelegate
    func geoObjectsRecieved() {
        filters = geoTagManager.dataBaseManager.getFilters()
        tableView.reloadData()
        updateTagsOnMap()
    }

    
    
    
    
 
    // MARK: -- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keysArray = Array(filters.keys)
        let filterName = keysArray[section]

        if filterName == "duration" {
            let values = (filters[filterName] as! [Int:Bool])
            return values.keys.count
        } else {
            let values = (filters[filterName] as! [String:Bool])
            return values.keys.count
        }
    }
    
    ///
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keysArray = Array(filters.keys)
        let filterName = keysArray[section]
        return filterName
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRecordTVC", for: indexPath) as! FilterRecordTableViewCell

        let keysArray = Array(filters.keys)
        let filterName = keysArray[indexPath.section]
        let valuesArray = filters[filterName]

        if filterName == "duration" {
            let values = valuesArray as! [Int:Bool]
            let currentValue = Array(values.keys)[indexPath.row]
            cell.setValue(currentValue.description)
            cell.enabled = values[currentValue] ?? true
        }
        if filterName == "color" {
            let values = valuesArray as! [String:Bool]
            let color = Array(values.keys)[indexPath.row]
            cell.setColor(UIColor(hex: color) ?? UIColor.white)
            cell.enabled = values[color] ?? true
        }
        if filterName == "type" {
            let values = valuesArray as! [String:Bool]
            let currentValue = Array(values.keys)[indexPath.row]
            cell.setValue(currentValue)
            cell.enabled = values[currentValue] ?? true
        }
        return cell
    }

    
    
    
    
    // MARK: -- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FilterRecordTableViewCell
        cell.toggleSwitch()
        tableView.deselectRow(at: indexPath, animated: true)

        
        let filtersArray = Array(filters.keys)
        let filterName = filtersArray[indexPath.section]


        if filterName == "duration" {
            var filterValues = (filters[filterName] as! [Int:Bool])
            let filterValue = Array(filterValues.keys)[indexPath.row]
            
            filterValues[filterValue] = cell.enabled
            filters[filterName] = filterValues
        } else {
            var filterValues = (filters[filterName] as! [String:Bool])
            let filterValue = Array(filterValues.keys)[indexPath.row]
            
            filterValues[filterValue] = cell.enabled
            filters[filterName] = filterValues
        }

        let geoObjectsArray = geoTagManager.getObjectsArray(filters: filters)
        mapViewController.showOnMap(objects: geoObjectsArray)
    }
    
    ///
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    

    
    
    
    
    // MARK: -- Buttom Sheet View helper methods
    /// Handle Pan Gesture
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        if self.tableView.contentOffset.y > 0 {
            return
        }
        
        let dy = recognizer.translation(in: self.parentView).y
        switch recognizer.state {
        case .changed:
            if self.tableView.contentOffset.y <= 0 {
                let maxY = max(topY, lastY + dy)
                let y = min(bottomY, maxY)
                filterSheetDelegate?.updateFilterSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            }
            
            if self.parentView.frame.minY > topY {
                self.tableView.contentOffset.y = 0
            }
        case .failed, .ended, .cancelled:
            self.mainView.isUserInteractionEnabled = false
            
            self.disableTableScroll = (self.lastLevel != .top)
            
            self.lastY = self.parentView.frame.minY
            self.lastLevel = self.nextLevel(recognizer: recognizer)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                
                switch self.lastLevel {
                case .top:
                    self.filterSheetDelegate?.updateFilterSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.topY))
                    self.tableView.contentInset.bottom = self.topY + 50
                case .middle:
                    self.filterSheetDelegate?.updateFilterSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
                case .bottom:
                    self.filterSheetDelegate?.updateFilterSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.bottomY))
                }
            }) { (_) in
                self.mainView.isUserInteractionEnabled = true
                self.lastY = self.parentView.frame.minY
            }
            
        default:
            break
        }
    }
    ///
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tableView else { return }
        if (self.parentView.frame.minY > topY) {
            self.tableView.contentOffset.y = 0
        }
    }
    // Stops unintended tableview scrolling while animating to top
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == tableView else { return }
        if disableTableScroll {
            targetContentOffset.pointee = scrollView.contentOffset
            disableTableScroll = false
        }
    }
    /// Buttom Sheet states
    func nextLevel(recognizer: UIPanGestureRecognizer) -> SheetLevel {
        let y = self.lastY
        let velY = recognizer.velocity(in: self.view).y
        if velY < -200 {
            return y > middleY ? .middle : .top
        } else if velY > 200 {
            return y < (middleY + 1) ? .middle : .bottom
        } else {
            if y > middleY {
                return (y - middleY) < (bottomY - y) ? .middle : .bottom
            } else {
                return (y - topY) < (middleY - y) ? .top : .middle
            }
        }
    }
    
    
}



extension FilterSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
