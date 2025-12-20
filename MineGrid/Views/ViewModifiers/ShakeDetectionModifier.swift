//
//  ShakeDetectionModifier.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import SwiftUI
import Combine

extension UIWindow {

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        guard motion == .motionShake else { return }

        NotificationCenter.default.post(
            name: .deviceDidShake,
            object: nil
        )
    }
}

extension Notification.Name {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}

/// Модификатор для обнаружения встряхивания устройства
struct ShakeDetectionModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                action()
            }
    }
}

/// Расширение для View для удобного использования модификатора
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetectionModifier(action: action))
    }
}

final class ShakeService: ObservableObject {

    @Published var isDebugViewPresented = false

    func handleShake() {
        #if DEBUG
        guard !isDebugViewPresented else { return }
        isDebugViewPresented = true
        #endif
    }
}
