//
//  GameLogicService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Сервис для игровой логики
final class GameLogicService: GameLogicProtocol {
    
    // MARK: - Properties
    
    private let logger: LogService
    
    // MARK: - Initialization
    
    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "GameLogic")) {
        self.logger = logger
    }
    
    // MARK: - GameLogicProtocol
    
    func openCell(
        row: Int,
        column: Int,
        board: inout GameBoardModel,
        mineGenerator: MineGeneratorProtocol
    ) -> CellOpenResult {
        logger.debug("Opening cell at (\(row), \(column))")
        
        // Проверка валидности позиции
        guard board.isValidPosition(row: row, column: column) else {
            logger.warning("Invalid position: (\(row), \(column))")
            return .invalidPosition
        }
        
        // Проверка состояния ячейки
        if board.cells[row][column].state == .opened {
            logger.debug("Cell already opened at (\(row), \(column))")
            return .alreadyOpened
        }
        
        if board.cells[row][column].state == .flagged {
            logger.debug("Cell is flagged at (\(row), \(column))")
            return .flagged
        }
        
        // Первый ход: размещаем мины
        if board.isFirstMove {
            logger.info("First move detected, placing mines...")
            board.isFirstMove = false
            mineGenerator.placeMines(
                on: &board,
                mineCount: board.mineCount,
                excludingRow: row,
                excludingColumn: column
            )
            logger.info("Mines placed successfully")
        }
        
        // Проверка на мину
        if board.cells[row][column].isMine {
            logger.error("Mine exploded at (\(row), \(column))")
            board.cells[row][column].state = .opened
            revealAllMines(board: &board)
            return .mineExploded
        }
        
        // Открываем ячейку
        board.cells[row][column].state = .opened
        logger.debug("Cell opened at (\(row), \(column)), adjacent mines: \(board.cells[row][column].adjacentMines)")
        
        // Если ячейка пустая, выполняем flood fill
        if board.cells[row][column].adjacentMines == 0 {
            logger.debug("Empty cell detected, starting flood fill")
            floodFill(row: row, column: column, board: &board)
        }
        
        return .success
    }
    
    func floodFill(row: Int, column: Int, board: inout GameBoardModel) {
        let startTime = Date()
        var cellsOpened = 0
        var visited = Set<String>()
        var queue = [(row: Int, column: Int)]()
        queue.append((row, column))
        visited.insert("_\(row)_\(column)")
        
        while !queue.isEmpty {
            let (r, c) = queue.removeFirst()
            
            // Проверяем всех 8 соседей
            for dr in -1...1 {
                for dc in -1...1 {
                    let newRow = r + dr
                    let newColumn = c + dc
                    
                    guard board.isValidPosition(row: newRow, column: newColumn) else {
                        continue
                    }
                    
                    let neighbor = board.cells[newRow][newColumn]
                    let key = "_\(newRow)_\(newColumn)"
                    
                    // Обрабатываем только закрытые ячейки без мин и не посещенные
                    if neighbor.state == .closed && !neighbor.isMine && !visited.contains(key) {
                        board.cells[newRow][newColumn].state = .opened
                        cellsOpened += 1
                        visited.insert(key)
                        
                        // Если ячейка тоже пустая, добавляем в очередь для дальнейшего расширения
                        if neighbor.adjacentMines == 0 {
                            queue.append((newRow, newColumn))
                        }
                    }
                }
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.debug("Flood fill completed: opened \(cellsOpened) cells in \(String(format: "%.3f", duration))s")
    }
    
    func checkWinCondition(board: GameBoardModel, mineCount: Int) -> Bool {
        let totalCells = board.size * board.size
        let totalNonMineCells = totalCells - mineCount
        
        // Оптимизация: используем ранний выход для больших полей
        var openedCount = 0
        var closedCount = 0
        var flaggedMinesCount = 0
        var allMinesFlagged = true
        
        // Для больших полей проверяем только необходимые условия
        for row in 0..<board.size {
            for column in 0..<board.size {
                let cell = board.cells[row][column]
                
                switch cell.state {
                case .opened:
                    openedCount += 1
                case .closed:
                    closedCount += 1
                case .flagged:
                    if cell.isMine {
                        flaggedMinesCount += 1
                    }
                }
                
                // Проверяем, все ли мины помечены флагами
                if cell.isMine && cell.state != .flagged {
                    allMinesFlagged = false
                }
            }
        }
        
        // Условие победы:
        // 1. Все не-мины открыты (классическое условие) ИЛИ
        // 2. Все мины помечены флагами И нет неоткрытых ячеек
        let won = openedCount == totalNonMineCells || (allMinesFlagged && closedCount == 0)
        
        if won {
            logger.info("Win condition met: opened=\(openedCount)/\(totalNonMineCells), flagged mines=\(flaggedMinesCount)/\(mineCount), closed=\(closedCount)")
        }
        
        return won
    }
    
    func revealAllMines(board: inout GameBoardModel) {
        logger.debug("Revealing all mines on \(board.size)×\(board.size) board")
        var revealedCount = 0
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.cells[row][column].isMine {
                    board.cells[row][column].state = .opened
                    revealedCount += 1
                }
            }
        }
        
        logger.info("Revealed \(revealedCount) mines")
    }
}

