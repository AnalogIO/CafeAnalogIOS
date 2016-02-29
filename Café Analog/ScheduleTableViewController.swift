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
    var timeslots: [TimeSlot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeslots.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeSlotCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        let timeslot = timeslots[indexPath.row]
        
        cell.dayLabel.text = timeslot.day
        cell.timeslotLabel.text = timeslot.start + " - " + timeslot.end
        
        return cell
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
                self.timeslots = self.parseDictionaryToTimeSlotArray(response)
                let table = self.view as! UITableView
                table.reloadData()
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
        let table = self.view as! UITableView
        table.reloadData()
    }
    
    func parseDictionaryToTimeSlotArray(data: [NSDictionary]) -> [TimeSlot] {
        var toReturn = [TimeSlot]()
        
        for timeSlotData in data {
            if let open = timeSlotData["Open"] as? String {
                if let close = timeSlotData["Close"] as? String {
                    if let start = jsonDateToNSDate(open) {
                        if let end = jsonDateToNSDate(close) {
                            let formattedDay = formatDateWithString("EEEE", toFormat: start)
                            let formattedStart = formatDateWithString("HH:mm", toFormat: start)
                            let formattedEnd = formatDateWithString("HH:mm", toFormat: end)
                    
                            let timeslot = TimeSlot(day: formattedDay, start: formattedStart, end: formattedEnd)
                            toReturn.append(timeslot)
                        }
                    }
                }
            }
        }
        
        return toReturn
    }
    
    func jsonDateToNSDate(jsonDate: String) -> NSDate? {
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFor.dateFromString(jsonDate)!
    }
    
    func formatDateWithString(format: String, toFormat date: NSDate) -> String {
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        df.dateFormat = format
        let stringFromDate = df.stringFromDate(date)
        return stringFromDate
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeslotLabel: UILabel!
}

class TimeSlot {
    var day: String
    var start: String
    var end: String
    
    init(day: String, start: String, end: String) {
        self.day = day
        self.start = start
        self.end = end
    }
}