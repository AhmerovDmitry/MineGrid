//
//  GameStorageProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftData

/// Протокол для сохранения и загрузки игр
protocol GameStorageProtocol {
    /// Сохраняет текущее состояние игры
    /// - Parameters:
    ///   - gameState: Состояние игры
    ///   - board: Игровое поле
    ///   - difficulty: Уровень сложности
    ///   - elapsedTime: Прошедшее время
    ///   - flaggedCount: Количество флагов
    ///   - modelContext: Контекст SwiftData
    func saveGame(
        gameState: GameState,
        board: GameBoardModel,
        difficulty: Difficulty,
        elapsedTime: Int,
        flaggedCount: Int,
        modelContext: ModelContext
    )
    
    /// Загружает сохраненную игру
    /// - Parameter modelContext: Контекст SwiftData
    /// - Returns: Сохраненная игра или nil, если сохранений нет
    func loadSavedGame(modelContext: ModelContext) -> SavedGame?
    
    /// Удаляет сохраненную игру
    /// - Parameter modelContext: Контекст SwiftData
    func deleteSavedGame(modelContext: ModelContext)
    
    /// Проверяет наличие незавершенной сохраненной игры
    /// - Parameter modelContext: Контекст SwiftData
    /// - Returns: true, если есть незавершенная игра
    func hasActiveSavedGame(modelContext: ModelContext) -> Bool
}

