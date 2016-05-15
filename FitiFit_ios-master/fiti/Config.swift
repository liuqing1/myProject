//
//  Config.swift
//  fiti
//
//  Created by Juan-Manuel Fluxá on 1/15/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation

class Config {
    static let shared = Config()
    
    private var dict : Dictionary<String,String>!
    
    init() {
        if let url = NSBundle.mainBundle().URLForResource("Config", withExtension: "json") {
            if let data = NSData(contentsOfURL: url) {
                if let dict = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? Dictionary<String,String> {
                    self.dict = dict
                    return
                }
            }
            
        }
        NSException(name: "Missing Config.json for environment", reason: "Cannot parse Config.json file", userInfo: nil).raise()
    }
    
    func getStr(key : String) -> String {
        if let str = dict[key] {
            return str
        }
        NSException(name: "Config key not found", reason: "Key \(key) nor found in config file", userInfo: nil).raise()
        return ""
    }
}
