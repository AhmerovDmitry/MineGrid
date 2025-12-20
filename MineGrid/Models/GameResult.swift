//
//  GameResult.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftData

/// Модель результата игры для сохранения в SwiftData
@Model
final class GameResult {
    /// Имя игрока
    var playerName: String
    /// Дата и время завершения игры
    var date: Date
    /// Время прохождения в секундах
    var time: Int
    /// Уровень сложности
    var difficulty: String
    /// Размер поля
    var boardSize: Int
    /// Количество мин
    var mineCount: Int
    
    /// Инициализатор результата игры
    /// - Parameters:
    ///   - playerName: Имя игрока
    ///   - date: Дата и время завершения
    ///   - time: Время прохождения в секундах
    ///   - difficulty: Уровень сложности
    ///   - boardSize: Размер поля
    ///   - mineCount: Количество мин
    init(playerName: String, date: Date, time: Int, difficulty: String, boardSize: Int, mineCount: Int) {
        self.playerName = playerName
        self.date = date
        self.time = time
        self.difficulty = difficulty
        self.boardSize = boardSize
        self.mineCount = mineCount
    }
}

