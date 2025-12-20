//
//  MineGeneratorService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Сервис для генерации мин на игровом поле
final class MineGeneratorService: MineGeneratorProtocol {
    
    // MARK: - Properties
    
    private let logger: LogService
    
    // MARK: - Initialization
    
    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "MineGenerator")) {
        self.logger = logger
    }
    
    // MARK: - MineGeneratorProtocol
    
    func placeMines(
        on board: inout GameBoardModel,
        mineCount: Int,
        excludingRow: Int,
        excludingColumn: Int
    ) {
        logger.debug("Placing \(mineCount) mines on \(board.size)×\(board.size) board, excluding (\(excludingRow), \(excludingColumn))")
        
        let startTime = Date()
        let totalCells = board.size * board.size
        
        // Оптимизация для больших полей: создаем список доступных позиций
        // Это более эффективно, чем случайный выбор с проверками
        var availablePositions: [(row: Int, column: Int)] = []
        availablePositions.reserveCapacity(totalCells - 9) // Исключаем первую ячейку и 8 соседей
        
        // Собираем все доступные позиции (исключая первую ячейку и её соседей)
        for row in 0..<board.size {
            for column in 0..<board.size {
                // Пропускаем первую кликнутую ячейку и её соседей
                if abs(row - excludingRow) <= 1 && abs(column - excludingColumn) <= 1 {
                    continue
                }
                availablePositions.append((row, column))
            }
        }
        
        // Проверяем, достаточно ли доступных позиций
        guard availablePositions.count >= mineCount else {
            logger.error("Not enough available positions: \(availablePositions.count) < \(mineCount)")
            return
        }
        
        // Перемешиваем массив для случайного распределения
        availablePositions.shuffle()
        
        // Размещаем мины
        for i in 0..<mineCount {
            let position = availablePositions[i]
            board.cells[position.row][position.column].isMine = true
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.info("Successfully placed \(mineCount) mines in \(String(format: "%.3f", duration))s")
        
        // Вычисляем количество соседних мин для всех ячеек
        calculateAdjacentMines(for: &board)
    }
    
    func calculateAdjacentMines(for board: inout GameBoardModel) {
        logger.debug("Calculating adjacent mines for \(board.size)×\(board.size) board")
        
        let startTime = Date()
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                if !board.cells[row][column].isMine {
                    board.cells[row][column].adjacentMines = countAdjacentMines(
                        row: row,
                        column: column,
                        board: board
                    )
                }
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.debug("Adjacent mines calculated in \(String(format: "%.3f", duration))s")
    }
    
    // MARK: - Private Methods
    
    /// Подсчитывает количество мин в соседних ячейках
    private func countAdjacentMines(row: Int, column: Int, board: GameBoardModel) -> Int {
        var count = 0
        let boardSize = board.size
        
        // Оптимизированный цикл для подсчета мин
        for dr in -1...1 {
            let newRow = row + dr
            if newRow < 0 || newRow >= boardSize { continue }
            
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                
                let newColumn = column + dc
                if newColumn >= 0 && newColumn < boardSize && board.cells[newRow][newColumn].isMine {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    /// Проверяет, является ли позиция валидной
    private func isValidPosition(row: Int, column: Int, boardSize: Int) -> Bool {
        row >= 0 && row < boardSize && column >= 0 && column < boardSize
    }
}

