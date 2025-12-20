//
//  DependencyContainer.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 19.12.2025.
//

import Foundation
import SwiftUI

/// Контейнер для управления зависимостями в приложении
final class DependencyContainer {
    
    // MARK: - Properties
    
    /// Общий экземпляр контейнера (синглтон)
    static let shared = DependencyContainer()
    
    /// Сервис логирования
    private let logger: LogService
    
    // MARK: - Services
    
    private var mineGeneratorService: MineGeneratorProtocol
    private var gameLogicService: GameLogicProtocol
    private var timerService: TimerServiceProtocol
    private var gameStorageService: GameStorageProtocol
    private var scoreService: ScoreServiceProtocol
    private var hapticFeedbackService: HapticFeedbackProtocol
    private var gameSaveService: GameSaveServiceProtocol
    
    // MARK: - Initialization
    
    /// Приватный инициализатор контейнера зависимостей
    private init() {
        self.logger = AppLogger(category: "DependencyContainer")
        logger.info("Initializing DependencyContainer")
        
        // Инициализация сервисов
        self.mineGeneratorService = MineGeneratorService(logger: AppLogger(category: "MineGenerator"))
        self.gameLogicService = GameLogicService(logger: AppLogger(category: "GameLogic"))
        self.timerService = TimerService()
        self.gameStorageService = GameStorageService(logger: AppLogger(category: "GameStorage"))
        self.scoreService = ScoreService(logger: AppLogger(category: "ScoreService"))
        self.hapticFeedbackService = HapticFeedbackService()
        self.gameSaveService = GameSaveService(logger: AppLogger(category: "GameSaveService"))
        
        logger.info("DependencyContainer initialized successfully")
    }
    
    // MARK: - Service Access
    
    /// Возвращает сервис генерации мин
    func makeMineGenerator() -> MineGeneratorProtocol {
        logger.debug("Providing MineGeneratorService")
        return mineGeneratorService
    }
    
    /// Возвращает сервис игровой логики
    func makeGameLogic() -> GameLogicProtocol {
        logger.debug("Providing GameLogicService")
        return gameLogicService
    }
    
    /// Возвращает сервис таймера
    func makeTimerService() -> TimerServiceProtocol {
        logger.debug("Providing TimerService")
        return timerService
    }
    
    /// Возвращает сервис сохранения игр
    func makeGameStorage() -> GameStorageProtocol {
        logger.debug("Providing GameStorageService")
        return gameStorageService
    }
    
    /// Возвращает сервис результатов
    func makeScoreService() -> ScoreServiceProtocol {
        logger.debug("Providing ScoreService")
        return scoreService
    }

    /// Возвращает сервис тактильной обратной связи
    func makeHapticFeedback() -> HapticFeedbackProtocol {
        logger.debug("Providing HapticFeedbackService")
        return hapticFeedbackService
    }

    /// Возвращает сервис сохранения игр
    func makeGameSaveService() -> GameSaveServiceProtocol {
        logger.debug("Providing GameSaveService")
        return gameSaveService
    }
    
    /// Возвращает сервис логирования
    func makeLogger() -> LogService {
        logger.debug("Providing Logger")
        return logger
    }
    
    // MARK: - ViewModel Factory
    
    /// Создает GameViewModel с заданным уровнем сложности
    /// - Parameter difficulty: Уровень сложности игры
    /// - Returns: Конфигурированный GameViewModel
    func makeGameViewModel(difficulty: Difficulty) -> GameViewModel {
        logger.info("Creating GameViewModel with difficulty: \(difficulty.rawValue)")
        return GameViewModel(
            difficulty: difficulty,
            mineGenerator: makeMineGenerator(),
            gameLogic: makeGameLogic(),
            timerService: makeTimerService(),
            gameStorage: makeGameStorage(),
            scoreService: makeScoreService(),
            hapticFeedback: makeHapticFeedback(),
            gameSaveService: makeGameSaveService(),
            logger: makeLogger()
        )
    }

    /// Создает GameViewModel из сохраненной игры
    /// - Parameter savedGame: Сохраненная игра
    /// - Returns: Конфигурированный GameViewModel или nil, если не удалось загрузить
    func makeGameViewModel(from savedGame: SavedGame) -> GameViewModel? {
        logger.info("Creating GameViewModel from saved game")
        return GameViewModel(
            savedGame: savedGame,
            mineGenerator: makeMineGenerator(),
            gameLogic: makeGameLogic(),
            timerService: makeTimerService(),
            gameStorage: makeGameStorage(),
            scoreService: makeScoreService(),
            hapticFeedback: makeHapticFeedback(),
            gameSaveService: makeGameSaveService(),
            logger: makeLogger()
        )
    }
}