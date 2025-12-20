//
//  LogService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation

/// Протокол для сервиса логирования
protocol LogService {
    /// Логирует сообщение с указанным уровнем
    /// - Parameters:
    ///   - message: Сообщение для логирования
    ///   - level: Уровень логирования
    ///   - file: Имя файла (автоматически подставляется через #file)
    ///   - function: Имя функции (автоматически подставляется через #function)
    ///   - line: Номер строки (автоматически подставляется через #line)
    func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    )
}

