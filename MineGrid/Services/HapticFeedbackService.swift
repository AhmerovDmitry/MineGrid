//
//  HapticFeedbackService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 19.12.2025.
//

import Foundation
import UIKit

/// Сервис для работы с тактильной обратной связью
final class HapticFeedbackService: HapticFeedbackProtocol {

    private let impactFeedbackGenerator: UIImpactFeedbackGenerator

    init() {
        self.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        prepareGenerators()
    }

    private func prepareGenerators() {
        impactFeedbackGenerator.prepare()
    }

    /// Выполняет тактильную обратную связь
    /// - Parameter style: Стиль тактильной обратной связи
    func triggerHapticFeedback(style: HapticFeedbackStyle) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            
        case .medium:
            impactFeedbackGenerator.impactOccurred()
            prepareGenerators()
        }
    }
}