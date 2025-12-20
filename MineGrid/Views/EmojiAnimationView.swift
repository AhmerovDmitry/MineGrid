//
//  EmojiAnimationView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import SwiftUI
import UIKit

/// Компонент для анимации эмодзи
struct EmojiAnimationView: View {
    /// Тип анимации
    enum AnimationType {
        case fireworks // Салют для победы
        case bombs     // Дождь бомб для проигрыша
    }
    
    /// Тип текущей анимации
    let type: AnimationType
    
    /// Состояние анимации
    @State private var isAnimating = false
    
    /// Размеры экрана
    @State private var screenSize: CGSize = .zero
    
    /// Эмодзи для анимации
    private var emojis: [String] {
        switch type {
        case .fireworks:
            return ["🎉", "🎊", "✨", "🌟", "💫", "🎆", "🎇", "🎈", "🎀", "🎁"]
        case .bombs:
            return ["💣", "🧨", "🔥", "☠️", "💥", "😵", "🤯", "😱", "😨", "💀"]
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<30, id: \.self) { index in
                    Text(emojis[index % emojis.count])
                        .font(.system(size: CGFloat.random(in: 10...50)))
                        .offset(
                            x: CGFloat.random(in: -geometry.size.width...geometry.size.width),
                            y: isAnimating ? geometry.size.height + 50 : -geometry.size.height - 50
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 2...4))
                                .delay(Double.random(in: 0...2))
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EmojiAnimationView(type: .fireworks)
    }
}