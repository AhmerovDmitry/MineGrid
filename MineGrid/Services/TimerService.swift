//
//  TimerService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Сервис для управления таймером игры
final class TimerService: TimerServiceProtocol {
    
    // MARK: - Properties
    
    private var timer: Timer?
    private(set) var isRunning: Bool = false
    private let logger: LogService
    
    // MARK: - Initialization
    
    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "Timer")) {
        self.logger = logger
    }
    
    // MARK: - TimerServiceProtocol
    
    func start(onTick: @escaping () -> Void) {
        guard !isRunning else {
            logger.warning("Timer already running")
            return
        }
        
        logger.info("Starting timer")
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isRunning else { return }
            onTick()
        }
    }
    
    func stop() {
        guard isRunning else {
            logger.debug("Timer already stopped")
            return
        }
        
        logger.info("Stopping timer")
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}

