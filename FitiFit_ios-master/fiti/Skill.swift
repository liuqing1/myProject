//
// Created by Tuo on 1/6/16.
// Copyright (c) 2016 ReignDesign. All rights reserved.
//

import UIKit
import RealmSwift
class Skill: Object,Equatable {
    dynamic var id: String?
    dynamic var zhName:String?
    dynamic var enName:String?
    
    dynamic var enDescription:String?
    dynamic var zhDescription:String?

    dynamic var enMuscles:String?
    dynamic var zhMuscles:String?
    
    dynamic var enEquipment:String?
    dynamic var zhEquipment:String?
    
    dynamic var category:String?
    
    dynamic var icon:String?
    
    static private var allSkillsArr:[Skill]?
    
    
    

    func localizedDesciption()->String? {
        if Util.isChinese() {
            return zhDescription
        }
        return enDescription
    }
    func localizedName()->String? {
        if Util.isChinese() {
            return zhName
        }
        return enName
    }
    func localizedMuscles()->String? {
        if Util.isChinese() {
            return zhMuscles
        }
        return enMuscles
    }
    func localizedEquipment()->String? {
        if Util.isChinese() {
            return zhEquipment
        }
        return enEquipment
    }
    func pinImageSelected(selected:Bool)->UIImage {
        let im1 = UIImage(named: "pin-big-\(icon!)")
        let im2 = UIImage(named: "pin-small-\(icon!)")
        let bigpin = UIImage(named:"pin-big")!
        let smallpin = UIImage(named:"pin-small")!
        
        return selected ? (im1 ?? bigpin) : (im2 ?? smallpin)
    }
    static func allCategories()->[String] {
        return ["workouts", "dance", "yoga", "ball", "martial", "inout", "strength"]
    }
    
    static func allSkills()->[Skill] {
        if let allSkillsArr = allSkillsArr {
            return allSkillsArr
        }
        allSkillsArr = []
        let presets:[[String: AnyObject]] = Util.loadJsonArr("mock_skills") ?? [[String: AnyObject]]()
        for skill in presets {
            let skillObj = Skill()
            skillObj.id = skill["id"] as? String
            
            skillObj.enName = skill["en_name"] as? String
            skillObj.zhName = skill["zh_name"] as? String
            
            skillObj.enDescription = skill["en_description"] as? String
            skillObj.zhDescription = skill["zh_description"] as? String
            
            skillObj.enMuscles = skill["en_muscles"] as? String
            skillObj.zhMuscles = skill["zh_muscles"] as? String
            
            skillObj.enEquipment = skill["en_equipment"] as? String
            skillObj.zhEquipment = skill["zh_equipment"] as? String
            
            skillObj.category = skill["category"] as? String
            
            skillObj.icon = skill["icon"] as? String
            
            assert(skillObj.icon != nil && UIImage(named:skillObj.icon!) != nil, "cannot find icon for \(skillObj.icon)");
            
            if let icon = skillObj.icon  {
                skillObj.icon = icon.replace(".png", withString:"")
            }
            allSkillsArr?.append(skillObj)
        }
        return allSkillsArr!
    }
    static func allSkillsInCategory(category:String)->[Skill] {
        let skills = allSkills()
        let filtered = skills.filter {
            return category == $0.category
        }
        return filtered
    }
    static func skillById(id: String) -> Skill? {
        let skills = allSkills()
        let filtered = skills.filter {
            if let _id = $0["id"] as? String {
                return _id == id
            }
            return false
        }
        return filtered.first
    }
}

func == <T: Skill>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}


