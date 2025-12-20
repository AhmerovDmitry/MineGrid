//
//  MineGeneratorProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Протокол для генерации мин на игровом поле
protocol MineGeneratorProtocol {
    /// Размещает мины на поле случайным образом
    /// - Parameters:
    ///   - board: Игровое поле для размещения мин
    ///   - mineCount: Количество мин для размещения
    ///   - excludingRow: Строка, которую нужно исключить (первый клик)
    ///   - excludingColumn: Столбец, который нужно исключить (первый клик)
    /// - Note: Мины не размещаются в указанной ячейке и её 8 соседях для безопасности первого хода
    func placeMines(
        on board: inout GameBoardModel,
        mineCount: Int,
        excludingRow: Int,
        excludingColumn: Int
    )
    
    /// Вычисляет количество мин в соседних ячейках для каждой ячейки поля
    /// - Parameter board: Игровое поле для вычисления
    func calculateAdjacentMines(for board: inout GameBoardModel)
}

