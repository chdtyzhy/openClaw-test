//
//  CalculatorSimple.swift
//  简化版计算器模型
//

import Foundation
import Combine

// MARK: - 简化计算操作枚举
enum SimpleCalculatorOperation: String, CaseIterable, Equatable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case equals = "="
}

// MARK: - 历史记录项
struct HistoryItem: Identifiable, Equatable {
    let id = UUID()
    let expression: String
    let result: String
    let timestamp: Date
    
    init(expression: String, result: String) {
        self.expression = expression
        self.result = result
        self.timestamp = Date()
    }
    
    var displayText: String {
        return "\(expression) = \(result)"
    }
}

// MARK: - 简化计算器
class SimpleCalculator: ObservableObject {
    // 使用 @Published
    @Published var display: String = "0"
    @Published var operation: SimpleCalculatorOperation?
    @Published var history: [HistoryItem] = []
    
    private var firstNumber: Double = 0
    private var secondNumber: Double = 0
    private var isSecondNumber = false
    
    init() {
        // 空初始化
    }
    
    func inputDigit(_ digit: String) {
        if display == "0" || isSecondNumber {
            display = digit
            isSecondNumber = false
        } else {
            display += digit
        }
    }
    
    func inputDecimal() {
        if !display.contains(".") {
            display += "."
        }
    }
    
    func clear() {
        display = "0"
        firstNumber = 0
        secondNumber = 0
        operation = nil
        isSecondNumber = false
    }
    
    func setOperation(_ op: SimpleCalculatorOperation) {
        if let value = Double(display) {
            if operation == nil {
                firstNumber = value
            } else {
                calculate()
            }
            operation = op
            isSecondNumber = true
        }
    }
    
    func calculate() {
        guard let op = operation,
              let currentValue = Double(display) else {
            return
        }
        
        secondNumber = currentValue
        var result: Double = 0
        
        switch op {
        case .add:
            result = firstNumber + secondNumber
        case .subtract:
            result = firstNumber - secondNumber
        case .multiply:
            result = firstNumber * secondNumber
        case .divide:
            result = secondNumber != 0 ? firstNumber / secondNumber : 0
        case .equals:
            return
        }
        
        // 处理特殊结果
        if result.isNaN || result.isInfinite {
            display = "错误"
        } else {
            // 格式化显示
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 10
            formatter.minimumFractionDigits = 0
            formatter.groupingSeparator = ""
            display = formatter.string(from: NSNumber(value: result)) ?? "\(result)"
            
            // 记录到历史
            let expression = "\(formatNumber(firstNumber)) \(op.displaySymbol) \(formatNumber(secondNumber))"
            let historyItem = HistoryItem(expression: expression, result: display)
            history.insert(historyItem, at: 0)
            
            // 限制历史记录数量
            if history.count > 50 {
                history.removeLast()
            }
        }
        
        firstNumber = result
        operation = nil
        isSecondNumber = true
    }
    
    func equals() {
        calculate()
    }
    
    // MARK: - 历史记录管理
    func clearHistory() {
        history.removeAll()
    }
    
    func useHistoryItem(_ item: HistoryItem) {
        display = item.result
        isSecondNumber = true
    }
    
    // MARK: - 工具函数
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}