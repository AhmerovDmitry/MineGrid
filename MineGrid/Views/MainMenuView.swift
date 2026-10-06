//
//  MainMenuView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI
import SwiftData
import Combine

/// Обертка для GameViewModel для использования в навигации
struct GameViewModelWrapper: Identifiable, Equatable {
    let id = UUID()
    let viewModel: GameViewModel

    static func == (lhs: GameViewModelWrapper, rhs: GameViewModelWrapper) -> Bool {
        lhs.id == rhs.id
    }
}

/// Главное меню приложения с выбором уровня сложности
struct MainMenuView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedDifficulty: Difficulty?
    @State private var showLeaderboard = false
    @State private var showGameRules = false
    @State private var continueGameViewModel: GameViewModelWrapper?
    @State private var gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()
    @State private var savedGames: [SavedGame] = []

    private let logger: LogService

    init(logger: LogService = AppLogger(category: "MainMenuView")) {
        self.logger = logger
        logger.debug("MainMenuView initializing")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                logoView
                Spacer()

                // Если есть сохраненная игра и она не завершена, показываем кнопку продолжения
                if let savedGame = savedGames.first,
                   let gameState = GameState(rawValue: savedGame.gameState),
                   gameState == .playing || gameState == .notStarted {
                    continueGameButton(saved: savedGame)
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
            .onReceive(gameTimer) { _ in
                // Обновляем время для перерисовки
                currentTime = Date()
            }
            .onAppear {
                loadAndCleanupSavedGames()
            }
            .onChange(of: continueGameViewModel) { oldValue, newValue in
                // Когда fullScreenCover закрывается, continueGameViewModel становится nil
                if newValue == nil {
                    logger.debug("Game view dismissed, reloading saved games")
                    loadAndCleanupSavedGames()
                }
            }
            .navigationDestination(item: $selectedDifficulty) { difficulty in
                GameView(viewModel: DependencyContainer.shared.makeGameViewModel(difficulty: difficulty))
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

                    Text("\(saved.difficulty) • \(formatElapsedTime(saved.elapsedTime))")
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

    // MARK: - Helper Methods

    private func formatElapsedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }

    /// Загружает сохраненные игры и очищает завершенные
    private func loadAndCleanupSavedGames() {
        do {
            // Загружаем все сохранения, игнорируя кэш контекста для получения актуальных данных
            var descriptor = FetchDescriptor<SavedGame>(
                sortBy: [SortDescriptor(\.savedDate, order: .reverse)]
            )
            descriptor.includePendingChanges = false
            let allGames = try modelContext.fetch(descriptor)

            // Удаляем завершенные игры
            let finishedGames = allGames.filter { game in
                if let gameState = GameState(rawValue: game.gameState) {
                    return gameState == .won || gameState == .lost
                }
                return false
            }

            for game in finishedGames {
                modelContext.delete(game)
            }

            if !finishedGames.isEmpty {
                try modelContext.save()
                logger.info("Cleaned up \(finishedGames.count) finished games")
                // После удаления перезагружаем список
                let reloadedGames = try modelContext.fetch(descriptor)
                self.savedGames = reloadedGames
            } else {
                self.savedGames = allGames
            }

            logger.debug("Loaded \(savedGames.count) saved games")
        } catch {
            logger.error("Failed to load/cleanup saved games", error: error)
            self.savedGames = []
        }
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
