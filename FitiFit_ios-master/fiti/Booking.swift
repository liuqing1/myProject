//
//  Booking.swift
//  fiti
//
//  Created by Matthew Mayer on 22/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit
import SwiftyJSON

enum BookingStatus:String {
    case Unconfirmed="unconfirmed"
    case Confirmed="confirmed"
    case Rejected="rejected"
    case Cancelled="cancelled"
    case Skipped="skipped"
    case Withdrawn="withdrawn"
    case Expired="expired"
    case Completed="completed"
    case InProgress="inprogress"
    case Pending="pending"
    case Paid="paid"
    case Unknown="unknown"
}

class Booking: Object {
    dynamic var trainer:Trainer?=nil
    dynamic var trainee:Trainee?=nil
    dynamic var id:String?=nil
    dynamic var duration:Int=0
    dynamic var cost:Double=0
    dynamic var startTime:NSDate?=nil
    dynamic var actualStartTime:NSDate?=nil
    dynamic var people:Int=1
    dynamic var skill:Skill?=nil
    dynamic var latitude:Double=0
    dynamic var longitude:Double=0
    dynamic var location:String?
    dynamic var rated:Bool = false
    dynamic var status_string:String?
    
    
    
    
    
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return formatter
    }()
    
    private static var shortLocalDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    private static var shortLocalDateFormatterDateOnly: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()

    var endTime:NSDate? {
        get {
            return self.startTime?.dateByAddingTimeInterval(Double(duration)*60)
        }
    }
    var status:BookingStatus {
        return BookingStatus(rawValue: status_string ?? "unknown") ?? .Unknown
    }
    
    var bestAvailableStartTime:NSDate {
        get {
            if let time = actualStartTime {
                return time
            } else if let time = startTime {
                return time
            } else {
                return APIManager.shared.serverTime
            }
        }
    }
    var bestAvailableEndTime:NSDate {
        get {
            return bestAvailableStartTime.dateByAddingTimeInterval(Double(duration)*60)
        }
    }
    var isTimeUp:Bool {
        get {
            return APIManager.shared.serverTime > bestAvailableEndTime
        }
    }
    
    func coordinate()->CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    func niceLocation()->String {
        return location?.componentsSeparatedByString(",").first ?? "?"
    }
    func quickDescription()->String  {
        guard let trainee = trainee, skillname = skill?.localizedName() else {
            return ""
        }
        return "\(trainee.name), \(skillname), \(niceLocation())"
    }
    func descriptionForTrainee()->String  {
        guard let trainer = trainer, skillname = skill?.localizedName() else {
            return "Fiti Payment"
        }
        return String(format:"payment_detail".localized,trainer.name, skillname, duration.inHours(), niceLocation())
    }
    func descriptionForTrainer()->String {
        guard let skillname = skill?.localizedName(), time=startTime else {
            return ""
        }
        return String(format:"request_detail".localized,skillname, NSNumber(double: Double(duration)/60), Booking.shortLocalDateFormatter.stringFromDate(time), niceLocation())
    }
    func niceDate()->String {
        guard let time=startTime else {
            return ""
        }
        return Booking.shortLocalDateFormatterDateOnly.stringFromDate(time)
    }
    func markCompleted() {
        status_string = BookingStatus.Completed.rawValue
    }
    func markPaid() {
        status_string = BookingStatus.Paid.rawValue
    }
    static func fromJSON(json:JSON)->Booking {
        let b = Booking()
        b.id = json["_id"].string
        b.trainer = Trainer.fromJSON(json["trainer"])
        b.trainee = Trainee.fromJSON(json["trainee"])
        b.duration = json["duration"].int ?? 0
        b.startTime = dateFormatter.dateFromString(json["startTime"].string ?? "")
        b.actualStartTime = dateFormatter.dateFromString(json["actualStartTime"].string ?? "")
        b.location = json["location"].string ?? ""
        b.cost = json["cost"].double ?? 0
        b.people = json["people"].int ?? 1
        b.latitude = json["latitude"].double ?? 0
        b.longitude = json["longitude"].double ?? 0
        b.status_string = json["status"].string
        b.rated = json["rated"].bool ?? false
        if let skill_id = json["skill"]["_id"].string {
            b.skill = Skill.skillById(skill_id)
        }
        return b
    }
}
