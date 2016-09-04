//
//  ScheduleViewController.swift
//  Café Analog
//
//  Created by Anders Fischer-Nielsen on 29/02/16.
//  Copyright © 2016 Anders Fischer-Nielsen. All rights reserved.
//

import UIKit
import Alamofire

class ScheduleTableViewController: UITableViewController {
    var days: [Day] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        fetch()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        //+1 to add the last extra row
        return days.count + 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Check if last cell.
        let row = tableView.numberOfRowsInSection(indexPath.section)
        if (indexPath.row == row-1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("GitHubCell", forIndexPath: indexPath) as! GitHubTableViewCell
            return cell
        }
        
        //If not last cell, add schedule.
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeSlotCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        let day = days[indexPath.row]
        
        cell.dayLabel.text = day.day
        setBorder(cell.firstTimeSlot, open: day.first)
        setBorder(cell.secondTimeSlot, open: day.second)
        setBorder(cell.thirdTimeSlot, open: day.third)
        cell.userInteractionEnabled = false
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Check if last cell.
        let row = tableView.numberOfRowsInSection(indexPath.section)
        if (indexPath.row == row-1) {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string:"http://www.github.com/analogio/cafeanalogios")!)
        }
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
                            let NSDay = getNSDay(start)
                            
                            let startHour = getHourFromDate(start)
                            let endHour = getHourFromDate(end)
                            
                            if toReturn[formattedDay] == nil {
                                toReturn[formattedDay] = Day(day: formattedDay, first: false, second: false, third: false, NSDateDay: NSDay)
                            }
                            if (startHour >= 8 && endHour <= 10) {
                                toReturn[formattedDay]?.first = true
                            }
                            if (startHour >= 10 && endHour <= 13) {
                                toReturn[formattedDay]?.second = true
                            }
                            if (startHour >= 13) {
                                toReturn[formattedDay]?.third = true
                            }
                        }
                    }
                }
            }
        }
        
        return toReturn.values.sort({ (first: Day, second: Day) -> Bool in return first.NSDateDay < second.NSDateDay })
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
    
    func getNSDay(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar();
        return calendar.component(.Day, fromDate: date)
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

class GitHubTableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        reload()
    }
    func reload() {
        if selected {
            contentView.backgroundColor = .whiteColor()
        }
    }

}

class Day {
    let day: String
    var first: Bool
    var second: Bool
    var third: Bool
    let NSDateDay: Int
    
    init(day: String, first: Bool, second: Bool, third: Bool, NSDateDay: Int) {
        self.day = day
        self.first = first
        self.second = second
        self.third = third
        self.NSDateDay = NSDateDay
    }
}