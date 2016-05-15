//
//  Trainee.swift
//  fiti
//
//  Created by Matthew Mayer on 19/01/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
class Trainee: Object {
    dynamic var name: String = "Untitled Trainee"
    dynamic var id: String = ""
    dynamic var phone: String = ""
    dynamic var gender:String = "M"
    dynamic var city:String = ""
    dynamic var profile:String = ""
    dynamic var country:String = ""
    dynamic var districts_string:String=""
    
    var skills = List<Skill>()

    var districts:[String] {
        get {
            return districts_string.componentsSeparatedByString(",")
        }
    }
    func setDistrictsWithArray(v:[String]) {
        districts_string = v.joinWithSeparator(",")
    }
    func getOptionalProfileImageURL()->NSURL? {
        if profile.isEmpty {
            return nil
        }
        return NSURL(string:profile)
    }
    static func fromJSON(json:JSON)->Trainee {
        let t = Trainee()
        
        t.name = json["name"].string ?? ""
        t.id = json["_id"].string ?? ""
        t.phone = json["phone"].string ?? ""
        t.city = json["city"].string ?? ""
        t.country = json["country"].string ?? ""
        t.profile = json["profile"].string ?? ""
        t.gender = json["gender"].string ?? "M"
        for (_,skillJSON):(String, JSON) in json["skills"] {
            if let str = skillJSON.string, skill = Skill.skillById(str) {
                t.skills.append(skill)
            }
        }
        t.districts_string = json["districts"].arrayValue.map { "\($0)" }.joinWithSeparator(",")
        
        return t
    }
    override static func primaryKey() -> String? {
        return "id"
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