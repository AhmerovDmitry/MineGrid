//
//  GridCellView.swift
//  MineGrid
//
//  Created by Dmitriy Akhmerov on 03.12.2025.
//

import SwiftUI

/// Компонент отображения одной ячейки игрового поля
struct GridCellView: View {
    /// Модель ячейки для отображения
    let cell: CellModel
    /// Размер ячейки в пикселях
    let cellSize: CGFloat
    /// Действие при обычном нажатии (открытие ячейки)
    let onTap: () -> Void
    /// Действие при долгом нажатии (установка/снятие флага)
    let onLongPress: () -> Void
    
    @State private var isLongPressing = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(borderColor, lineWidth: 1)
                }
            
            if cell.state == .opened {
                if cell.isMine {
                    Image(systemName: "circle.fill")
                        .font(.system(size: cellSize * 0.5))
                        .foregroundStyle(.red)
                } else if cell.adjacentMines > 0 {
                    Text("\(cell.adjacentMines)")
                        .font(.system(size: cellSize * 0.5, weight: .bold, design: .rounded))
                        .foregroundStyle(numberColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            } else if cell.state == .flagged {
                Image(systemName: "flag.fill")
                    .font(.system(size: cellSize * 0.4))
                    .foregroundStyle(.red)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isLongPressing else {
                isLongPressing = false
                return
            }
            onTap()
            isLongPressing = false
        }
        .onLongPressGesture(minimumDuration: 0.3) {
            isLongPressing = true
            onLongPress()
        }
    }
    
    /// Цвет фона ячейки в зависимости от её состояния
    private var backgroundColor: Color {
        switch cell.state {
        case .closed:
            return Color(red: 0.4, green: 0.4, blue: 0.45)
        case .opened:
            if cell.isMine {
                return Color.red.opacity(0.3)
            }
            return Color(red: 0.3, green: 0.3, blue: 0.35)
        case .flagged:
            return Color(red: 0.4, green: 0.4, blue: 0.45)
        }
    }
    
    /// Цвет границы ячейки в зависимости от её состояния
    private var borderColor: Color {
        switch cell.state {
        case .closed:
            return Color.white.opacity(0.2)
        case .opened:
            return Color.white.opacity(0.1)
        case .flagged:
            return Color.white.opacity(0.2)
        }
    }
    
    /// Цвет цифры в зависимости от количества соседних мин
    private var numberColor: Color {
        switch cell.adjacentMines {
        case 1:
            return .blue
        case 2:
            return .green
        case 3:
            return .red
        case 4:
            return .purple
        case 5:
            return .brown
        case 6:
            return .pink
        case 7:
            return .black
        case 8:
            return .gray
        default:
            return .primary
        }
    }
}

#Preview {
    HStack {
        GridCellView(
            cell: CellModel(row: 0, column: 0, state: .closed),
            cellSize: 30,
            onTap: {},
            onLongPress: {}
        )
        GridCellView(
            cell: CellModel(row: 0, column: 1, adjacentMines: 2, state: .opened),
            cellSize: 30,
            onTap: {},
            onLongPress: {}
        )
        GridCellView(
            cell: CellModel(row: 0, column: 2, state: .flagged),
            cellSize: 30,
            onTap: {},
            onLongPress: {}
        )
    }
    .padding()
    .background(Color.black)
}

