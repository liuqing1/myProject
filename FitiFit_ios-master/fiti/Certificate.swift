//
//  Certificate.swift
//  fiti
//
//  Created by Matthew Mayer on 21/03/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import Foundation
import RealmSwift;
class Certificate : Object {
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var url: String = ""
    dynamic var skill: Skill?
}
