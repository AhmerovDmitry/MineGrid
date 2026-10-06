//
//  GameBoardModel.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Модель игрового поля
struct GameBoardModel: Equatable {
    /// Двумерный массив ячеек игрового поля
    var cells: [[CellModel]]
    /// Размер поля (количество клеток по одной стороне)
    let size: Int
    /// Общее количество мин на поле
    let mineCount: Int
    /// Флаг, указывающий, был ли сделан первый ход
    var isFirstMove: Bool = true

    // MARK: - Performance Counters (для быстрой проверки победы)

    /// Количество открытых ячеек (инкрементируется при открытии)
    private(set) var openedCellsCount: Int = 0
    /// Количество закрытых ячеек (декрементируется при открытии)
    private(set) var closedCellsCount: Int = 0
    /// Количество ячеек, помеченных флагом
    private(set) var flaggedCellsCount: Int = 0
    /// Количество правильно помеченных мин (флаг на мине)
    private(set) var correctlyFlaggedMinesCount: Int = 0

    /// Инициализатор игрового поля
    /// - Parameters:
    ///   - size: Размер поля
    ///   - mineCount: Количество мин
    ///   - logger: Сервис логирования (опционально, для внутреннего использования)
    init(size: Int, mineCount: Int, logger: LogService? = nil) {
        self.size = size
        self.mineCount = mineCount

        logger?.debug("Creating GameBoardModel: \(size)×\(size), mines: \(mineCount)")

        // Оптимизация: предварительное выделение памяти для больших полей
        self.cells = Array(repeating: Array(repeating: CellModel(row: 0, column: 0), count: size), count: size)

        // Инициализируем ячейки с правильными индексами
        // Для больших полей используем более эффективный подход
        if size > 30 {
            // Для больших полей инициализируем в фоновой очереди не требуется,
            // так как это синхронная операция и она достаточно быстрая
            logger?.debug("Initializing large board (\(size)×\(size))")
        }

        let totalCells = size * size
        for row in 0..<size {
            for column in 0..<size {
                cells[row][column] = CellModel(row: row, column: column)
            }
        }

        // Инициализируем счетчики
        self.openedCellsCount = 0
        self.closedCellsCount = totalCells
        self.flaggedCellsCount = 0
        self.correctlyFlaggedMinesCount = 0

        logger?.info("GameBoardModel initialized with \(totalCells) cells")
    }

    /// Проверяет, является ли позиция валидной
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    /// - Returns: true, если позиция валидна
    func isValidPosition(row: Int, column: Int) -> Bool {
        row >= 0 && row < size && column >= 0 && column < size
    }

    // MARK: - Cell State Management

    /// Обновляет состояние ячейки с автоматическим обновлением счетчиков
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    ///   - newState: Новое состояние ячейки
    mutating func updateCellState(_ row: Int, _ column: Int, _ newState: CellState) {
        guard isValidPosition(row: row, column: column) else { return }

        var cell = cells[row][column]
        let oldState = cell.state
        guard oldState != newState else { return }

        // Обновляем счетчики для старого состояния
        switch oldState {
        case .closed: closedCellsCount -= 1
        case .opened: openedCellsCount -= 1
        case .flagged:
            flaggedCellsCount -= 1
            if cell.isMine { correctlyFlaggedMinesCount -= 1 }
        }

        // Обновляем счетчики для нового состояния
        switch newState {
        case .closed: closedCellsCount += 1
        case .opened: openedCellsCount += 1
        case .flagged:
            flaggedCellsCount += 1
            if cell.isMine { correctlyFlaggedMinesCount += 1 }
        }

        cell.state = newState
        cells[row][column] = cell
    }

    /// Открывает ячейку (только если она закрыта)
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    /// - Returns: true, если ячейка была успешно открыта
    mutating func openCell(at row: Int, column: Int) -> Bool {
        guard isValidPosition(row: row, column: column) else { return false }
        let cell = cells[row][column]
        guard cell.state == .closed else { return false }

        updateCellState(row, column, .opened)
        return true
    }

    /// Переключает состояние флага на ячейке
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    mutating func toggleFlag(at row: Int, column: Int) {
        guard isValidPosition(row: row, column: column) else { return }
        let cell = cells[row][column]
        guard cell.state != .opened else { return }

        let newState: CellState = (cell.state == .closed) ? .flagged : .closed
        updateCellState(row, column, newState)
    }

    /// Открывает все мины на поле (при проигрыше)
    mutating func revealAllMines() {
        for row in 0..<size {
            for column in 0..<size {
                if cells[row][column].isMine {
                    updateCellState(row, column, .opened)
                }
            }
        }
    }

    // MARK: - Win Condition Optimization

    /// Проверяет условие победы за O(1) используя счетчики
    /// - Returns: true, если игра выиграна
    func isWon() -> Bool {
        let totalNonMineCells = size * size - mineCount

        // Условие 1: все не-мины открыты
        let allNonMinesOpened = openedCellsCount == totalNonMineCells

        // Условие 2: все мины помечены флагами и нет закрытых ячеек
        let allMinesFlaggedAndNoClosedCells =
            correctlyFlaggedMinesCount == mineCount &&
            closedCellsCount == 0

        return allNonMinesOpened || allMinesFlaggedAndNoClosedCells
    }

    /// Пересчитывает все счетчики на основе текущего состояния ячеек
    /// Используется после десериализации для восстановления счетчиков
    mutating func recalculateCounters() {
        var opened = 0
        var closed = 0
        var flagged = 0
        var correctlyFlaggedMines = 0

        for row in 0..<size {
            for column in 0..<size {
                let cell = cells[row][column]
                switch cell.state {
                case .opened: opened += 1
                case .closed: closed += 1
                case .flagged:
                    flagged += 1
                    if cell.isMine { correctlyFlaggedMines += 1 }
                }
            }
        }

        openedCellsCount = opened
        closedCellsCount = closed
        flaggedCellsCount = flagged
        correctlyFlaggedMinesCount = correctlyFlaggedMines
    }

    // MARK: - Equatable

    static func == (lhs: GameBoardModel, rhs: GameBoardModel) -> Bool {
        lhs.size == rhs.size &&
        lhs.mineCount == rhs.mineCount &&
        lhs.isFirstMove == rhs.isFirstMove &&
        lhs.cells == rhs.cells
    }
}