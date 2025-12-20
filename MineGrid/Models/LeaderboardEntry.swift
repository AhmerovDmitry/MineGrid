//
//  LeaderboardEntry.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import Foundation

/// Модель записи в таблице лидеров
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let username: String
    let date: Date
    let time: TimeInterval
    let difficulty: Difficulty
}