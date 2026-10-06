//
//  GameSaveService.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import Foundation
import SwiftData

/// Сервис для сохранения и загрузки игр
final class GameSaveService: GameSaveServiceProtocol {

    // MARK: - Properties

    private let logger: LogService

    // MARK: - Initialization

    /// Инициализатор сервиса
    /// - Parameter logger: Сервис логирования
    init(logger: LogService = AppLogger(category: "GameSaveService")) {
        self.logger = logger
    }

    // MARK: - GameSaveServiceProtocol

    func saveGame(
        gameState: GameState,
        board: GameBoardModel,
        difficulty: Difficulty,
        elapsedTime: Int,
        flaggedCount: Int,
        modelContext: ModelContext
    ) {
        logger.info("Saving game state: \(gameState.rawValue)")

        // Не сохраняем завершенные игры
        guard gameState == .playing || gameState == .notStarted else {
            deleteSavedGame(modelContext: modelContext)
            logger.debug("Skipping save for finished game: \(gameState.rawValue)")
            return
        }

        // Сохраняем состояние ячеек
        let cellsData = board.cells.flatMap { row in
            row.map { cell in
                CellData(
                    row: cell.row,
                    column: cell.column,
                    isMine: cell.isMine,
                    adjacentMines: cell.adjacentMines,
                    state: cell.state.rawValue
                )
            }
        }

        var encodedCellsData = Data()
        do {
            let encoder = JSONEncoder()
            encodedCellsData = try encoder.encode(cellsData)
            logger.debug("Cells data encoded successfully (size: \(encodedCellsData.count) bytes)")
        } catch {
            logger.error("Failed to encode cells data", error: error)
            return
        }

        do {
            let descriptor = FetchDescriptor<SavedGame>()
            let saves = try modelContext.fetch(descriptor)
            let savedGame: SavedGame

            if let existing = saves.first {
                savedGame = existing
                for duplicate in saves.dropFirst() {
                    modelContext.delete(duplicate)
                }
            } else {
                savedGame = SavedGame(
                    difficulty: difficulty.rawValue,
                    boardSize: board.size,
                    mineCount: board.mineCount,
                    gameState: gameState.rawValue,
                    elapsedTime: elapsedTime,
                    flaggedCount: flaggedCount,
                    isFirstMove: board.isFirstMove,
                    cellsData: encodedCellsData,
                    savedDate: Date()
                )
                modelContext.insert(savedGame)
            }

            savedGame.difficulty = difficulty.rawValue
            savedGame.boardSize = board.size
            savedGame.mineCount = board.mineCount
            savedGame.gameState = gameState.rawValue
            savedGame.elapsedTime = max(0, elapsedTime)
            savedGame.flaggedCount = board.flaggedCellsCount
            savedGame.isFirstMove = board.isFirstMove
            savedGame.cellsData = encodedCellsData
            savedGame.savedDate = Date()

            try modelContext.save()
            logger.info("Game saved successfully")
        } catch {
            modelContext.rollback()
            logger.error("Failed to persist game", error: error)
        }
    }

    func deleteSavedGame(modelContext: ModelContext) {
        logger.info("Deleting saved game")

        let descriptor = FetchDescriptor<SavedGame>()
        do {
            let savedGames = try modelContext.fetch(descriptor)
            logger.debug("Fetched \(savedGames.count) saved games for deletion")
            for game in savedGames {
                modelContext.delete(game)
                logger.debug("Deleted saved game: \(game.difficulty), state: \(game.gameState)")
            }
            // Немедленно сохраняем изменения
            try modelContext.save()
            logger.info("Deleted \(savedGames.count) saved games and saved context")
        } catch {
            logger.error("Failed to delete saved games", error: error)
        }
    }

    func loadCells(from data: Data) -> [CellData]? {
        logger.debug("Loading cells from data (size: \(data.count) bytes)")

        do {
            let cellsData = try JSONDecoder().decode([CellData].self, from: data)
            logger.debug("Decoded \(cellsData.count) cells")
            return cellsData
        } catch {
            logger.error("Failed to decode cells data", error: error)
            return nil
        }
    }
}
