//
//  GameState.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Состояние игры
enum GameState: String, Codable, Equatable {
    /// Игра не начата
    case notStarted = "notStarted"
    /// Игра в процессе
    case playing = "playing"
    /// Игра выиграна
    case won = "won"
    /// Игра проиграна
    case lost = "lost"
    
    /// Проверяет, является ли игра активной (не завершена)
    var isActive: Bool {
        self == .notStarted || self == .playing
    }
    
    /// Проверяет, завершена ли игра
    var isFinished: Bool {
        self == .won || self == .lost
    }
}

