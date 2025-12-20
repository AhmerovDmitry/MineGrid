//
//  BackgroundGradientModifier.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI

extension View {
    /// Применяет стандартный фоновый градиент
    func backgroundGradient() -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.15, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            self
        }
    }
}

