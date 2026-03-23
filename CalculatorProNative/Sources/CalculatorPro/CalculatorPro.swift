import Foundation
import CalculatorCore
import ScientificEngine

/// 计算器专业版主框架
/// 集成基础计算和科学计算，提供完整的计算器功能
public final class CalculatorPro {
    
    // MARK: - 属性
    
    private let basicCalculator: Calculator
    private let scientificCalculator: ScientificCalculator
    private var calculationHistory: [CalculationRecord] = []
    private let maxHistorySize = 100
    
    // MARK: - 计算模式
    
    public enum CalculatorMode {
        case basic           // 基础计算模式
        case scientific      // 科学计算模式
        case programmer      // 程序员模式
        case converter       // 单位换算模式
    }
    
    // MARK: - 计算记录
    
    public struct CalculationRecord: Codable {
        public let id: UUID
        public let expression: String
        public let result: String
        public let timestamp: Date
        public let mode: CalculatorMode
        
        public init(expression: String, result: String, mode: CalculatorMode) {
            self.id = UUID()
            self.expression = expression
            self.result = result
            self.timestamp = Date()
            self.mode = mode
        }
    }
    
    // MARK: - 初始化
    
    public init() {
        self.basicCalculator = Calculator()
        self.scientificCalculator = ScientificCalculator()
    }
    
    // MARK: - 基础计算
    
    /// 输入数字
    /// - Parameter digit: 数字字符
    public func inputDigit(_ digit: Character) throws {
        try basicCalculator.inputDigit(digit)
    }
    
    /// 执行基础操作
    /// - Parameter operation: 操作类型
    public func performBasicOperation(_ operation: Calculator.Operation) throws {
        try basicCalculator.performOperation(operation)
    }
    
    /// 执行等于操作
    /// - Returns: 计算结果
    @discardableResult
    public func performEquals() throws -> Double {
        let result = try basicCalculator.performEquals()
        addToHistory(
            expression: basicCalculator.currentExpression,
            result: formatNumber(result),
            mode: .basic
        )
        return result
    }
    
    /// 获取当前显示值
    public var displayValue: Double {
        return basicCalculator.displayValue
    }
    
    /// 获取当前表达式
    public var currentExpression: String {
        return basicCalculator.currentExpression
    }
    
    // MARK: - 科学计算
    
    /// 设置角度模式
    /// - Parameter mode: 角度模式
    public func setAngleMode(_ mode: ScientificCalculator.AngleMode) {
        scientificCalculator.setAngleMode(mode)
    }
    
    /// 执行科学计算函数
    /// - Parameters:
    ///   - function: 函数名
    ///   - value: 输入值
    /// - Returns: 计算结果
    @discardableResult
    public func performScientificFunction(_ function: String, value: Double) throws -> Double {
        let result: Double
        
        switch function.lowercased() {
        case "sin":
            result = try scientificCalculator.sin(value)
        case "cos":
            result = try scientificCalculator.cos(value)
        case "tan":
            result = try scientificCalculator.tan(value)
        case "asin":
            result = try scientificCalculator.asin(value)
        case "acos":
            result = try scientificCalculator.acos(value)
        case "atan":
            result = try scientificCalculator.atan(value)
        case "log":
            result = try scientificCalculator.log10(value)
        case "ln":
            result = try scientificCalculator.ln(value)
        case "exp":
            result = scientificCalculator.exp(value)
        case "exp10":
            result = scientificCalculator.exp10(value)
        case "sqrt":
            result = try scientificCalculator.sqrt(value)
        case "square":
            result = scientificCalculator.square(value)
        case "cube":
            result = scientificCalculator.cube(value)
        case "reciprocal":
            result = try scientificCalculator.reciprocal(value)
        case "factorial":
            result = try scientificCalculator.factorial(Int(value))
        default:
            throw ScientificCalculator.ScientificError.invalidInput
        }
        
        addToHistory(
            expression: "\(function)(\(formatNumber(value)))",
            result: formatNumber(result),
            mode: .scientific
        )
        
        return result
    }
    
    /// 获取数学常数
    /// - Parameter constant: 常数名
    /// - Returns: 常数值
    public func getConstant(_ constant: String) -> Double? {
        switch constant.lowercased() {
        case "pi":
            return scientificCalculator.pi
        case "e":
            return scientificCalculator.e
        case "phi", "goldenratio":
            return scientificCalculator.goldenRatio
        default:
            return nil
        }
    }
    
    // MARK: - 历史记录管理
    
    /// 添加计算记录到历史
    private func addToHistory(expression: String, result: String, mode: CalculatorMode) {
        let record = CalculationRecord(
            expression: expression,
            result: result,
            mode: mode
        )
        
        calculationHistory.insert(record, at: 0)
        
        // 限制历史记录大小
        if calculationHistory.count > maxHistorySize {
            calculationHistory.removeLast()
        }
    }
    
    /// 获取计算历史
    /// - Parameter limit: 返回的最大记录数
    /// - Returns: 计算记录数组
    public func getCalculationHistory(limit: Int = 50) -> [CalculationRecord] {
        return Array(calculationHistory.prefix(limit))
    }
    
    /// 清除计算历史
    public func clearHistory() {
        calculationHistory.removeAll()
    }
    
    /// 删除特定记录
    /// - Parameter id: 记录ID
    public func deleteHistoryRecord(_ id: UUID) {
        calculationHistory.removeAll { $0.id == id }
    }
    
    /// 导出历史记录
    /// - Returns: JSON格式的历史记录
    public func exportHistory() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(calculationHistory)
    }
    
    // MARK: - 状态管理
    
    /// 清除计算器状态
    public func clearAll() {
        basicCalculator.clear()
        scientificCalculator.clearCache()
    }
    
    /// 清除当前输入
    public func clearEntry() {
        basicCalculator.clearEntry()
    }
    
    // MARK: - 格式化
    
    /// 格式化数字显示
    /// - Parameter number: 数字
    /// - Returns: 格式化后的字符串
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        
        // 根据数字大小选择合适的格式
        if abs(number) >= 1_000_000_000 || (abs(number) < 0.0001 && number != 0) {
            formatter.numberStyle = .scientific
            formatter.maximumFractionDigits = 6
            formatter.exponentSymbol = "e"
        } else {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 10
            formatter.minimumFractionDigits = 0
        }
        
        formatter.locale = Locale(identifier: "zh_CN")
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    /// 格式化表达式
    /// - Parameter expression: 原始表达式
    /// - Returns: 格式化后的表达式
    public func formatExpression(_ expression: String) -> String {
        // 简化实现：实际会进行更复杂的格式化
        return expression
            .replacingOccurrences(of: "×", with: "×")
            .replacingOccurrences(of: "÷", with: "÷")
            .replacingOccurrences(of: "+/-", with: "±")
    }
    
    // MARK: - 性能优化
    
    /// 批量计算表达式
    /// - Parameter expressions: 表达式数组
    /// - Returns: 结果数组
    public func batchCalculate(_ expressions: [String]) throws -> [Double] {
        // 简化实现：实际会并行处理
        var results: [Double] = []
        results.reserveCapacity(expressions.count)
        
        for expression in expressions {
            // 这里应该解析并计算表达式
            // 简化实现：返回0
            results.append(0)
        }
        
        return results
    }
    
    /// 运行性能基准测试
    /// - Returns: 各种操作的执行时间
    public func runPerformanceBenchmark() -> [String: TimeInterval] {
        var results: [String: TimeInterval] = [:]
        
        // 基础计算性能
        results["basic"] = basicCalculator.performanceBenchmark()
        
        // 科学计算性能
        results["scientific"] = scientificCalculator.performanceBenchmark()
        
        // 批量计算性能
        let startTime = Date()
        _ = try? batchCalculate(Array(repeating: "1+2*3", count: 1000))
        results["batch"] = Date().timeIntervalSince(startTime)
        
        return results
    }
    
    // MARK: - 错误处理
    
    /// 获取错误描述
    /// - Parameter error: 错误
    /// - Returns: 用户友好的错误描述
    public func getErrorDescription(_ error: Error) -> String {
        if let calcError = error as? Calculator.CalculatorError {
            return calcError.description
        } else if let sciError = error as? ScientificCalculator.ScientificError {
            return sciError.description
        } else {
            return "计算错误: \(error.localizedDescription)"
        }
    }
    
    /// 检查表达式是否有效
    /// - Parameter expression: 表达式
    /// - Returns: 是否有效
    public func validateExpression(_ expression: String) -> Bool {
        // 简化实现：实际会进行语法检查
        return !expression.isEmpty
    }
}

// MARK: - 扩展功能

extension CalculatorPro {
    /// 计算器统计信息
    public struct Statistics {
        public let totalCalculations: Int
        public let scientificCalculations: Int
        public let mostUsedFunction: String
        public let averageCalculationTime: TimeInterval
    }
    
    /// 获取计算器统计信息
    public func getStatistics() -> Statistics {
        let total = calculationHistory.count
        let scientific = calculationHistory.filter { $0.mode == .scientific }.count
        
        // 统计最常用函数（简化实现）
        let mostUsed = "addition"
        
        return Statistics(
            totalCalculations: total,
            scientificCalculations: scientific,
            mostUsedFunction: mostUsed,
            averageCalculationTime: 0.001 // 简化值
        )
    }
    
    /// 计算器设置
    public struct Settings {
        public var vibrationEnabled: Bool = true
        public var soundEnabled: Bool = false
        public var decimalPlaces: Int = 6
        public var angleMode: ScientificCalculator.AngleMode = .degrees
        public var theme: String = "auto"
    }
    
    /// 当前设置
    public private(set) var settings = Settings()
    
    /// 更新设置
    /// - Parameter newSettings: 新设置
    public func updateSettings(_ newSettings: Settings) {
        settings = newSettings
        setAngleMode(newSettings.angleMode)
    }
}

// MARK: - 单位换算（简化实现）

extension CalculatorPro {
    /// 单位类型
    public enum UnitType {
        case length
        case weight
        case temperature
        case currency
        case time
    }
    
    /// 单位换算
    /// - Parameters:
    ///   - value: 数值
    ///   - fromUnit: 源单位
    ///   - toUnit: 目标单位
    ///   - type: 单位类型
    /// - Returns: 换算结果
    public func convertUnit(_ value: Double, from fromUnit: String, to toUnit: String, type: UnitType) throws -> Double {
        // 简化实现：实际会有完整的换算逻辑
        switch type {
        case .length:
            // 长度换算示例
            let factors: [String: Double] = [
                "m": 1.0,
                "km": 1000.0,
                "cm": 0.01,
                "mm": 0.001,
                "inch": 0.0254,
                "foot": 0.3048
            ]
            
            guard let fromFactor = factors[fromUnit],
                  let toFactor = factors[toUnit] else {
                throw ScientificCalculator.ScientificError.invalidInput
            }
            
            return value * fromFactor / toFactor
            
        case .temperature:
            // 温度换算
            if fromUnit == "°C" && toUnit == "°F" {
                return value * 9/5 + 32
            } else if fromUnit == "°F" && toUnit == "°C" {
                return (value - 32) * 5/9
            } else if fromUnit == "°C" && toUnit == "K" {
                return value + 273.15
            } else {
                throw ScientificCalculator.ScientificError.invalidInput
            }
            
        default:
            throw ScientificCalculator.ScientificError.invalidInput
        }
    }
}