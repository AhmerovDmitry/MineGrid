//
//  Difficulty.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Перечисление уровней сложности игры
enum Difficulty: String, CaseIterable, Hashable {
    case beginner = "Новичок"
    case intermediate = "Средний"
    case expert = "Эксперт"
    
    /// Размер игрового поля (количество клеток по одной стороне)
    var size: Int {
        switch self {
        case .beginner:
            return 10
        case .intermediate:
            return 25
        case .expert:
            return 50
        }
    }
    
    /// Процент мин от общего количества клеток
    var minePercentage: Double {
        switch self {
        case .beginner:
            return 0.10
        case .intermediate:
            return 0.14
        case .expert:
            return 0.18
        }
    }
    
    /// Общее количество мин на поле для данного уровня сложности
    var mineCount: Int {
        let totalCells = size * size
        return Int(Double(totalCells) * minePercentage)
    }
}

