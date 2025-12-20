//
//  HapticFeedbackProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 19.12.2025.
//

import Foundation

/// Протокол для работы с тактильной обратной связью
protocol HapticFeedbackProtocol {
    /// Выполняет тактильную обратную связь
    /// - Parameter style: Стиль тактильной обратной связи
    func triggerHapticFeedback(style: HapticFeedbackStyle)
}

/// Стили тактильной обратной связи
enum HapticFeedbackStyle {
    case light
    case medium
}