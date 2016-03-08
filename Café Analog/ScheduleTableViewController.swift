//
//  ScheduleViewController.swift
//  Café Analog
//
//  Created by Anders Fischer-Nielsen on 29/02/16.
//  Copyright © 2016 Jacob Benjamin Cholewa. All rights reserved.
//

import UIKit
import Alamofire

class ScheduleTableViewController: UITableViewController {
    var days: [Day] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeSlotCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        let day = days[indexPath.row]
        
        cell.dayLabel.text = day.day
        setBorder(cell.firstTimeSlot, open: day.first)
        setBorder(cell.secondTimeSlot, open: day.second)
        setBorder(cell.thirdTimeSlot, open: day.third)
        
        cell.userInteractionEnabled = false
        return cell
    }
    
    func setBorder(label: UILabel, open: Bool) {
        if open {
            label.layer.borderColor = UIColor.blackColor().CGColor
            label.textColor = UIColor.blackColor()
        }
        else {
            label.layer.borderColor = UIColor.lightGrayColor().CGColor
        }

        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func fetch() {
        debugPrint("update")
        Alamofire.request(.GET, "http://cafeanalog.dk/api/shifts/")
        .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let response = JSON as! [NSDictionary]
                self.days = self.parseDictionaryToDays(response)
                let table = self.view as! UITableView
                table.reloadData()
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
        let table = self.view as! UITableView
        table.reloadData()
    }
    
    func parseDictionaryToDays(data: [NSDictionary]) -> [Day] {
        var toReturn = [String: Day]()
        
        for timeSlotData in data {
            if let open = timeSlotData["Open"] as? String {
                if let close = timeSlotData["Close"] as? String {
                    if let start = jsonDateToNSDate(open) {
                        if let end = jsonDateToNSDate(close) {
                            let formattedDay = formatDateWithString("EEEE", toFormat: start)
                            
                            let startHour = getHourFromDate(start)
                            let endHour = getHourFromDate(end)
                            
                            if toReturn[formattedDay] == nil {
                                toReturn[formattedDay] = Day(day: formattedDay, first: false, second: false, third: false)
                            }
                            if (startHour >= 9 && endHour < 12) {
                                toReturn[formattedDay]?.first = true
                            }
                            if (startHour >= 11 && endHour < 16) {
                                toReturn[formattedDay]?.second = true
                            }
                            if (startHour >= 14) {
                                toReturn[formattedDay]?.third = true
                            }
                        }
                    }
                }
            }
        }
        
        return Array(toReturn.values)
    }
    
    func jsonDateToNSDate(jsonDate: String) -> NSDate? {
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFor.dateFromString(jsonDate)!
    }
    
    func getHourFromDate(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        return components.hour
    }
    
    func formatDateWithString(format: String, toFormat date: NSDate) -> String {
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(forSecondsFromGMT: 3600)
        df.dateFormat = format
        let stringFromDate = df.stringFromDate(date)
        return stringFromDate
    }
}

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var firstTimeSlot: UILabel!
    @IBOutlet weak var secondTimeSlot: UILabel!
    @IBOutlet weak var thirdTimeSlot: UILabel!
}

class Day {
    let day: String
    var first: Bool
    var second: Bool
    var third: Bool
    
    init(day: String, first: Bool, second: Bool, third: Bool) {
        self.day = day
        self.first = first
        self.second = second
        self.third = third
    }
}