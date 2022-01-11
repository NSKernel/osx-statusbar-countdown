//
//  AppDelegate.swift
//  StatusbarCountdown
//
//  Created by Ben Brooks on 31/03/2015.
//  Copyright (c) 2015 Ben Brooks. All rights reserved.
//
//  Copyright (c) 2021 NSKernel. All rights reserved.

import Cocoa
import Foundation

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PreferencesWindowDelegate {

    let DEFAULT_NAME = "Countdown Name"
    let DEFAULT_DATE = NSDate(timeIntervalSince1970: 1597249800)
    
    var countToDate = NSDate(timeIntervalSince1970: 1597249800)
    var startFromDate = NSDate(timeIntervalSince1970: 1597249800)
    var countdownName = "Countdown Name"

    var showInDays = true
    var showInTotal = false
    var showInProgress = false
    
    var showName = false
    var showSeconds = true
    var zeroPad = true
    var showTime = false
    
    var showInWeeks = false
    var showInHours = false
    var showInMinutes = false
    var showInSeconds = true
    
    var refreshTimer : Timer? = nil

    var formatter = NumberFormatter()

    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    @IBOutlet weak var statusMenu: NSMenu!
    var preferencesWindow: PreferencesWindow!
    
    func updateTimerFreq() {
        var interval: TimeInterval = 1
        
        if (showInDays && showTime && showSeconds) {
            interval = 0.5
        }
        else if (showInTotal && showInSeconds) {
            interval = 0.5
        }
        
        if (refreshTimer != nil) {
            refreshTimer!.invalidate()
        }
        refreshTimer = Timer.scheduledTimer(timeInterval: interval, // 1s ~ 1fps
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true)
        
        tick()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        statusItem.button!.title = ""
        statusItem.menu = statusMenu
        
        // Choose your own font of your taste
        // statusItem.button!.font = NSFont(name: "SF Mono Regular", size: 13)
        formatter.minimumIntegerDigits = zeroPad ? 2 : 1
        
        updatePreferences()
    }
    
    func preferencesDidUpdate() { // Delegate when setting values are updated
        updatePreferences()
    }
    
    @IBOutlet weak var showInDaysMI: NSMenuItem!
    @IBOutlet weak var showInTotalMI: NSMenuItem!
    @IBOutlet weak var showInProgressMI: NSMenuItem!
    
    @IBOutlet weak var showNameMI: NSMenuItem!
    @IBOutlet weak var showSecMI: NSMenuItem!
    @IBOutlet weak var zeroPadMI: NSMenuItem!
    @IBOutlet weak var showTimeMI: NSMenuItem!
    
    @IBOutlet weak var showInWeeksMI: NSMenuItem!
    @IBOutlet weak var showInHoursMI: NSMenuItem!
    @IBOutlet weak var showInMinutesMI: NSMenuItem!
    @IBOutlet weak var showInSecondsMI: NSMenuItem!
    @IBOutlet weak var secondarySeperator: NSMenuItem!
    
    func secondaryMenuUpdate(mode: Int) {
        showSecMI.isHidden = mode == 1 ? false : true
        zeroPadMI.isHidden = mode == 1 ? false : true
        showTimeMI.isHidden = mode == 1 ? false : true
        
        showInWeeksMI.isHidden = mode == 2 ? false : true
        showInHoursMI.isHidden = mode == 2 ? false : true
        showInMinutesMI.isHidden = mode == 2 ? false : true
        showInSecondsMI.isHidden = mode == 2 ? false : true
        
        secondarySeperator.isHidden = mode == 3 ? true : false
    }
    
    @IBAction func showInDaysClick(_ sender: NSMenuItem) {
        let defaults = UserDefaults.standard
        showInDays = true
        showInTotal = false
        showInProgress = false
        showInDaysMI.state = .on
        showInTotalMI.state = .off
        showInProgressMI.state = .off
        defaults.set(true, forKey: "showindays")
        defaults.set(false, forKey: "showintotal")
        defaults.set(false, forKey: "showinprogress")
        
        secondaryMenuUpdate(mode: 1)
        updateTimerFreq()
    }
    
    @IBAction func showInTotalClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        showInDays = false
        showInTotal = true
        showInProgress = false
        showInDaysMI.state = .off
        showInTotalMI.state = .on
        showInProgressMI.state = .off
        defaults.set(false, forKey: "showindays")
        defaults.set(true, forKey: "showintotal")
        defaults.set(false, forKey: "showinprogress")
        
        secondaryMenuUpdate(mode: 2)
        updateTimerFreq()
    }
    
    @IBAction func showInProgressClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        showInDays = false
        showInTotal = false
        showInProgress = true
        showInDaysMI.state = .off
        showInTotalMI.state = .off
        showInProgressMI.state = .on
        defaults.set(false, forKey: "showindays")
        defaults.set(false, forKey: "showintotal")
        defaults.set(true, forKey: "showinprogress")
        
        secondaryMenuUpdate(mode: 3)
        updateTimerFreq()
    }
    
    func updatePreferences() {
        let defaults = UserDefaults.standard
        
        // Gets the saved values in user defaults
        countdownName = defaults.string(forKey: "name") ?? DEFAULT_NAME
        countToDate = defaults.value(forKey: "date") as? NSDate ?? DEFAULT_DATE
        startFromDate = defaults.value(forKey: "startsfrom") as? NSDate ?? DEFAULT_DATE
        
        showInDays = defaults.value(forKey: "showindays") as? Bool ?? true
        showInTotal = defaults.value(forKey: "showintotal") as? Bool ?? false
        showInProgress = defaults.value(forKey: "showinprogress") as? Bool ?? false
        
        showSeconds = defaults.value(forKey: "showsec") as? Bool ?? true
        showName = defaults.value(forKey: "showname") as? Bool ?? false
        zeroPad = defaults.value(forKey: "zeropad") as? Bool ?? true
        showTime = defaults.value(forKey: "showtime") as? Bool ?? false
        
        showInWeeks = defaults.value(forKey: "showinweeks") as? Bool ?? false
        showInHours = defaults.value(forKey: "showinhours") as? Bool ?? false
        showInMinutes = defaults.value(forKey: "showinminutes") as? Bool ?? false
        showInSeconds = defaults.value(forKey: "showinseconds") as? Bool ?? true
        
        showInDaysMI.state = showInDays ? .on : .off
        showInTotalMI.state = showInTotal ? .on : .off
        showInProgressMI.state = showInProgress ? .on : .off
        
        showSecMI.state = showSeconds ? .on : .off
        showNameMI.state = showName ? .on : .off
        zeroPadMI.state = zeroPad ? .on : .off
        showTimeMI.state = showTime ? .on : .off
        
        showInWeeksMI.state = showInWeeks ? .on : .off
        showInHoursMI.state = showInHours ? .on : .off
        showInMinutesMI.state = showInMinutes ? .on : .off
        showInSecondsMI.state = showInSeconds ? .on : .off
        
        if (showInDays) {
            secondaryMenuUpdate(mode: 1)
        }
        else if (showInTotal) {
            secondaryMenuUpdate(mode: 2)
        }
        else if (showInProgress) {
            secondaryMenuUpdate(mode: 3)
        }
        updateTimerFreq()
    }

    // Calculates the difference in time from now to the specified date and sets the statusItem title
    @objc func tick() {
        let diffSeconds = Int(countToDate.timeIntervalSinceNow)
        let passedSeconds = -Int(startFromDate.timeIntervalSinceNow)
        
        statusItem.button!.title = (showName) ? countdownName + ": " : ""
        if (showInDays) {
            statusItem.button!.title += formatTime(diffSeconds)
        }
        else if (showInTotal) {
            statusItem.button!.title += formatTotal(diffSeconds)
        }
        else if (showInProgress) {
            statusItem.button!.title += formatProgress(diffSeconds, passedSeconds)
        }
        statusItem.button!.needsDisplay = true
    }
    
    // Convert seconds to 4 Time integers (days, hours minutes and seconds)
    func secondsToTime (_ seconds : Int) -> (Int, Int, Int, Int) {
        let days = seconds / (3600 * 24)
        var remainder = seconds % (3600 * 24)
        
        let hours = remainder / 3600
        remainder = remainder % 3600
        
        let minutes = remainder / 60
        
        let seconds = remainder % 60
        
        return (days, hours, minutes, seconds)
    }
    
    // Display seconds as Days, Hours, Minutes, Seconds.
    func formatTime(_ seconds: Int) -> (String) {
        let time = secondsToTime(abs(seconds))
        var daysStr    = (time.0 != 0) ? String(time.0) : ""
        var hoursStr = ""
        var minutesStr = ""
        var secondsStr = ""
        if (showTime) {
            daysStr    += (time.0 != 0) ? " - " : ""
            hoursStr   = (time.1 != 0 || time.0 != 0)               ? formatter.string(from: NSNumber(value: time.1))! + ":" : ""
            minutesStr = (time.2 != 0 || time.1 != 0 || time.0 != 0) ? formatter.string(from: NSNumber(value: time.2))! : ""
            secondsStr = (showSeconds) ? ":" + formatter.string(from: NSNumber(value: time.3))! : ""
        }
        let suffixStr  = (seconds < 0) ? " ago" : "" // TODO: i18n?
        return daysStr + hoursStr + minutesStr + secondsStr + suffixStr
    }
    
    func formatTotal(_ seconds: Int) -> (String) {
        if (showInWeeks) {
            let weeks = seconds / (3600 * 24 * 7)
            return formatter.string(from: NSNumber(value: weeks))!
        }
        else if (showInHours) {
            let hours = seconds / (3600)
            return formatter.string(from: NSNumber(value: hours))!
        }
        else if (showInMinutes) {
            let minutes = seconds / (60)
            return formatter.string(from: NSNumber(value: minutes))!
        }
        else {
            return formatter.string(from: NSNumber(value: seconds))!
        }
    }
    
    func formatProgress(_ seconds: Int, _ passed: Int) -> (String) {
        let secondsfloat: Float64 = Float64(seconds)
        let passedfloat: Float64 = Float64(passed)
        
        return String(NSString(format: "%.2f", 100 * passedfloat / (passedfloat + secondsfloat))) + "%"
    }

    // MenuItem click event to toggle showSeconds
    @IBAction func toggleShowSeconds(sender: NSMenuItem) {
        let defaults = UserDefaults.standard
        if (showSeconds) {
            showSeconds = false
            sender.state = .off
        } else {
            showSeconds = true
            sender.state = .on
        }
        defaults.set(showSeconds, forKey: "showsec")
        updateTimerFreq()
    }

    // MenuItem click event to toggle showName
    @IBAction func toggleShowName(sender: NSMenuItem) {
        let defaults = UserDefaults.standard
        if (showName) {
            showName = false
            sender.state = .off
        } else {
            showName = true
            sender.state = .on
        }
        defaults.set(showName, forKey: "showname")
    }

    // MenuItem click event to toggle zeroPad
    @IBAction func toggleZeroPad(sender: NSMenuItem) {
        let defaults = UserDefaults.standard
        if (zeroPad) {
            zeroPad = false
            sender.state = .off
        } else {
            zeroPad = true
            sender.state = .on
        }
        formatter.minimumIntegerDigits = zeroPad ? 2 : 1
        defaults.set(zeroPad, forKey: "zeropad")
        updateTimerFreq()
    }

    @IBAction func toggleShowTime(_ sender: NSMenuItem) {
        let defaults = UserDefaults.standard
        if (showTime) {
            showTime = false
            sender.state = .off
        } else {
            showTime = true
            sender.state = .on
        }
        defaults.set(showTime, forKey: "showtime")
        updateTimerFreq()
    }
    
    @IBAction func showInWeeksClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        showInWeeks = true
        showInHours = false
        showInMinutes = false
        showInSeconds = false
        
        showInWeeksMI.state = .on
        showInHoursMI.state = .off
        showInMinutesMI.state = .off
        showInSecondsMI.state = .off
        
        defaults.set(true, forKey: "showinweeks")
        defaults.set(false, forKey: "showinhours")
        defaults.set(false, forKey: "showinminutes")
        defaults.set(false, forKey: "showinseconds")
        updateTimerFreq()
    }
    
    @IBAction func showInHoursClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        showInWeeks = false
        showInHours = true
        showInMinutes = false
        showInSeconds = false
        
        showInWeeksMI.state = .off
        showInHoursMI.state = .on
        showInMinutesMI.state = .off
        showInSecondsMI.state = .off
        
        defaults.set(false, forKey: "showinweeks")
        defaults.set(true, forKey: "showinhours")
        defaults.set(false, forKey: "showinminutes")
        defaults.set(false, forKey: "showinseconds")
        updateTimerFreq()
    }
    
    @IBAction func showInMinutesClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        showInWeeks = false
        showInHours = false
        showInMinutes = true
        showInSeconds = false
        
        showInWeeksMI.state = .off
        showInHoursMI.state = .off
        showInMinutesMI.state = .on
        showInSecondsMI.state = .off
        
        defaults.set(false, forKey: "showinweeks")
        defaults.set(false, forKey: "showinhours")
        defaults.set(true, forKey: "showinminutes")
        defaults.set(false, forKey: "showinseconds")
        updateTimerFreq()
    }
    
    @IBAction func showInSecondsClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        showInWeeks = false
        showInHours = false
        showInMinutes = false
        showInSeconds = true
        
        showInWeeksMI.state = .off
        showInHoursMI.state = .off
        showInMinutesMI.state = .off
        showInSecondsMI.state = .on
        
        defaults.set(false, forKey: "showinweeks")
        defaults.set(false, forKey: "showinhours")
        defaults.set(false, forKey: "showinminutes")
        defaults.set(true, forKey: "showinseconds")
        updateTimerFreq()
    }
    
    // MenuItem click event to open preferences popover
    @IBAction func configurePreferences(_ sender: Any) {
        preferencesWindow.showWindow(nil)
    }
    
    // MenuItem click event to quit application
    @IBAction func quitApplication(sender: NSMenuItem) {
        NSApplication.shared.terminate(self);
    }

}
