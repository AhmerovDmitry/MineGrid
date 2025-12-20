//
//  GameStorageService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftData

/// Сервис для сохранения и загрузки игр
final class GameStorageService: GameStorageProtocol {
    
    // MARK: - Properties
    
    private let logger: LogService
    
    // MARK: - Initialization
    
    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "GameStorage")) {
        self.logger = logger
    }
    
    // MARK: - GameStorageProtocol
    
    func saveGame(
        gameState: GameState,
        board: GameBoardModel,
        difficulty: Difficulty,
        elapsedTime: Int,
        flaggedCount: Int,
        modelContext: ModelContext
    ) {
        // Не сохраняем завершенные игры
        guard gameState == .playing || gameState == .notStarted else {
            logger.debug("Skipping save for finished game: \(gameState.rawValue)")
            return
        }
        
        logger.info("Saving game: state=\(gameState.rawValue), difficulty=\(difficulty.rawValue), time=\(elapsedTime)s, board=\(board.size)×\(board.size)")
        
        // Удаляем предыдущее сохранение, если есть
        deleteExistingSave(modelContext: modelContext)
        
        // Сериализуем ячейки
        guard let encodedData = serializeCells(board: board) else {
            logger.error("Failed to encode cells data")
            return
        }
        
        logger.debug("Encoded \(board.size * board.size) cells, data size: \(encodedData.count) bytes")
        
        // Создаем новое сохранение
        let savedGame = SavedGame(
            difficulty: difficulty.rawValue,
            boardSize: board.size,
            mineCount: difficulty.mineCount,
            gameState: gameState.rawValue,
            elapsedTime: elapsedTime,
            flaggedCount: flaggedCount,
            isFirstMove: board.isFirstMove,
            cellsData: encodedData,
            savedDate: Date()
        )
        
        modelContext.insert(savedGame)
        
        do {
            try modelContext.save()
            logger.info("Game saved successfully")
        } catch {
            logger.error("Failed to save game", error: error)
        }
    }
    
    func loadSavedGame(modelContext: ModelContext) -> SavedGame? {
        logger.debug("Loading saved game")
        let descriptor = FetchDescriptor<SavedGame>()
        do {
            let games = try modelContext.fetch(descriptor)
            logger.debug("Fetched \(games.count) saved games")
            
            if let first = games.first {
                logger.info("Saved game found: state=\(first.gameState), difficulty=\(first.difficulty), time=\(first.elapsedTime)s")
                return first
            } else {
                logger.debug("No saved games in database")
                return nil
            }
        } catch {
            logger.error("Failed to fetch saved game", error: error)
            return nil
        }
    }
    
    func deleteSavedGame(modelContext: ModelContext) {
        logger.info("Deleting saved game")
        deleteExistingSave(modelContext: modelContext)
        
        do {
            try modelContext.save()
            logger.info("Saved game deleted successfully")
        } catch {
            logger.error("Failed to delete saved game", error: error)
        }
    }
    
    func hasActiveSavedGame(modelContext: ModelContext) -> Bool {
        logger.debug("Checking for active saved game")
        guard let savedGame = loadSavedGame(modelContext: modelContext) else {
            logger.debug("No saved game found")
            return false
        }
        
        let gameState = GameState(rawValue: savedGame.gameState) ?? .notStarted
        let isActive = gameState == .notStarted || gameState == .playing
        logger.debug("Active saved game: \(isActive)")
        return isActive
    }
    
    // MARK: - Private Methods
    
    /// Удаляет существующее сохранение
    private func deleteExistingSave(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<SavedGame>()
        do {
            if let existingSave = try modelContext.fetch(descriptor).first {
                logger.debug("Deleting existing save")
                modelContext.delete(existingSave)
            }
        } catch {
            logger.error("Failed to fetch existing save", error: error)
        }
    }
    
    /// Сериализует ячейки игрового поля
    private func serializeCells(board: GameBoardModel) -> Data? {
        var cellsData: [CellData] = []
        cellsData.reserveCapacity(board.size * board.size)
        
        for row in 0..<board.size {
            for column in 0..<board.size {
                let cell = board.cells[row][column]
                cellsData.append(CellData(
                    row: row,
                    column: column,
                    isMine: cell.isMine,
                    adjacentMines: cell.adjacentMines,
                    state: cell.state.rawValue
                ))
            }
        }
        
        do {
            return try JSONEncoder().encode(cellsData)
        } catch {
            logger.error("Failed to encode cells data", error: error)
            return nil
        }
    }
}

