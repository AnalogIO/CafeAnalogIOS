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
        days = JSONFetch.getCache().schedule
        let table = self.view as! UITableView
        table.reloadData()
    }
}

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var firstTimeSlot: UILabel!
    @IBOutlet weak var secondTimeSlot: UILabel!
    @IBOutlet weak var thirdTimeSlot: UILabel!
}