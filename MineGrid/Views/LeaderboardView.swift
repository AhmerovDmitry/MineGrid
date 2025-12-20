//
//  LeaderboardView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import SwiftUI
import SwiftData

/// Экран таблицы лидеров с табами для разных уровней сложности
struct LeaderboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: LeaderboardViewModel
    @Environment(\.dismiss) private var dismiss

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: LeaderboardViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок
                headerView

                // Табы для выбора уровня сложности
                difficultyTabs

                // Список записей
                if viewModel.filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    leaderboardList
                }
            }
            .backgroundGradient()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear {
                viewModel.loadEntries()
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 32))
                .foregroundStyle(.yellow)

            Text("Таблица лидеров")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Топ 10 игр")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }

    private var difficultyTabs: some View {
        HStack(spacing: 0) {
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                difficultyTab(difficulty: difficulty)
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }

    private func difficultyTab(difficulty: Difficulty) -> some View {
        Button(action: {
            viewModel.selectedDifficulty = difficulty
        }) {
            Text(difficulty.rawValue)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(viewModel.selectedDifficulty == difficulty ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(viewModel.selectedDifficulty == difficulty ? .white : .clear)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle.portrait.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.5))

            Text("Нет записей")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text("Сыграйте несколько игр, чтобы увидеть результаты")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var leaderboardList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Заголовок таблицы
                HStack {
                    Text("Место")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 50, alignment: .leading)

                    Text("Игрок")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Время")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 80, alignment: .trailing)

                    Text("Дата")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 100, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                // Разделитель
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 20)

                // Записи таблицы лидеров
                ForEach(Array(viewModel.filteredEntries.prefix(10).enumerated()), id: \.element.id) { index, entry in
                    leaderboardRow(index: index, entry: entry)
                }
            }
            .padding(.top, 10)
        }
    }

    private func leaderboardRow(index: Int, entry: LeaderboardEntry) -> some View {
        VStack(spacing: 0) {
            HStack {
                // Место
                Text("#\(index + 1)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(index < 3 ? medalColor(for: index) : .white)
                    .frame(width: 50, alignment: .leading)

                // Имя игрока
                Text(entry.username)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Время
                Text(entry.time.formattedTimeWithRussianSuffix)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 80, alignment: .trailing)

                // Дата
                Text(entry.date.formattedDate)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 100, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Разделитель (кроме последней записи)
            if index < min(9, viewModel.filteredEntries.count - 1) {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Helper Methods

    private func medalColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow // Золото
        case 1: return .gray // Серебро
        case 2: return .orange // Бронза
        default: return .white
        }
    }
}

// MARK: - Extensions

extension TimeInterval {
    var formattedTimeWithRussianSuffix: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes == 0 {
            return "\(seconds) сек"
        } else if seconds == 0 {
            return "\(minutes) мин"
        } else {
            return "\(minutes) мин \(seconds) сек"
        }
    }
}

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}

// MARK: - Preview

#Preview {
    LeaderboardView(modelContext: ModelContext(try! ModelContainer(for: GameResult.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))))
}