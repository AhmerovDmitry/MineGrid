//
//  SavedGame.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftData

/// Модель сохраненной игры для продолжения игры после выхода
@Model
final class SavedGame {
    /// Уровень сложности
    var difficulty: String
    /// Размер поля
    var boardSize: Int
    /// Количество мин
    var mineCount: Int
    /// Состояние игры (notStarted, playing, won, lost)
    var gameState: String
    /// Прошедшее время в секундах
    var elapsedTime: Int
    /// Количество установленных флагов
    var flaggedCount: Int
    /// Флаг первого хода
    var isFirstMove: Bool
    /// Данные ячеек в формате JSON
    var cellsData: Data
    /// Дата сохранения
    var savedDate: Date
    
    /// Инициализатор сохраненной игры
    /// - Parameters:
    ///   - difficulty: Уровень сложности
    ///   - boardSize: Размер поля
    ///   - mineCount: Количество мин
    ///   - gameState: Состояние игры
    ///   - elapsedTime: Прошедшее время
    ///   - flaggedCount: Количество флагов
    ///   - isFirstMove: Флаг первого хода
    ///   - cellsData: Данные ячеек
    init(difficulty: String, boardSize: Int, mineCount: Int, gameState: String, elapsedTime: Int, flaggedCount: Int, isFirstMove: Bool, cellsData: Data, savedDate: Date) {
        self.difficulty = difficulty
        self.boardSize = boardSize
        self.mineCount = mineCount
        self.gameState = gameState
        self.elapsedTime = elapsedTime
        self.flaggedCount = flaggedCount
        self.isFirstMove = isFirstMove
        self.cellsData = cellsData
        self.savedDate = savedDate
    }
}

/// Структура для сериализации ячейки
struct CellData: Codable {
    let row: Int
    let column: Int
    let isMine: Bool
    let adjacentMines: Int
    let state: String
}

