//
//  GameView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI
import SwiftData
import CoreMotion

/// Основной экран игры с игровым полем и элементами управления
struct GameView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showNameInput = false
    @State private var playerName = ""

    @StateObject private var shakeService = ShakeService()

    private let logger: LogService
    
    init(viewModel: GameViewModel, logger: LogService = AppLogger(category: "GameView")) {
        self.viewModel = viewModel
        self.logger = logger
        logger.debug("GameView initializing, state: \(viewModel.gameState.rawValue), board: \(viewModel.board.size)×\(viewModel.board.size)")
    }
    
    var body: some View {
        #if DEBUG
        // Логирование рендера только в DEBUG для производительности
        logger.debug("GameView body rendering")
        #endif
         
        return ZStack {
            VStack(spacing: 0) {
                topBar
                gameGrid
                Spacer()
            }
            .backgroundGradient()
             
            if viewModel.gameState.isFinished {
                gameOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .onDisappear {
            handleViewDisappear()
        }
        .onChange(of: viewModel.gameState) { oldValue, newValue in
            handleGameStateChange(newValue)
        }
        .sheet(isPresented: $shakeService.isDebugViewPresented) {
            DebugView(viewModel: viewModel)
        }
        .onShake {
            shakeService.handleShake()
        }
    }
    
    // MARK: - Subviews
    
    private var topBar: some View {
        HStack {
            mineCounter
            Spacer()
            restartButton
            Spacer()
            timerView
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
    
    private var mineCounter: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text("\(viewModel.remainingMines)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(minWidth: 30, alignment: .trailing) // Фиксируем ширину для стабильности
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular)
    }
    
    private var restartButton: some View {
        Button(action: {
            viewModel.resetGame(modelContext: modelContext)
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                }
        }
    }
    
    private var timerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .foregroundStyle(.blue)
            Text(viewModel.formattedTime)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(minWidth: 40, alignment: .trailing) // Фиксируем ширину для 3+ цифр
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular)
    }
    
    private var gameGrid: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            LazyVStack(spacing: 2) {
                ForEach(0..<viewModel.board.size, id: \.self) { row in
                    LazyHStack(spacing: 2) {
                        ForEach(0..<viewModel.board.size, id: \.self) { column in
                            let cell = viewModel.board.cells[row][column]
                            GridCellView(
                                cell: cell,
                                cellSize: viewModel.calculateCellSize(),
                                onTap: {
                                    // Явно захватываем координаты для предотвращения проблем с замыканием
                                    viewModel.openCell(row: row, column: column)
                                },
                                onLongPress: {
                                    // Явно захватываем координаты для предотвращения проблем с замыканием
                                    viewModel.toggleFlag(row: row, column: column)
                                }
                            )
                            .id(cell.id) // Используем стабильный идентификатор из модели
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var gameOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Анимация эмодзи в зависимости от состояния игры
            if viewModel.gameState == .won {
                EmojiAnimationView(type: .fireworks)
            } else if viewModel.gameState == .lost {
                EmojiAnimationView(type: .bombs)
            }
            
            if viewModel.gameState == .won && showNameInput {
                nameInputView
            } else {
                gameOverView
            }
        }
    }
    
    private var nameInputView: some View {
        VStack(spacing: 24) {
            nameInputTitle
            nameInputField
            nameInputButtons
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(40)
    }

    private var nameInputTitle: some View {
        Text("Введите ваше имя")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }

    private var nameInputField: some View {
        TextField("Имя игрока", text: $playerName)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 40)
            .autocapitalization(.words)
            .submitLabel(.done)
            .onSubmit(saveResult)
    }

    private var nameInputButtons: some View {
        HStack(spacing: 20) {
            PrimaryButton(
                title: "Сохранить",
                action: saveResult,
                isEnabled: playerName.isNotEmptyAfterTrimming
            )
            
            SecondaryButton(title: "Пропустить") {
                showNameInput = false
                playerName = ""
            }
        }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            gameResultIcon
            gameResultTitle
            gameTimeInfo
            gameOverButtons
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(40)
    }

    private var gameResultIcon: some View {
        Image(systemName: viewModel.gameState == .won ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 80))
            .foregroundStyle(viewModel.gameState == .won ? .green : .red)
    }

    private var gameResultTitle: some View {
        Text(viewModel.gameState == .won ? "Вы выиграли!" : "Игра окончена")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }

    private var gameTimeInfo: some View {
        Text("Время: \(viewModel.formattedTime) секунд")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
    }

    private var gameOverButtons: some View {
        HStack(spacing: 20) {
            PrimaryButton(
                title: viewModel.gameState == .won ? "Сохранить результат" : "Играть снова"
            ) {
                if viewModel.gameState == .won {
                    showNameInput = true
                } else {
                    viewModel.resetGame(modelContext: modelContext)
                }
            }
            
            SecondaryButton(title: "Главное меню") {
                dismiss()
            }
        }
    }
    
    private var backButton: some View {
        Button(action: handleBackButton) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Назад")
            }
            .foregroundStyle(.white)
        }
    }
    
    // MARK: - Private Methods
    
    private func saveResult() {
        logger.info("Saving game result")
        do {
            try viewModel.saveResult(
                playerName: playerName.sanitizedPlayerName,
                modelContext: modelContext
            )
            // Убеждаемся, что удаление сохранено в базе данных
            try modelContext.save()
            logger.info("Saved game deletion successfully persisted after saving result")
            
            showNameInput = false
            viewModel.resetGame(modelContext: modelContext)
            dismiss()
        } catch {
            logger.error("Failed to save result", error: error)
        }
    }
    
    private func handleBackButton() {
        logger.info("Back button pressed, game state: \(viewModel.gameState.rawValue)")
        
        if viewModel.gameState.isActive {
            logger.info("Saving game before going back")
            viewModel.saveGame(modelContext: modelContext)
            
            // Убеждаемся, что сохранение записано в базе данных
            do {
                try modelContext.save()
                logger.info("Game saved and context saved successfully")
            } catch {
                logger.error("Failed to save context after saving game", error: error)
            }
        } else {
            logger.info("Game is finished, no need to save")
        }
        
        viewModel.stopTimer()
        dismiss()
    }
    
    private func handleViewDisappear() {
        if viewModel.gameState.isActive {
            logger.info("View disappeared, saving game progress")
            viewModel.saveGame(modelContext: modelContext)
            
            // Убеждаемся, что сохранение записано в базу данных
            do {
                try modelContext.save()
                logger.info("Game progress saved successfully on view disappear")
            } catch {
                logger.error("Failed to save game progress on view disappear", error: error)
            }
        }
        viewModel.stopTimer()
    }
    
    private func handleGameStateChange(_ newState: GameState) {
        if newState.isFinished {
            logger.info("Game finished with state: \(newState.rawValue), deleting saved game immediately")
            do {
                let descriptor = FetchDescriptor<SavedGame>()
                if let savedGame = try modelContext.fetch(descriptor).first {
                    modelContext.delete(savedGame)
                    try modelContext.save()
                    logger.info("Saved game deleted immediately after game finish")
                } else {
                    logger.debug("No saved game found to delete")
                }
            } catch {
                logger.error("Failed to delete saved game after finish", error: error)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameView(viewModel: DependencyContainer.shared.makeGameViewModel(difficulty: .beginner))
    }
}
