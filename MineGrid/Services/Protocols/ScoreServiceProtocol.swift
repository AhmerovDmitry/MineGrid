//
//  ScoreServiceProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftData

/// Протокол для работы с результатами игр
protocol ScoreServiceProtocol {
    /// Сохраняет результат игры
    /// - Parameters:
    ///   - playerName: Имя игрока
    ///   - time: Время прохождения
    ///   - difficulty: Уровень сложности
    ///   - boardSize: Размер поля
    ///   - mineCount: Количество мин
    ///   - modelContext: Контекст SwiftData
    func saveResult(
        playerName: String,
        time: Int,
        difficulty: Difficulty,
        boardSize: Int,
        mineCount: Int,
        modelContext: ModelContext
    ) throws
}

