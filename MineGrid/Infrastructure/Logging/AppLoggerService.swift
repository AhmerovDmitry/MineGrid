//
//  AppLogger.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import OSLog

/// Реализация сервиса логирования
final class AppLogger: LogService {
    
    // MARK: - Properties
    
    /// Флаг включения/выключения логирования
    var isLoggingEnabled: Bool = true
    
    /// Минимальный уровень логирования
    private let minimumLevel: LogLevel
    
    /// Подсистема для OSLog
    private let subsystem: String
    
    /// Категория логов
    private let category: String
    
    /// OSLog logger
    private let osLogger: Logger
    
    // MARK: - Initialization
    
    /// Инициализатор логгера
    /// - Parameters:
    ///   - subsystem: Подсистема для OSLog (по умолчанию bundle identifier)
    ///   - category: Категория логов
    ///   - minimumLevel: Минимальный уровень логирования (по умолчанию зависит от build configuration)
    init(
        subsystem: String? = nil,
        category: String = "App",
        minimumLevel: LogLevel? = nil
    ) {
        self.subsystem = subsystem ?? (Bundle.main.bundleIdentifier ?? "com.minegrid")
        self.category = category
        self.minimumLevel = minimumLevel ?? Self.defaultMinimumLevel
        self.osLogger = Logger(subsystem: self.subsystem, category: category)
    }
    
    // MARK: - LogService
    
    func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        guard isLoggingEnabled else { return }
        guard level >= minimumLevel else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = Self.formattedTimestamp()
        let logMessage = "[\(level.stringValue)] \(timestamp) \(fileName):\(line) \(function) → \(message)"
        
        switch level {
        case .debug:
            osLogger.debug("\(logMessage)")
        case .info:
            osLogger.info("\(logMessage)")
        case .warning:
            osLogger.warning("\(logMessage)")
        case .error:
            osLogger.error("\(logMessage)")
        }
        
        #if DEBUG
        print(logMessage)
        #endif
    }
    
    // MARK: - Private Methods
    
    /// Определяет минимальный уровень логирования в зависимости от build configuration
    private static var defaultMinimumLevel: LogLevel {
        #if DEBUG
        return LogLevel.debugBuildMinimum
        #else
        return LogLevel.releaseBuildMinimum
        #endif
    }
    
    /// Форматирует временную метку
    private static func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - Convenience Extensions

extension LogService {
    /// Удобный метод для логирования с автоматическим определением файла, функции и строки
    func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, file: file, function: function, line: line)
    }
    
    /// Логирует debug сообщение
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Логирует info сообщение
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Логирует warning сообщение
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// Логирует error сообщение
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    /// Логирует error с объектом Error
    func error(_ message: String, error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = "\(message) - \(error.localizedDescription)"
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
}

