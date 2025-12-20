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
        
        for row in 0..<size {
            for column in 0..<size {
                cells[row][column] = CellModel(row: row, column: column)
            }
        }
        
        logger?.info("GameBoardModel initialized with \(size * size) cells")
    }
    
    /// Проверяет, является ли позиция валидной
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    /// - Returns: true, если позиция валидна
    func isValidPosition(row: Int, column: Int) -> Bool {
        row >= 0 && row < size && column >= 0 && column < size
    }
    
    // MARK: - Equatable
    
    static func == (lhs: GameBoardModel, rhs: GameBoardModel) -> Bool {
        lhs.size == rhs.size &&
        lhs.mineCount == rhs.mineCount &&
        lhs.isFirstMove == rhs.isFirstMove &&
        lhs.cells == rhs.cells
    }
}

