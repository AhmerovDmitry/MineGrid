//
//  ScoreService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftData

/// Сервис для работы с результатами игр
final class ScoreService: ScoreServiceProtocol {
    
    // MARK: - Properties
    
    private let logger: LogService
    
    // MARK: - Initialization
    
    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "Score")) {
        self.logger = logger
    }
    
    // MARK: - ScoreServiceProtocol
    
    func saveResult(
        playerName: String,
        time: Int,
        difficulty: Difficulty,
        boardSize: Int,
        mineCount: Int,
        modelContext: ModelContext
    ) throws {
        logger.info("Saving result: player=\(playerName), time=\(time)s, difficulty=\(difficulty.rawValue)")
        
        let trimmedName = playerName.trimmingCharacters(in: .whitespaces)
        let finalName = trimmedName.isEmpty ? "Anonymous" : trimmedName
        
        let result = GameResult(
            playerName: finalName,
            date: Date(),
            time: time,
            difficulty: difficulty.rawValue,
            boardSize: boardSize,
            mineCount: mineCount
        )
        
        modelContext.insert(result)
        
        do {
            try modelContext.save()
            logger.info("Result saved successfully")
        } catch {
            logger.error("Failed to save result", error: error)
            throw error
        }
    }
}

