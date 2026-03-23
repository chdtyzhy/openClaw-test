//
//  SimpleCalculatorView.swift
//  简化版计算器视图
//

import SwiftUI
import Combine

struct SimpleCalculatorView: View {
    @StateObject private var calculator = SimpleCalculator()
    
    let buttons = [
        ["7", "8", "9", "÷"],
        ["4", "5", "6", "×"],
        ["1", "2", "3", "−"],
        ["0", ".", "C", "+"],
        ["="]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // 显示区域
            Text(calculator.display)
                .font(.system(size: 48, weight: .light))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
            // 按钮网格
            VStack(spacing: 12) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButton(title: button) {
                                handleButtonTap(button)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private func handleButtonTap(_ button: String) {
        switch button {
        case "0"..."9":
            calculator.inputDigit(button)
        case ".":
            calculator.inputDecimal()
        case "C":
            calculator.clear()
        case "+":
            calculator.setOperation(.add)
        case "−":
            calculator.setOperation(.subtract)
        case "×":
            calculator.setOperation(.multiply)
        case "÷":
            calculator.setOperation(.divide)
        case "=":
            calculator.equals()
        default:
            break
        }
    }
}

struct CalculatorButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 28, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(buttonColor)
                .foregroundColor(buttonTextColor)
                .cornerRadius(10)
        }
    }
    
    private var buttonColor: Color {
        if title == "C" {
            return .orange
        } else if ["+", "−", "×", "÷", "="].contains(title) {
            return .blue
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var buttonTextColor: Color {
        if ["C", "+", "−", "×", "÷", "="].contains(title) {
            return .white
        } else {
            return .primary
        }
    }
}

#Preview {
    SimpleCalculatorView()
}