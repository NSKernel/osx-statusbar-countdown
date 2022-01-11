//
//  PreferencesWindow.swift
//  StatusbarCountdown
//
//  Created by Jacqueline Alves on 02/10/19.
//  Copyright © 2019 Ben Brooks. All rights reserved.
//
//  Copyright (c) 2021 NSKernel. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var startsFromDatePicker: NSDatePicker!
    @IBOutlet weak var nameBadInputFeedback: NSTextField!
    @IBOutlet weak var dateBadInputFeedback: NSTextField!
    @IBOutlet weak var startsLaterThanEndsFeedback: NSTextField!
    
    var delegate: PreferencesWindowDelegate?
    
    override func windowDidLoad() {
        let defaults = UserDefaults.standard
        
        super.windowDidLoad()

        self.window?.center() // Center the popover
        self.window?.makeKeyAndOrderFront(nil) // Make popover appear on top of anything else
        
        nameTextField.stringValue = defaults.string(forKey: "name") ?? ""
        startsFromDatePicker.dateValue = (defaults.value(forKey: "startsfrom") as? NSDate ?? (Date() as NSDate)) as Date
        datePicker.dateValue = (defaults.value(forKey: "date") as? NSDate ?? (Date() as NSDate)) as Date

        NSApp.activate(ignoringOtherApps: true) // Activate popover
        
        nameTextField.delegate = self
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(nameTextField.stringValue, forKey: "name")
        defaults.set(datePicker.dateValue, forKey: "date")
        defaults.set(startsFromDatePicker.dateValue, forKey: "startsfrom")
        
        delegate?.preferencesDidUpdate()
    }
    
    @IBAction func validate(_ sender: Any) {
        var validation = true
        
        if nameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) == "" { // Check if name is empty
            nameBadInputFeedback.isHidden = false
            window?.shakeWindow()
            
            validation = false
            
        }
        
        if datePicker.dateValue < Date() { // Check if date is after today
            dateBadInputFeedback.isHidden = false
            window?.shakeWindow()
            
            validation = false
        }
        
        if datePicker.dateValue < startsFromDatePicker.dateValue { // Check if starts from is later than ends at
            startsLaterThanEndsFeedback.isHidden = false
            window?.shakeWindow()
            
            validation = false
        }
        
        if validation { // Everything is ok, save values to user defaults and close popover
            save()
            close()
        }
    }
    
    @IBAction func changeDatePicker(_ sender: Any) {
        dateBadInputFeedback.isHidden = true // Hide bad input feedback when change the date
        startsLaterThanEndsFeedback.isHidden = true
    }
    
    @IBAction func closePopover(_ sender: Any) {
        close()
    }
}

extension PreferencesWindow: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        nameBadInputFeedback.isHidden = true // Hide bad input feedback when something is entered on textfield
    }
}
