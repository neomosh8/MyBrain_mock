//
//  Item.swift
//  My Brain
//
//  Created by Mojtaba Rabiei on 2025-01-18.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
