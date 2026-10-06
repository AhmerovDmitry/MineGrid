//
//  GameLogicProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Протокол для игровой логики
protocol GameLogicProtocol {
    /// Открывает ячейку и выполняет необходимые действия
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    ///   - board: Игровое поле (isFirstMove изменяется внутри функции)
    ///   - mineGenerator: Генератор мин
    /// - Returns: Результат открытия ячейки
    func openCell(
        row: Int,
        column: Int,
        board: inout GameBoardModel,
        mineGenerator: MineGeneratorProtocol
    ) -> CellOpenResult
    
    /// Выполняет flood fill для открытия соседних пустых ячеек
    /// - Parameters:
    ///   - row: Начальная строка
    ///   - column: Начальный столбец
    ///   - board: Игровое поле
    func floodFill(row: Int, column: Int, board: inout GameBoardModel)
    
    /// Открывает все мины на поле
    /// - Parameter board: Игровое поле
    func revealAllMines(board: inout GameBoardModel)
}

/// Результат открытия ячейки
enum CellOpenResult {
    case success
    case mineExploded
    case alreadyOpened
    case flagged
    case invalidPosition
}
