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

        let cell = board.cells[row][column]

        // Проверка состояния ячейки
        if cell.state == .opened {
            logger.debug("Cell already opened at (\(row), \(column))")
            return .alreadyOpened
        }

        if cell.state == .flagged {
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
        if cell.isMine {
            logger.error("Mine exploded at (\(row), \(column))")
            board.updateCellState(row, column, .opened)
            revealAllMines(board: &board)
            return .mineExploded
        }

        // Открываем ячейку с обновлением счетчиков
        _ = board.openCell(at: row, column: column)
        logger.debug("Cell opened at (\(row), \(column)), adjacent mines: \(cell.adjacentMines), openedCount: \(board.openedCellsCount)")

        // Если ячейка пустая, выполняем flood fill
        if cell.adjacentMines == 0 {
            logger.debug("Empty cell detected, starting flood fill")
            floodFill(row: row, column: column, board: &board)
        }

        return .success
    }

    func floodFill(row: Int, column: Int, board: inout GameBoardModel) {
        let startTime = Date()
        var cellsOpened = 0
        let boardSize = board.size
        var visited = Set<Int>()
        var queue = [(row: Int, column: Int)]()
        var queueIndex = 0

        // Используем эффективное кодирование позиции: row * size + column
        func encodePosition(_ r: Int, _ c: Int) -> Int {
            return r * boardSize + c
        }

        queue.append((row, column))
        visited.insert(encodePosition(row, column))

        while queueIndex < queue.count {
            let (r, c) = queue[queueIndex]
            queueIndex += 1

            // Проверяем всех 8 соседей
            for dr in -1...1 {
                let newRow = r + dr
                if newRow < 0 || newRow >= boardSize { continue }

                for dc in -1...1 {
                    let newColumn = c + dc
                    if newColumn < 0 || newColumn >= boardSize { continue }

                    // Пропускаем центральную ячейку (текущую)
                    if dr == 0 && dc == 0 { continue }

                    let key = encodePosition(newRow, newColumn)
                    guard !visited.contains(key) else { continue }

                    let neighbor = board.cells[newRow][newColumn]

                    // Обрабатываем только закрытые ячейки без мин
                    if neighbor.state == .closed && !neighbor.isMine {
                        _ = board.openCell(at: newRow, column: newColumn)
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

    func revealAllMines(board: inout GameBoardModel) {
        logger.debug("Revealing all mines on \(board.size)×\(board.size) board")
        var revealedCount = 0

        for row in 0..<board.size {
            for column in 0..<board.size {
                if board.cells[row][column].isMine && board.cells[row][column].state != .opened {
                    board.updateCellState(row, column, .opened)
                    revealedCount += 1
                }
            }
        }

        logger.info("Revealed \(revealedCount) mines")
    }
}
