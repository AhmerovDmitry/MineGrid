//
//  Int+Formatting.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

extension Int {
    /// Форматирует время в виде строки (000, 001, 002...)
    var formattedTime: String {
        String(format: "%03d", self)
    }
    
    /// Форматирует время с русским суффиксом (например: "010 сек")
    var formattedTimeWithRussianSuffix: String {
        "\(formattedTime) сек"
    }
}

