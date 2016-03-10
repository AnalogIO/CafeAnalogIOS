//
// Created by Anders Fischer-Nielsen on 10/03/16.
// Copyright (c) 2016 Jacob Benjamin Cholewa. All rights reserved.
//

import Foundation
import Alamofire

class JSONFetch {
    let cache: JSONCache
    
    init() {
        self.cache = getCache()
    }
    
    private func getCache() -> JSONCache {
        //If five minutes have passed since last cache, fetch new data.
        if self.cache.created.timeIntervalSinceNow/60 > 5 {
            return fetchData()
        }

        //otherwise return cached data.
        return self.cache
    }

    func fetchData() -> JSONCache! {
        var open: Bool?
        var schedule: [Day]?

        Alamofire.request(.GET, "http://cafeanalog.dk/api/open/")
        .responseJSON { response in switch response.result {
        case .Success(let JSON):
            let response = JSON as! NSDictionary
            open = response.objectForKey("open") as? Bool
        case .Failure(let error):
            print("Request failed with error: \(error)")
        }
        }

        Alamofire.request(.GET, "http://cafeanalog.dk/api/shifts/")
        .responseJSON { response in switch response.result {
        case .Success(let JSON):
            let response = JSON as! [NSDictionary]
            schedule = self.parseDictionaryToDays(response)
        case .Failure(let error):
            print("Request failed with error: \(error)")
        }
        }

        if let open = open {
            if let schedule = schedule {
                return JSONCache(open: open, schedule: schedule)
            }
        }
        return cache
    }

    func parseDictionaryToDays(data: [NSDictionary]) -> [Day] {
        var toReturn = [String: Day]()

        for timeSlotData in data {
            if let open = timeSlotData["Open"] as? String {
                if let close = timeSlotData["Close"] as? String {
                    if let start = jsonDateToNSDate(open) {
                        if let end = jsonDateToNSDate(close) {
                            let formattedDay = formatDateWithString("EEEE", toFormat: start)
                            let NSDay = dayOfMonthFrom(start)

                            let startHour = hourFrom(start)
                            let endHour = hourFrom(end)

                            if toReturn[formattedDay] == nil {
                                toReturn[formattedDay] = Day(day: formattedDay, first: false, second: false, third: false, NSDateDay: NSDay)
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

        let sorted = toReturn.values.sort({ (first: Day, second: Day) -> Bool in return first.NSDateDay < second.NSDateDay })
        return sorted
    }
    
    func jsonDateToNSDate(jsonDate: String) -> NSDate? {
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFor.dateFromString(jsonDate)!
    }
    
    func formatDateWithString(format: String, toFormat date: NSDate) -> String {
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(forSecondsFromGMT: 3600)
        df.dateFormat = format
        let stringFromDate = df.stringFromDate(date)
        return stringFromDate
    }
    
    func dayOfMonthFrom(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar();
        return calendar.component(.Day, fromDate: date)
    }
    
    func hourFrom(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        return components.hour
    }
}

class JSONCache {
    let created = NSDate()
    let open: Bool
    let schedule: [Day]

    init(open:Bool, schedule: [Day]) {
        self.open = open
        self.schedule = schedule
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
