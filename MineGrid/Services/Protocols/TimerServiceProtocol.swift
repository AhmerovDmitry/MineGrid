//
//  TimerServiceProtocol.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Протокол для управления таймером игры
protocol TimerServiceProtocol {
    /// Запускает таймер
    /// - Parameter onTick: Замыкание, вызываемое каждую секунду
    func start(onTick: @escaping () -> Void)
    
    /// Останавливает таймер
    func stop()
    
    /// Проверяет, запущен ли таймер
    var isRunning: Bool { get }
}

