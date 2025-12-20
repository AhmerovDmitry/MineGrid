//
//  LogLevel.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Уровни логирования
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// Строковое представление уровня
    var stringValue: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        }
    }
    
    /// Минимальный уровень для Debug build
    static let debugBuildMinimum: LogLevel = .debug
    
    /// Минимальный уровень для Release build
    static let releaseBuildMinimum: LogLevel = .warning
}

