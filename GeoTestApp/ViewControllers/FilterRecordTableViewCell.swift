//
//  FilterRecordTableViewCell.swift
//  GeoTestApp
//
//  Created by Admin on 9/30/18.
//  Copyright © 2018 AD. All rights reserved.
//

import UIKit

class FilterRecordTableViewCell: UITableViewCell {

    @IBOutlet var colorView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    @IBAction func switchAction(_ sender: Any) {
        _enabled = toggle.isOn
    }

    private var _enabled = true
    var enabled:Bool {
        get {
            return _enabled
        }
        set {
            _enabled = newValue
            toggle.setOn(_enabled, animated: false)
        }
    }
    
    func setValue(_ value: String) {
        title.isHidden = false
        colorView.isHidden = true
        title.text = value
    }

    func setColor(_ color: UIColor) {
        title.isHidden = true
        colorView.isHidden = false
        colorView.backgroundColor = color
    }
    
    func toggleSwitch() {
        _enabled = !_enabled
        toggle.setOn(_enabled, animated: true)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.borderWidth = 0.5
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
