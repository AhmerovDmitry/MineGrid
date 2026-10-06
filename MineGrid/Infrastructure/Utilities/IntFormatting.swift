//
//  Int+Formatting.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

extension Int {
    /// Форматирует время в виде строки без ведущих нулей (1, 2, 3...)
    var formattedTime: String {
        "\(self)"
    }

    /// Форматирует время с русским суффиксом (например: "10 сек")
    var formattedTimeWithRussianSuffix: String {
        "\(formattedTime) сек"
    }
}