//
//  String+Validation.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

extension String {
    /// Проверяет, является ли строка непустой после удаления пробелов
    var isNotEmptyAfterTrimming: Bool {
        !trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// Возвращает строку без пробелов или "Anonymous", если пустая
    var sanitizedPlayerName: String {
        let trimmed = trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Anonymous" : trimmed
    }
}