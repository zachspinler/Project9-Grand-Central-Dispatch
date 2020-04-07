//
//  Petition.swift
//  Project9-Grand Central Dispatch
//
//  Created by Zach Spinler on 4/7/20.
//  Copyright © 2020 Zach Spinler. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
