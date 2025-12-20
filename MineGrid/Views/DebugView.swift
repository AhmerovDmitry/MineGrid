//
//  DebugView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 20.12.2025.
//

import SwiftUI

/// Полноценный экран для отладки
struct DebugView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Debug Menu")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                VStack(spacing: 20) {
                    Button(action: {
                        viewModel.setDebugWinState()
                        dismiss()
                    }) {
                        Text("Show Win Screen")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)

                    Button(action: {
                        viewModel.setDebugLoseState()
                        dismiss()
                    }) {
                        Text("Show Lose Screen")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)

                    Button(action: {
                        viewModel.resetGame()
                        dismiss()
                    }) {
                        Text("Reset Game")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                }

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 50)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DebugView(viewModel: DependencyContainer.shared.makeGameViewModel(difficulty: .beginner))
    }
}