//
//  CalculatorButtonsView.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

struct CalculatorButtonsView: View {
    let onNumberPressed: (String) -> Void
    let onOperatorPressed: (String) -> Void
    let onFunctionPressed: (String) -> Void
    let onEqualsPressed: () -> Void
    let onClearPressed: () -> Void
    
    @EnvironmentObject private var calculatorManager: CalculatorManager
    @State private var pressedButton: String? = nil
    
    // 按钮布局配置
    private let buttonRows: [[CalculatorButton]] = [
        [
            .function("C", color: .red),
            .function("+/-", color: .gray),
            .function("%", color: .gray),
            .operator("÷", color: .orange)
        ],
        [
            .number("7"),
            .number("8"),
            .number("9"),
            .operator("×", color: .orange)
        ],
        [
            .number("4"),
            .number("5"),
            .number("6"),
            .operator("-", color: .orange)
        ],
        [
            .number("1"),
            .number("2"),
            .number("3"),
            .operator("+", color: .orange)
        ],
        [
            .number("0", isWide: true),
            .number("."),
            .equals("=", color: .blue)
        ]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(buttonRows, id: \.self) { row in
                HStack(spacing: 16) {
                    ForEach(row, id: \.id) { button in
                        CalculatorButtonView(
                            button: button,
                            isPressed: pressedButton == button.id,
                            onPress: handleButtonPress
                        )
                        .frame(maxWidth: button.isWide ? .infinity : nil)
                    }
                }
            }
        }
    }
    
    private func handleButtonPress(_ button: CalculatorButton) {
        // 触觉反馈
        if calculatorManager.isHapticFeedbackEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        // 按钮按下动画
        withAnimation(.easeInOut(duration: 0.1)) {
            pressedButton = button.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                pressedButton = nil
            }
        }
        
        // 处理按钮逻辑
        switch button {
        case .number(let value):
            onNumberPressed(value)
        case .operator(let symbol, _):
            onOperatorPressed(symbol)
        case .function(let symbol, _):
            if symbol == "C" {
                onClearPressed()
            } else {
                onFunctionPressed(symbol)
            }
        case .equals:
            onEqualsPressed()
        }
    }
}

// MARK: - 按钮类型
enum CalculatorButton: Hashable {
    case number(String, isWide: Bool = false)
    case `operator`(String, color: Color = .orange)
    case function(String, color: Color = .gray)
    case equals(String, color: Color = .blue)
    
    var id: String {
        switch self {
        case .number(let value, let isWide):
            return "number_\(value)_\(isWide)"
        case .operator(let symbol, let color):
            return "operator_\(symbol)_\(color.hashValue)"
        case .function(let symbol, let color):
            return "function_\(symbol)_\(color.hashValue)"
        case .equals(let symbol, let color):
            return "equals_\(symbol)_\(color.hashValue)"
        }
    }
    
    var label: String {
        switch self {
        case .number(let value, _):
            return value
        case .operator(let symbol, _):
            return symbol
        case .function(let symbol, _):
            return symbol
        case .equals(let symbol, _):
            return symbol
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .number:
            return Color(uiColor: .secondarySystemBackground)
        case .operator(_, let color):
            return color
        case .function(_, let color):
            return color
        case .equals(_, let color):
            return color
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .number:
            return .primary
        case .operator, .function, .equals:
            return .white
        }
    }
    
    var isWide: Bool {
        if case .number(_, let isWide) = self {
            return isWide
        }
        return false
    }
    
    var fontSize: CGFloat {
        switch self {
        case .number, .operator, .function:
            return 32
        case .equals:
            return 36
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .number, .function:
            return .medium
        case .operator, .equals:
            return .semibold
        }
    }
}

// MARK: - 单个按钮视图
struct CalculatorButtonView: View {
    let button: CalculatorButton
    let isPressed: Bool
    let onPress: (CalculatorButton) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: { onPress(button) }) {
            Text(button.label)
                .font(.system(size: button.fontSize, weight: button.fontWeight))
                .foregroundColor(button.foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(CalculatorButtonStyle(
            backgroundColor: button.backgroundColor,
            isPressed: isPressed,
            isWide: button.isWide
        ))
        .aspectRatio(button.isWide ? 2 : 1, contentMode: .fit)
    }
}

// MARK: - 按钮样式
struct CalculatorButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isPressed: Bool
    let isWide: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if isPressed {
                        backgroundColor
                            .opacity(0.8)
                    } else {
                        backgroundColor
                    }
                }
            )
            .clipShape(isWide ? Capsule() : Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(
                color: colorScheme == .dark ? 
                    Color.black.opacity(0.5) : 
                    Color.gray.opacity(0.3),
                radius: configuration.isPressed ? 2 : 4,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
    }
}

// MARK: - 科学计算面板
struct ScientificPanelView: View {
    let onFunctionSelected: (String) -> Void
    
    private let scientificFunctions = [
        ["sin", "cos", "tan", "log", "ln"],
        ["√", "x²", "x³", "π", "e"],
        ["asin", "acos", "atan", "sinh", "cosh"],
        ["tanh", "exp", "10ˣ", "eˣ", "xʸ"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(scientificFunctions, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { function in
                        ScientificButton(
                            function: function,
                            onPress: { onFunctionSelected(function) }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .tertiarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct ScientificButton: View {
    let function: String
    let onPress: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onPress()
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            Text(function)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 36)
        .background(
            Group {
                if isPressed {
                    Color.blue.opacity(0.8)
                } else {
                    Color.blue
                }
            }
        )
        .cornerRadius(8)
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    CalculatorButtonsView(
        onNumberPressed: { _ in },
        onOperatorPressed: { _ in },
        onFunctionPressed: { _ in },
        onEqualsPressed: { },
        onClearPressed: { }
    )
    .environmentObject(CalculatorManager())
    .padding()
    .background(Color(uiColor: .systemBackground))
}