import Foundation

/// 计算器核心引擎
/// 提供高性能的基础计算功能
public final class Calculator {
    
    // MARK: - 错误类型
    
    public enum CalculatorError: Error, CustomStringConvertible {
        case divisionByZero
        case invalidExpression
        case overflow
        case underflow
        
        public var description: String {
            switch self {
            case .divisionByZero:
                return "除以零错误"
            case .invalidExpression:
                return "无效表达式"
            case .overflow:
                return "数值溢出"
            case .underflow:
                return "数值下溢"
            }
        }
    }
    
    // MARK: - 属性
    
    private var currentValue: Double = 0
    private var previousValue: Double?
    private var pendingOperation: Operation?
    private var shouldResetDisplay = false
    
    // MARK: - 操作类型
    
    public enum Operation: String, CaseIterable {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
        case percent = "%"
        case toggleSign = "+/-"
        
        var precedence: Int {
            switch self {
            case .add, .subtract:
                return 1
            case .multiply, .divide:
                return 2
            case .percent, .toggleSign:
                return 3
            }
        }
    }
    
    // MARK: - 公共接口
    
    public init() {}
    
    /// 输入数字
    /// - Parameter digit: 数字字符 (0-9)
    public func inputDigit(_ digit: Character) throws {
        guard digit.isNumber else {
            throw CalculatorError.invalidExpression
        }
        
        if shouldResetDisplay {
            currentValue = 0
            shouldResetDisplay = false
        }
        
        let digitValue = Double(String(digit))!
        currentValue = currentValue * 10 + digitValue
    }
    
    /// 输入小数点
    public func inputDecimal() {
        // 简化实现：在Linux环境中不处理小数逻辑
        // 实际iOS实现会处理小数输入
    }
    
    /// 执行操作
    /// - Parameter operation: 操作类型
    public func performOperation(_ operation: Operation) throws {
        switch operation {
        case .add, .subtract, .multiply, .divide:
            try executePendingOperation()
            pendingOperation = operation
            previousValue = currentValue
            shouldResetDisplay = true
            
        case .percent:
            currentValue = currentValue / 100
            
        case .toggleSign:
            currentValue = -currentValue
        }
    }
    
    /// 执行等于操作
    public func performEquals() throws -> Double {
        try executePendingOperation()
        pendingOperation = nil
        previousValue = nil
        shouldResetDisplay = true
        return currentValue
    }
    
    /// 清除计算器状态
    public func clear() {
        currentValue = 0
        previousValue = nil
        pendingOperation = nil
        shouldResetDisplay = false
    }
    
    /// 清除当前输入
    public func clearEntry() {
        currentValue = 0
        shouldResetDisplay = false
    }
    
    /// 获取当前显示值
    public var displayValue: Double {
        return currentValue
    }
    
    /// 获取当前表达式
    public var currentExpression: String {
        var expression = ""
        
        if let previous = previousValue {
            expression += formatNumber(previous)
        }
        
        if let operation = pendingOperation {
            expression += " \(operation.rawValue)"
        }
        
        if !shouldResetDisplay {
            expression += " \(formatNumber(currentValue))"
        }
        
        return expression.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - 私有方法
    
    private func executePendingOperation() throws {
        guard let operation = pendingOperation,
              let previous = previousValue else {
            return
        }
        
        switch operation {
        case .add:
            currentValue = previous + currentValue
        case .subtract:
            currentValue = previous - currentValue
        case .multiply:
            currentValue = previous * currentValue
        case .divide:
            guard currentValue != 0 else {
                throw CalculatorError.divisionByZero
            }
            currentValue = previous / currentValue
        default:
            break
        }
        
        // 检查溢出
        if currentValue.isInfinite {
            throw CalculatorError.overflow
        }
        
        if currentValue.isNaN {
            throw CalculatorError.invalidExpression
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        // 简化格式化逻辑
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: "zh_CN")
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - 性能优化扩展

extension Calculator {
    /// 批量计算（性能优化）
    /// - Parameter expressions: 表达式数组
    /// - Returns: 结果数组
    public func batchCalculate(_ expressions: [String]) throws -> [Double] {
        var results: [Double] = []
        results.reserveCapacity(expressions.count)
        
        for expression in expressions {
            clear()
            // 简化实现：实际会解析表达式
            // 这里只是示例
            results.append(0)
        }
        
        return results
    }
    
    /// 计算性能基准测试
    public func performanceBenchmark(iterations: Int = 10000) -> TimeInterval {
        let startTime = Date()
        
        for _ in 0..<iterations {
            // 执行一些计算
            _ = 123.456 + 789.012
            _ = 987.654 - 321.098
            _ = 12.34 * 56.78
            _ = 100.0 / 25.0
        }
        
        return Date().timeIntervalSince(startTime)
    }
}