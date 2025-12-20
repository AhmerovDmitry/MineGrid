//
//  GameRulesService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import Foundation

/// Сервис для правил игры
final class GameRulesService {

    // MARK: - Properties

    private let logger: LogService

    // MARK: - Initialization

    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "GameRules")) {
        self.logger = logger
    }

    // MARK: - Game Rules

    /// Проверяет условие победы
    /// - Parameters:
    ///   - board: Игровое поле
    ///   - mineCount: Количество мин
    /// - Returns: true, если игра выиграна
    func checkWinCondition(board: GameBoardModel, mineCount: Int) -> Bool {
        let totalCells = board.size * board.size
        let totalNonMineCells = totalCells - mineCount
        
        var openedCount = 0
        var allMinesFlagged = true
        
        // Проверяем все ячейки на поле
        for row in 0..<board.size {
            for column in 0..<board.size {
                let cell = board.cells[row][column]
                
                if cell.state == .opened {
                    openedCount += 1
                }
                
                // Проверяем, все ли мины помечены флагами
                if cell.isMine && cell.state != .flagged {
                    allMinesFlagged = false
                }
            }
        }
        
        // Условие победы:
        // 1. Все не-мины открыты ИЛИ
        // 2. Все мины помечены флагами
        let won = openedCount == totalNonMineCells || allMinesFlagged
        
        if won {
            logger.info("Win condition met: opened=openedCount/totalNonMineCells")
        }
        
        return won
    }

    /// Проверяет, можно ли установить флаг на ячейку
    /// - Parameters:
    ///   - cell: Ячейка
    ///   - flaggedCount: Текущее количество флагов
    ///   - maxFlags: Максимальное количество флагов
    /// - Returns: true, если флаг можно установить
    func canPlaceFlag(cell: CellModel, flaggedCount: Int, maxFlags: Int) -> Bool {
        guard cell.state == .closed else {
            return false
        }
        
        guard flaggedCount < maxFlags else {
            return false
        }
        
        return true
    }

    /// Проверяет, можно ли открыть ячейку
    /// - Parameters:
    ///   - cell: Ячейка
    ///   - gameState: Текущее состояние игры
    /// - Returns: true, если ячейку можно открыть
    func canOpenCell(cell: CellModel, gameState: GameState) -> Bool {
        guard gameState.isActive else {
            return false
        }
        
        guard cell.state != .opened else {
            return false
        }
        
        guard cell.state != .flagged else {
            return false
        }
        
        return true
    }

    /// Проверяет, завершена ли игра
    /// - Parameter gameState: Текущее состояние игры
    /// - Returns: true, если игра завершена
    func isGameFinished(gameState: GameState) -> Bool {
        return gameState.isFinished
    }
}