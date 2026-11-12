//
//  Item.swift
//  shelved-ios
//
//  Created by Pauly Rodriguez on 11/12/26.
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
