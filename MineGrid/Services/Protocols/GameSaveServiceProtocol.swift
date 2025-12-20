//
//  GameSaveServiceProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import Foundation
import SwiftData

/// Протокол для сервиса сохранения и загрузки игр
protocol GameSaveServiceProtocol {
    /// Сохраняет текущее состояние игры
    /// - Parameters:
    ///   - gameState: Состояние игры
    ///   - board: Игровое поле
    ///   - difficulty: Уровень сложности
    ///   - elapsedTime: Прошедшее время
    ///   - flaggedCount: Количество установленных флагов
    ///   - modelContext: Контекст SwiftData
    func saveGame(
        gameState: GameState,
        board: GameBoardModel,
        difficulty: Difficulty,
        elapsedTime: Int,
        flaggedCount: Int,
        modelContext: ModelContext
    )

    /// Удаляет сохраненную игру
    /// - Parameter modelContext: Контекст SwiftData
    func deleteSavedGame(modelContext: ModelContext)

    /// Загружает состояние ячеек из данных
    /// - Parameter data: Данные для загрузки
    /// - Returns: Массив данных ячеек или nil в случае ошибки
    func loadCells(from data: Data) -> [CellData]?
}