//
//  GameRulesView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI

/// Экран с правилами и инструкциями игры
struct GameRulesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    objectiveSection
                    howToPlaySection
                    rulesSection
                    tipsSection
                }
                .padding(20)
            }
            .backgroundGradient()
            .navigationTitle("Правила игры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.8))
            
            Text("Сапер")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var objectiveSection: some View {
        rulesCard(
            title: "Цель",
            icon: "target",
            content: {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Откройте все ячейки без мин или правильно пометьте все мины.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                     
                    Text("Игра выиграна, когда:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                     
                    ruleItem("Все ячейки без мин открыты")
                    ruleItem("Все мины помечены и нет закрытых ячеек")
                }
            }
        )
    }
    
    private var howToPlaySection: some View {
        rulesCard(
            title: "Как играть",
            icon: "play.circle",
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    instructionStep(
                        number: "1",
                        title: "Открыть ячейку",
                        description: "Нажмите на закрытую ячейку, чтобы открыть её. Первый ход всегда безопасен - мины размещаются после первого хода."
                    )
                     
                    instructionStep(
                        number: "2",
                        title: "Используйте числа",
                        description: "Числа показывают, сколько мин находится в соседних ячейках (до 8 соседей). Используйте эту информацию, чтобы определить безопасные ячейки."
                    )
                     
                    instructionStep(
                        number: "3",
                        title: "Пометить мины",
                        description: "Долгое нажатие на ячейку установит или удалит флаг. Флаги отмечают ячейки, которые, по вашему мнению, содержат мины."
                    )
                     
                    instructionStep(
                        number: "4",
                        title: "Очистить пустые области",
                        description: "Когда вы открываете пустую ячейку (без соседних мин), все окружающие пустые ячейки открываются автоматически."
                    )
                }
            }
        )
    }
    
    private var rulesSection: some View {
        rulesCard(
            title: "Правила",
            icon: "list.bullet.rectangle",
            content: {
                VStack(alignment: .leading, spacing: 12) {
                    ruleItem("Вы не можете разместить больше флагов, чем количество мин")
                    ruleItem("Игра не заканчивается, пока не открыты все безопасные ячейки")
                    ruleItem("Если вы открываете ячейку с миной, вы проигрываете")
                    ruleItem("Таймер начинается с вашего первого хода")
                }
            }
        )
    }
    
    private var tipsSection: some View {
        rulesCard(
            title: "Советы",
            icon: "lightbulb.fill",
            content: {
                VStack(alignment: .leading, spacing: 12) {
                    tipItem("Начните с углов и краев - у них меньше соседей")
                    tipItem("Ищите закономерности - если число совпадает с количеством закрытых соседей, все они мины")
                    tipItem("Если число совпадает с помеченными соседями, оставшиеся закрытые ячейки безопасны")
                    tipItem("Не спешите - нет штрафа за размышления")
                }
            }
        )
    }
    
    // MARK: - Helper Views
    
    private func rulesCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, alignment: .leading)
                 
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            content()
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func ruleItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(.green)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
    
    private func tipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 16))
                .foregroundStyle(.yellow)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
    
    private func instructionStep(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text(number)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GameRulesView()
}

