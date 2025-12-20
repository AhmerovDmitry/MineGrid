//
//  SecondaryButton.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI

/// Вторичная кнопка приложения
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .glassEffect(.regular)
        }
    }
}

