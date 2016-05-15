//
//  Trainer.swift
//  fiti
//
//  Created by Matthew Mayer on 15/12/2015.
//  Copyright © 2015 ReignDesign. All rights reserved.
//


import RealmSwift
import MapKit;
import SwiftyJSON;
class Trainer: Object {
    dynamic var id: String = ""
    dynamic var name: String = "Untitled Trainer"
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var location: String = ""
    dynamic var phone: String = ""
    dynamic var price:Int = 300
    dynamic var status:Int = 0
    dynamic var profile:String = ""
    dynamic var videoURL:String = ""
    dynamic var gender:String = "M"
    dynamic var videoPosterURL:String = ""
    dynamic var bio:String = ""
    dynamic var experience:String=""
    dynamic var qualifications:String=""
    dynamic var country:String=""
    dynamic var city:String=""
    
    dynamic var school:String=""
    dynamic var admission:String=""
    dynamic var department:String=""
    dynamic var districts_string:String=""
    dynamic var averageRating:Double = 3.0
    
    var skills = List<Skill>()
    var skillCertificates = List<Certificate>();

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getOptionalProfileImageURL()->NSURL? {
        if profile.isEmpty {
            return nil
        }
        return NSURL(string:profile)
    }
    
    func coordinate()->CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
    }

    func localizedSkillList()->String {
        let skillNames = self.skills.map { (skill) -> String in
            return skill.localizedName() ?? ""
        }
        return skillNames.joinWithSeparator("list_separator".localized)
        
    }
    
    var districts:[String] {
        get {
            return districts_string.componentsSeparatedByString(",")
        }
    }
    var education:String {
        get {
            return "\(admission)\n\(department)\n\(school)"
        }
    }
    func setDistrictsWithArray(v:[String]) {
        districts_string = v.joinWithSeparator(",")
    }
    func getFriendlyLocation()->String {
        if districts_string != "" && districts.count>0 {
            return districts.joinWithSeparator(", ")
        } else {
            return city.capitalizedString ?? ""
        }
    }
    static func fromJSON(json:JSON)->Trainer {
        let t = Trainer()
        t.name = json["name"].string ?? ""
        t.bio = json["bio"].string ?? ""
        t.id = json["_id"].string ?? ""
        t.country = json["country"].string ?? ""
        t.city = json["city"].string ?? ""
        t.experience = json["experience"].string ?? ""
        t.gender = json["gender"].string ?? "M"
        t.price = json["price"].int ?? 300
        t.phone = json["phone"].string ?? ""
        t.profile = json["profile"].string ?? ""
        t.qualifications = json["qualifications"].string ?? ""
        t.school = json["school"].string ?? ""
        t.admission = json["admission"].string ?? ""
        t.department = json["department"].string ?? ""
        t.latitude = json["latitude"].double ?? 0
        t.longitude = json["longitude"].double ?? 0
        t.status = json["status"].int ?? 0
        t.videoURL = json["video"].string ?? ""
        t.averageRating = json["average_rating"].double ?? 3.0
        t.skillCertificates.removeAll()
        if let arr = json["skill_certs"].array {
            for json in arr {
                let title = json["title"].string ?? ""
                let url = json["url"].string ?? ""
                let skill = json["skill"].string ?? ""
                let cert = Certificate()
                cert.title = title
                cert.url = url
                cert.skill = Skill.skillById(skill)
                t.skillCertificates.append(cert)
            }
        }
        
        ////if you're in demo mode, randomise the pins a little
        if Constants.Values.DemoMode {
            let randomdub1:Double = Double(CGFloat(Float(arc4random()) / Float(UINT32_MAX)-0.5) * 0.008)
            t.latitude = t.latitude + randomdub1
            let randomdub2:Double = Double(CGFloat(Float(arc4random()) / Float(UINT32_MAX)-0.5) * 0.012)
            t.longitude = t.longitude + randomdub2
        }
        
        t.districts_string = json["districts"].arrayValue.map { "\($0)" }.joinWithSeparator(",")
        
        for (_,skillJSON):(String, JSON) in json["skills"] {
            if let str = skillJSON.string, skill = Skill.skillById(str) {
                t.skills.append(skill)
            }
        }
        return t
    }
    func setSkillsByIds(ids:[String]) {
        skills.removeAll()
        for id in ids {
            if let skill = Skill.skillById(id) {
                skills.append(skill)
            }
        }
    }
    func isBigCity()->Bool {
        let cityDistrictDict:[String: AnyObject] = Util.loadJsonDict("locations") ?? [String: AnyObject]()
        return cityDistrictDict[city.lowercaseString] != nil
    }
    
}
