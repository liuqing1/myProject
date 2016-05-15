//
//  Util.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/11/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    struct Values {
        static let MaxTimeBeforeStartInSeconds:NSTimeInterval = 60
        static let DemoMode = false
        static let AnimationFast = 0.25
    }
    
    struct Fonts {
        static let MonsterratRegular = "Montserrat-Regular"
        static let MonsterratLight = "Montserrat-Light"
        static let MontserratUltraLight = "Montserrat-UltraLight"
        static let MontserratSemiBold = "Montserrat-SemiBold"
    }
    
    struct Colors {
        static let FitiBlue = "2F96FF"
        static let FitiGrayLight = "A4A5A9"
        static let FitiGraySuperLight = "CACAD2"
        
        static let FitiGrayDark = "585963"
    }
    struct Attributes {
        static func getFitiSpacedStyle()->[String:AnyObject] {
            let para = NSMutableParagraphStyle()
            para.lineSpacing = 8
            para.alignment = .Center
            let attrs:[String:AnyObject] = [NSParagraphStyleAttributeName:para, NSFontAttributeName:UIFont(name:Constants.Fonts.MonsterratRegular, size:15)!, NSForegroundColorAttributeName:UIColor.fitiGray()]
            return attrs
        }
        static func getFitiSpacedStyleLight()->[String:AnyObject] {
            let para = NSMutableParagraphStyle()
            para.lineSpacing = 8
            para.alignment = .Center
            let attrs:[String:AnyObject] = [NSParagraphStyleAttributeName:para, NSFontAttributeName:UIFont(name:Constants.Fonts.MonsterratLight, size:15)!, NSForegroundColorAttributeName:UIColor.fitiGray()]
            return attrs
        }
        static func getFitiSpacedStyleLightLeft()->[String:AnyObject] {
            let para = NSMutableParagraphStyle()
            para.lineSpacing = 8
            para.alignment = .Left
            let attrs:[String:AnyObject] = [NSParagraphStyleAttributeName:para, NSFontAttributeName:UIFont(name:Constants.Fonts.MonsterratLight, size:15)!, NSForegroundColorAttributeName:UIColor.fitiGray()]
            return attrs
        }
        
    }
    
    struct Notifications {
        static let OnVideoPathPicked = "OnVideoPathPicked"
    }
}

class Util {
    
    class func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName)
            print("Font Names = [\(names)]")
        }
    }

    class func isChinese()->Bool {
        if let preferred = NSLocale.preferredLanguages().first where preferred.hasPrefix("zh") {
            return true
        }
        return false
    }
    
    private class func loadJsonRawData(fileName: String) -> NSData? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") else {
            print("fail to load path: \(fileName)")
            return nil
        }
        return NSData(contentsOfFile: path)
    }
    
    class func loadJsonDict(fileName: String) -> [String: AnyObject]? {
        if let data = loadJsonRawData(fileName) {
            do
            {
                guard let jsonResult: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [String:AnyObject] else {
                    print("fail to parse dict out of json: \(fileName)")
                    return nil
                }
                return jsonResult;
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    class func loadJsonArr(fileName: String) -> [[String: AnyObject]]? {
        if let data = loadJsonRawData(fileName) {
            do
            {
                guard let jsonResult: [[String: AnyObject]] = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [[String:AnyObject]] else {
                    print("fail to parse arr out of json: \(fileName)")
                    return nil
                }
                return jsonResult;
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    
    
}