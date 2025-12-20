//
//  MainMenuView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI
import SwiftData

/// Обертка для GameViewModel для использования в навигации
struct GameViewModelWrapper: Identifiable {
    let id = UUID()
    let viewModel: GameViewModel
}

/// Главное меню приложения с выбором уровня сложности
struct MainMenuView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDifficulty: Difficulty?
    @State private var showLeaderboard = false
    @State private var showGameRules = false
    @State private var continueGameViewModel: GameViewModelWrapper?
    @State private var activeSavedGame: SavedGame?
    
    private let logger: LogService
    
    init(logger: LogService = AppLogger(category: "MainMenuView")) {
        self.logger = logger
        logger.debug("MainMenuView initializing")
    }
    
    // MARK: - Body
    
    var body: some View {
        logger.debug("MainMenuView body rendering")
        
        // Не обращаемся к savedGames напрямую в body, чтобы избежать раннего доступа
        return NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                logoView
                Spacer()
                
                if let saved = activeSavedGame {
                    continueGameButton(saved: saved)
                }
                
                difficultyButtons
                Spacer()
            }
            .backgroundGradient()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showGameRules = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLeaderboard = true
                    }) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    }
                }
            }
            .task {
                // Используем task для асинхронной загрузки после готовности view
                updateActiveSavedGame()
            }
            .onAppear {
                // Обновляем сохраненную игру при каждом появлении view
                // Это нужно, когда пользователь возвращается из GameView
                updateActiveSavedGame()
            }
            .navigationDestination(item: $selectedDifficulty) { difficulty in
                logger.info("Navigating to GameView with difficulty: \(difficulty.rawValue)")
                return GameView(viewModel: DependencyContainer.shared.makeGameViewModel(difficulty: difficulty))
            }
            .fullScreenCover(item: $continueGameViewModel) { wrapper in
                NavigationStack {
                    GameView(viewModel: wrapper.viewModel)
                }
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView(modelContext: modelContext)
            }
            .sheet(isPresented: $showGameRules) {
                GameRulesView()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Обновляет активную сохраненную игру
    private func updateActiveSavedGame() {
        logger.debug("Updating activeSavedGame")
        
        // Безопасная загрузка данных через modelContext
        let descriptor = FetchDescriptor<SavedGame>(
            sortBy: [SortDescriptor(\.savedDate, order: .reverse)]
        )
        do {
            let savedGames = try modelContext.fetch(descriptor)
            let gamesCount = savedGames.count
            logger.debug("Found \(gamesCount) saved games")

            guard gamesCount > 0 else {
                logger.debug("No saved games found")
                activeSavedGame = nil
                return
            }
            
            // Берем самую свежую сохраненную игру (первая в отсортированном списке)
            guard let saved = savedGames.first else {
                logger.warning("Failed to get first saved game")
                activeSavedGame = nil
                return
            }
            
            // Безопасный доступ к gameState
            let gameStateString = saved.gameState
            logger.debug("Saved game found: state=\(gameStateString), difficulty=\(saved.difficulty), time=\(saved.elapsedTime)s")

            let gameState = GameState(rawValue: gameStateString) ?? .notStarted
            let isActive = gameState == .notStarted || gameState == .playing
            
            if isActive {
                logger.info("Active saved game found and set")
                activeSavedGame = saved
            } else {
                logger.debug("Saved game is not active (state: \(gameStateString)")
                activeSavedGame = nil
            }
        } catch {
            logger.error("Error fetching saved games", error: error)
            activeSavedGame = nil
        }
    }
    
    // MARK: - Subviews
    
    private var logoView: some View {
        VStack(spacing: 12) {
            Image(systemName: "grid.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
            
            Text("Сапер")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.bottom, 20)
    }
    
    private func continueGameButton(saved: SavedGame) -> some View {
        Button(action: {
            logger.info("Continue game button tapped, state: \(saved.gameState)")
            if let viewModel = DependencyContainer.shared.makeGameViewModel(from: saved) {
                continueGameViewModel = GameViewModelWrapper(viewModel: viewModel)
            } else {
                logger.error("Failed to load saved game")
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 26))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Продолжить игру")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                    Text("\(saved.difficulty) • \(saved.elapsedTime.formattedTimeWithRussianSuffix)")
                        .font(.system(size: 14, design: .rounded))
                        .opacity(0.8)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle()) // корректная зона тапа
        }
        .frame(height: 70)
        .glassEffect(.clear)
        .padding(.horizontal, 40)
        .padding(.bottom, 10)
    }

    private var difficultyButtons: some View {
        VStack(spacing: 20) {
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                DifficultyButton(difficulty: difficulty) {
                    selectedDifficulty = difficulty
                }
            }
        }
        .padding(.horizontal, 40)
    }

}

/// Кнопка выбора уровня сложности
struct DifficultyButton: View {
    let difficulty: Difficulty
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.rawValue)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("\(difficulty.size)×\(difficulty.size) • \(difficulty.mineCount) мин")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .glassEffect(.clear)
            .contentShape(Rectangle()) // корректная зона тапа
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
}
