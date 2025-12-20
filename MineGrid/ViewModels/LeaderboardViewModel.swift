//
//  LeaderboardViewModel.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import Foundation
import SwiftData
import Combine

/// ViewModel для управления данными таблицы лидеров
class LeaderboardViewModel: ObservableObject {
    @Published var selectedDifficulty: Difficulty = .beginner
    @Published var entries: [LeaderboardEntry] = []

    private let modelContext: ModelContext
    private var cachedEntries: [Difficulty: [LeaderboardEntry]] = [:]
    private let logger: LogService

    init(modelContext: ModelContext, logger: LogService = AppLogger(category: "LeaderboardViewModel")) {
        self.modelContext = modelContext
        self.logger = logger
    }

    /// Загружает результаты из хранилища и преобразует их в записи таблицы лидеров
    func loadEntries() {
        // Проверяем кэш
        if let cached = cachedEntries[selectedDifficulty], !cached.isEmpty {
            entries = cached
            return
        }

        let fetchDescriptor = FetchDescriptor<GameResult>(sortBy: [SortDescriptor(\GameResult.time, order: .forward)])

        do {
            let results = try modelContext.fetch(fetchDescriptor)
            entries = results.map { result in
                let difficulty = Difficulty(rawValue: result.difficulty) ?? .beginner
                return LeaderboardEntry(
                    username: result.playerName,
                    date: result.date,
                    time: TimeInterval(result.time),
                    difficulty: difficulty
                )
            }
            
            // Кэшируем результаты
            cacheEntries()
        } catch {
            logger.error("Failed to fetch game results", error: error)
        }
    }

    /// Кэширует записи по уровням сложности
    private func cacheEntries() {
        for difficulty in Difficulty.allCases {
            let filtered = entries.filter { $0.difficulty == difficulty }
            cachedEntries[difficulty] = filtered.sorted { $0.time < $1.time }
        }
    }

    /// Фильтрует и сортирует записи по выбранному уровню сложности
    var filteredEntries: [LeaderboardEntry] {
        if let cached = cachedEntries[selectedDifficulty] {
            return cached
        }
        return entries
            .filter { $0.difficulty == selectedDifficulty }
            .sorted { $0.time < $1.time }
    }

    /// Очищает кэш
    func clearCache() {
        cachedEntries.removeAll()
    }
}