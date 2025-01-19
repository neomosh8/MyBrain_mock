//
//  ViewModels.swift
//  My Brain
//
//  Created by Mojtaba Rabiei on 2025-01-18.
//

import Foundation
// MARK: - CardModel
struct CardModel: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct AudioText: Codable {
    let text: String
    let words: [Word]
}

struct Word: Codable, Identifiable {
    let id = UUID()
    let word: String
    let start: Double
    let end: Double
}
