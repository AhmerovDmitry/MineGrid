//
//  String+Validation.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

extension String {
    static let maximumPlayerNameLength = 32

    /// Проверяет, является ли строка непустой после удаления пробелов
    var isNotEmptyAfterTrimming: Bool {
        !normalizedPlayerNameInput.isEmpty
    }
    
    /// Возвращает строку без пробелов или "Anonymous", если пустая
    var sanitizedPlayerName: String {
        let normalized = normalizedPlayerNameInput
        return normalized.isEmpty ? "Anonymous" : normalized
    }

    private var normalizedPlayerNameInput: String {
        let withoutControls = unicodeScalars
            .filter { !CharacterSet.controlCharacters.contains($0) }
            .map(String.init)
            .joined()
        let trimmed = withoutControls.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(Self.maximumPlayerNameLength))
    }
}
