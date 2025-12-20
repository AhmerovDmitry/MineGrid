//
//  GameViewModel.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

/// ViewModel для управления логикой игры
@Observable
final class GameViewModel {

    // MARK: - Combine Properties

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    
    /// Игровое поле
    var board: GameBoardModel
    
    /// Уровень сложности
    let difficulty: Difficulty
    
    /// Текущее состояние игры
    var gameState: GameState = .notStarted
    
    /// Прошедшее время в секундах
    var elapsedTime: Int = 0
    
    /// Количество установленных флагов
    var flaggedCount: Int = 0
    
    // MARK: - Services

    private let mineGenerator: MineGeneratorProtocol
    private let gameLogic: GameLogicProtocol
    private let gameRules: GameRulesService
    private let timerService: TimerServiceProtocol
    private let gameStorage: GameStorageProtocol
    private let scoreService: ScoreServiceProtocol
    private let hapticFeedback: HapticFeedbackProtocol
    private let gameSaveService: GameSaveServiceProtocol
    private let logger: LogService
    
    // MARK: - Computed Properties
    
    /// Количество оставшихся мин
    var remainingMines: Int {
        difficulty.mineCount - flaggedCount
    }

    /// Отформатированное время в виде строки (000, 001, 002...)
    var formattedTime: String {
        elapsedTime.formattedTime
    }

    /// Вычисляет размер ячейки в зависимости от размера доски
    func calculateCellSize() -> CGFloat {
        let baseCellSize: CGFloat = 30
        let minCellSize: CGFloat = 20
        
        switch board.size {
        case 8:
            return min(25, baseCellSize)
        case 12:
            return min(20, baseCellSize)
        case 16:
            return min(18, baseCellSize)
        default:
            return max(minCellSize, min(baseCellSize, 30))
        }
    }
    
    // MARK: - Initialization
    
    /// Инициализатор ViewModel
    /// - Parameters:
    ///   - difficulty: Уровень сложности игры
    ///   - mineGenerator: Сервис генерации мин
    ///   - gameLogic: Сервис игровой логики
    ///   - timerService: Сервис таймера
    ///   - gameStorage: Сервис сохранения игр
    ///   - scoreService: Сервис результатов
    ///   - hapticFeedback: Сервис тактильной обратной связи
    ///   - logger: Сервис логирования
    init(
        difficulty: Difficulty,
        mineGenerator: MineGeneratorProtocol = MineGeneratorService(),
        gameLogic: GameLogicProtocol = GameLogicService(),
        gameRules: GameRulesService = GameRulesService(),
        timerService: TimerServiceProtocol = TimerService(),
        gameStorage: GameStorageProtocol = GameStorageService(),
        scoreService: ScoreServiceProtocol = ScoreService(),
        hapticFeedback: HapticFeedbackProtocol = HapticFeedbackService(),
        gameSaveService: GameSaveServiceProtocol = GameSaveService(),
        logger: LogService = AppLogger(category: "GameViewModel")
    ) {
        self.difficulty = difficulty
        self.mineGenerator = mineGenerator
        self.gameLogic = gameLogic
        self.gameRules = gameRules
        self.timerService = timerService
        self.gameStorage = gameStorage
        self.scoreService = scoreService
        self.hapticFeedback = hapticFeedback
        self.gameSaveService = gameSaveService
        self.logger = logger
        
        logger.info("Initializing GameViewModel with difficulty: \(difficulty.rawValue)")
        logger.debug("Board size: \(difficulty.size)×\(difficulty.size), mines: \(difficulty.mineCount)")
        
        self.board = GameBoardModel(size: difficulty.size, mineCount: difficulty.mineCount, logger: logger)
        logger.info("GameViewModel initialized successfully")
    }
    
    /// Инициализатор ViewModel из сохраненной игры
    /// - Parameters:
    ///   - savedGame: Сохраненная игра
    ///   - mineGenerator: Сервис генерации мин
    ///   - gameLogic: Сервис игровой логики
    ///   - timerService: Сервис таймера
    ///   - gameStorage: Сервис сохранения игр
    ///   - scoreService: Сервис результатов
    ///   - hapticFeedback: Сервис тактильной обратной связи
    ///   - logger: Сервис логирования
    init?(
        savedGame: SavedGame,
        mineGenerator: MineGeneratorProtocol = MineGeneratorService(),
        gameLogic: GameLogicProtocol = GameLogicService(),
        gameRules: GameRulesService = GameRulesService(),
        timerService: TimerServiceProtocol = TimerService(),
        gameStorage: GameStorageProtocol = GameStorageService(),
        scoreService: ScoreServiceProtocol = ScoreService(),
        hapticFeedback: HapticFeedbackProtocol = HapticFeedbackService(),
        gameSaveService: GameSaveServiceProtocol = GameSaveService(),
        logger: LogService = AppLogger(category: "GameViewModel")
    ) {
        logger.info("Initializing GameViewModel from saved game")
        logger.debug("Saved game: difficulty=\(savedGame.difficulty), boardSize=\(savedGame.boardSize), state=\(savedGame.gameState)")

        guard let difficulty = Difficulty(rawValue: savedGame.difficulty) else {
            logger.error("Failed to load difficulty: \(savedGame.difficulty)")
            return nil
        }

        self.difficulty = difficulty
        self.mineGenerator = mineGenerator
        self.gameLogic = gameLogic
        self.gameRules = gameRules
        self.timerService = timerService
        self.gameStorage = gameStorage
        self.scoreService = scoreService
        self.hapticFeedback = hapticFeedback
        self.logger = logger
        self.gameSaveService = gameSaveService

        self.board = GameBoardModel(size: savedGame.boardSize, mineCount: savedGame.mineCount, logger: logger)
        self.gameState = GameState(rawValue: savedGame.gameState) ?? .notStarted
        self.elapsedTime = savedGame.elapsedTime
        self.flaggedCount = savedGame.flaggedCount
        self.board.isFirstMove = savedGame.isFirstMove

        logger.debug("Loaded game state: \(gameState.rawValue), time: \(elapsedTime)s, flags: \(flaggedCount), isFirstMove: \(board.isFirstMove)")

        // Загружаем состояние ячеек
        logger.debug("Loading cells from saved data (size: \(savedGame.cellsData.count) bytes)")
        guard loadCells(from: savedGame.cellsData) else {
            logger.error("Failed to load cells from saved data")
            return nil
        }
        logger.info("Cells loaded successfully")

        // Если игра была в процессе, запускаем таймер
        if gameState == .playing {
            logger.info("Game was playing, starting timer")
            startTimer()
        }

        logger.info("GameViewModel initialized from saved game")
    }
    
    // MARK: - Game Control

    /// Запускает таймер игры
    func startTimer() {
        logger.debug("Starting game timer")
        timerService.start { [weak self] in
            guard let self = self, self.gameState == .playing else { return }
            self.elapsedTime += 1
        }
    }

    /// Останавливает таймер игры
    func stopTimer() {
        logger.debug("Stopping game timer")
        timerService.stop()
    }

    /// Сбрасывает игру в начальное состояние
    /// - Parameter modelContext: Контекст SwiftData для удаления сохраненной игры
    func resetGame(modelContext: ModelContext? = nil) {
        logger.info("Resetting game")
        stopTimer()
        board = GameBoardModel(size: difficulty.size, mineCount: difficulty.mineCount, logger: logger)
        gameState = .notStarted
        elapsedTime = 0
        flaggedCount = 0

        // Удаляем сохраненную игру, если предоставлен контекст
        if let modelContext = modelContext {
            gameSaveService.deleteSavedGame(modelContext: modelContext)

            // Убеждаемся, что удаление сохранено в базе данных
            do {
                try modelContext.save()
                logger.info("Saved game deletion successfully persisted after reset")
            } catch {
                logger.error("Failed to persist saved game deletion after reset", error: error)
            }
        }

        logger.info("Game reset completed")
    }

    // MARK: - Combine Integration

    /// Настраивает подписки на изменения состояния
    func setupCombineBindings() {
        // Пример использования Combine для реактивного управления состоянием
        // Можно расширить для других свойств
        // Note: Для использования Combine с @Observable свойствами нужно использовать
        // дополнительные обертки или перейти на ObservableObject
        logger.debug("Combine bindings setup - ready for reactive state management")
    }
    
    // MARK: - Game Actions
    
    /// Открывает ячейку по указанным координатам
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    func openCell(row: Int, column: Int) {
        guard board.isValidPosition(row: row, column: column) else {
            logger.warning("Invalid position: (\(row), \(column))")
            return
        }
        
        let cell = board.cells[row][column]
        
        // Используем сервис правил для проверки возможности открытия ячейки
        guard gameRules.canOpenCell(cell: cell, gameState: gameState) else {
            logger.debug("Cannot open cell: game is not active or cell is not openable")
            return
        }
         
        logger.debug("Opening cell at (\(row), \(column))")
         
        let result = gameLogic.openCell(
            row: row,
            column: column,
            board: &board,
            mineGenerator: mineGenerator
        )
         
        switch result {
        case .success:
            if gameState == .notStarted {
                logger.info("First move made, game started")
                gameState = .playing
                startTimer()
            }
            checkWinCondition()
             
        case .mineExploded:
            logger.error("Mine exploded at (\(row), \(column))")
            gameState = .lost
            stopTimer()
             
        case .alreadyOpened:
            logger.debug("Cell already opened at (\(row), \(column))")
             
        case .flagged:
            logger.debug("Cell is flagged at (\(row), \(column))")
             
        case .invalidPosition:
            logger.warning("Invalid position: (\(row), \(column))")
        }
    }
    
    /// Переключает состояние флага на ячейке
    /// - Parameters:
    ///   - row: Номер строки
    ///   - column: Номер столбца
    func toggleFlag(row: Int, column: Int) {
        guard board.isValidPosition(row: row, column: column) else {
            logger.warning("Invalid position for flag toggle: (\(row), \(column))")
            return
        }
        
        let cell = board.cells[row][column]
        
        // Используем сервис правил для проверки возможности установки флага
        if gameRules.canPlaceFlag(cell: cell, flaggedCount: flaggedCount, maxFlags: difficulty.mineCount) {
            board.cells[row][column].state = .flagged
            flaggedCount += 1
            logger.debug("Flag placed at (\(row), \(column)), total flags: \(flaggedCount)")
            hapticFeedback.triggerHapticFeedback(style: .medium)
        } else if cell.state == .flagged {
            board.cells[row][column].state = .closed
            flaggedCount -= 1
            logger.debug("Flag removed from (\(row), \(column)), total flags: \(flaggedCount)")
            hapticFeedback.triggerHapticFeedback(style: .light)
        } else if cell.state == .opened {
            logger.debug("Cannot toggle flag: cell is already opened")
        }
         
        checkWinCondition()
    }
    
    // MARK: - Win Condition
    
    /// Проверяет условие победы
    private func checkWinCondition() {
        if gameRules.checkWinCondition(board: board, mineCount: difficulty.mineCount) {
            logger.info("Win condition met! Game won in \(elapsedTime)s")
            gameState = .won
            stopTimer()
        }
    }

    /// Устанавливает состояние победы для отладки
    func setDebugWinState() {
        logger.info("Setting debug win state")
        gameState = .won
        stopTimer()
    }

    /// Устанавливает состояние проигрыша для отладки
    func setDebugLoseState() {
        logger.info("Setting debug lose state")
        gameState = .lost
        stopTimer()
    }
    
    // MARK: - Save/Load

    /// Сохраняет текущее состояние игры
    /// - Parameter modelContext: Контекст SwiftData
    func saveGame(modelContext: ModelContext) {
        logger.info("Saving game state")
        gameSaveService.saveGame(
            gameState: gameState,
            board: board,
            difficulty: difficulty,
            elapsedTime: elapsedTime,
            flaggedCount: flaggedCount,
            modelContext: modelContext
        )
    }

    /// Удаляет сохраненную игру
    /// - Parameter modelContext: Контекст SwiftData
    func deleteSavedGame(modelContext: ModelContext) {
        logger.info("Deleting saved game")
        gameSaveService.deleteSavedGame(modelContext: modelContext)
    }

    /// Сохраняет результат игры
    /// - Parameters:
    ///   - playerName: Имя игрока
    ///   - modelContext: Контекст SwiftData
    func saveResult(playerName: String, modelContext: ModelContext) throws {
        logger.info("Saving game result for player: \(playerName)")
        try scoreService.saveResult(
            playerName: playerName,
            time: elapsedTime,
            difficulty: difficulty,
            boardSize: difficulty.size,
            mineCount: difficulty.mineCount,
            modelContext: modelContext
        )
    }

    // MARK: - Private Methods

    /// Загружает состояние ячеек из данных
    private func loadCells(from data: Data) -> Bool {
        logger.debug("Loading cells from data (size: \(data.count) bytes, board: \(board.size)×\(board.size))")

        guard let cellsData = gameSaveService.loadCells(from: data) else {
            logger.error("Failed to decode cells data")
            return false
        }

        logger.debug("Decoded \(cellsData.count) cells")

        var loadedCount = 0
        var skippedCount = 0

        for cellData in cellsData {
            guard cellData.row < board.size && cellData.column < board.size else {
                logger.warning("Cell out of bounds: row=\(cellData.row), column=\(cellData.column), boardSize=\(board.size)")
                skippedCount += 1
                continue
            }

            board.cells[cellData.row][cellData.column] = CellModel(
                row: cellData.row,
                column: cellData.column,
                isMine: cellData.isMine,
                adjacentMines: cellData.adjacentMines,
                state: CellState(rawValue: cellData.state) ?? .closed
            )
            loadedCount += 1
        }

        logger.info("Loaded \(loadedCount) cells, skipped \(skippedCount)")
        return true
    }
}