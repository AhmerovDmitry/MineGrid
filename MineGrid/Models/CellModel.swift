//
//  CellModel.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Состояние ячейки игрового поля
enum CellState: String, Codable, Equatable {
    /// Ячейка закрыта
    case closed
    /// Ячейка открыта
    case opened
    /// Ячейка помечена флагом
    case flagged
}

/// Модель ячейки игрового поля
struct CellModel: Identifiable, Equatable {
    /// Уникальный идентификатор на основе координат (стабильный)
    var id: String {
        "\(row)-\(column)"
    }
    /// Номер строки ячейки
    let row: Int
    /// Номер столбца ячейки
    let column: Int
    /// Флаг, указывающий, является ли ячейка миной
    var isMine: Bool
    /// Количество мин в соседних ячейках (8 соседей)
    var adjacentMines: Int
    /// Текущее состояние ячейки
    var state: CellState
    
    /// Инициализатор ячейки
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    ///   - isMine: Является ли ячейка миной (по умолчанию false)
    ///   - adjacentMines: Количество соседних мин (по умолчанию 0)
    ///   - state: Состояние ячейки (по умолчанию closed)
    init(row: Int, column: Int, isMine: Bool = false, adjacentMines: Int = 0, state: CellState = .closed) {
        self.row = row
        self.column = column
        self.isMine = isMine
        self.adjacentMines = adjacentMines
        self.state = state
    }
    
    // MARK: - Equatable
    
    static func == (lhs: CellModel, rhs: CellModel) -> Bool {
        lhs.row == rhs.row &&
        lhs.column == rhs.column &&
        lhs.isMine == rhs.isMine &&
        lhs.adjacentMines == rhs.adjacentMines &&
        lhs.state == rhs.state
    }
}

