//
//  CalculatorOCWrapper.swift
//  CalculatorPro
//
//  Swift 包装器，用于调用 Objective-C 计算器功能
//

import Foundation

class CalculatorOCWrapper {
    private let calculatorOC: CalculatorOC
    
    init() {
        calculatorOC = CalculatorOC()
    }
    
    // MARK: - 基本计算
    func add(_ a: Double, _ b: Double) -> Double {
        return calculatorOC.add(a, to: b)
    }
    
    func subtract(_ a: Double, _ b: Double) -> Double {
        return calculatorOC.subtract(a, from: b)
    }
    
    func multiply(_ a: Double, _ b: Double) -> Double {
        return calculatorOC.multiply(a, by: b)
    }
    
    func divide(_ a: Double, _ b: Double) -> Double {
        return calculatorOC.divide(a, by: b)
    }
    
    func percentage(_ value: Double, of total: Double) -> Double {
        return calculatorOC.percentage(value, of: total)
    }
    
    // MARK: - 高级计算
    func squareRoot(_ value: Double) -> Double {
        return calculatorOC.squareRoot(value)
    }
    
    func power(base: Double, exponent: Double) -> Double {
        return calculatorOC.power(base, exponent: exponent)
    }
    
    func sin(angle: Double) -> Double {
        return calculatorOC.sin(angle)
    }
    
    func cos(angle: Double) -> Double {
        return calculatorOC.cos(angle)
    }
    
    func tan(angle: Double) -> Double {
        return calculatorOC.tan(angle)
    }
    
    // MARK: - 内存功能
    func memoryStore(_ value: Double) {
        calculatorOC.memoryStore(value)
    }
    
    func memoryRecall() -> Double {
        return calculatorOC.memoryRecall()
    }
    
    func memoryClear() {
        calculatorOC.memoryClear()
    }
    
    func memoryAdd(_ value: Double) {
        calculatorOC.memoryAdd(value)
    }
    
    func memorySubtract(_ value: Double) {
        calculatorOC.memorySubtract(value)
    }
    
    // MARK: - 表达式计算
    func evaluateExpression(_ expression: String) -> Result<Double, Error> {
        var error: NSError?
        let result = calculatorOC.evaluateExpression(expression, error: &error)
        
        if let error = error {
            return .failure(error)
        } else if result.isNaN {
            return .failure(NSError(domain: "CalculatorError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "无效的计算结果"]))
        } else {
            return .success(result)
        }
    }
    
    // MARK: - 格式化
    func formatNumber(_ number: Double) -> String {
        return calculatorOC.formatNumber(number)
    }
    
    func formatNumber(_ number: Double, decimalPlaces: Int) -> String {
        return calculatorOC.formatNumber(number, withDecimalPlaces: Int32(decimalPlaces))
    }
    
    // MARK: - 单位转换
    func convertCurrency(_ amount: Double, from: String, to: String) -> Double {
        return calculatorOC.convertCurrency(amount, from: from, to: to)
    }
    
    func convertLength(_ length: Double, from: String, to: String) -> Double {
        return calculatorOC.convertLength(length, from: from, to: to)
    }
    
    func convertWeight(_ weight: Double, from: String, to: String) -> Double {
        return calculatorOC.convertWeight(weight, from: from, to: to)
    }
}

// MARK: - 历史记录管理器包装器
class HistoryManagerOCWrapper {
    private let historyManager: HistoryManagerOC
    
    init(maxHistoryCount: Int = 100) {
        historyManager = HistoryManagerOC(maxHistoryCount: Int32(maxHistoryCount))
    }
    
    // MARK: - 历史记录管理
    var historyItems: [HistoryItemOC] {
        return historyManager.historyItems
    }
    
    var maxHistoryCount: Int {
        get { return Int(historyManager.maxHistoryCount) }
        set { historyManager.maxHistoryCount = Int32(newValue) }
    }
    
    func addHistoryItem(expression: String, result: String, category: String = "general") {
        let item = HistoryItemOC(expression: expression, result: result, category: category)
        historyManager.addHistoryItem(item)
    }
    
    func clearAllHistory() {
        historyManager.clearAllHistory()
    }
    
    func removeHistoryItem(at index: Int) {
        historyManager.removeHistoryItemAtIndex(Int32(index))
    }
    
    // MARK: - 查询
    func historyItems(for category: String) -> [HistoryItemOC] {
        return historyManager.historyItemsForCategory(category)
    }
    
    func historyItems(containing text: String) -> [HistoryItemOC] {
        return historyManager.historyItemsContainingText(text)
    }
    
    func historyItems(from startDate: Date, to endDate: Date) -> [HistoryItemOC] {
        return historyManager.historyItemsFromDate(startDate, toDate: endDate)
    }
    
    // MARK: - 持久化
    func saveHistoryToUserDefaults(key: String = "calculatorHistory") -> Bool {
        return historyManager.saveHistoryToUserDefaultsWithKey(key)
    }
    
    func loadHistoryFromUserDefaults(key: String = "calculatorHistory") -> Bool {
        return historyManager.loadHistoryFromUserDefaultsWithKey(key)
    }
    
    // MARK: - 导出导入
    func exportHistoryToJSON() -> String {
        return historyManager.exportHistoryToJSONString()
    }
    
    func importHistoryFromJSON(_ jsonString: String) -> Bool {
        return historyManager.importHistoryFromJSONString(jsonString)
    }
    
    // MARK: - 统计
    var totalHistoryCount: Int {
        return Int(historyManager.totalHistoryCount)
    }
    
    func historyCount(for category: String) -> Int {
        return Int(historyManager.historyCountForCategory(category))
    }
    
    var categoryStatistics: [String: Int] {
        let stats = historyManager.categoryStatistics
        var result: [String: Int] = [:]
        
        for (key, value) in stats {
            result[key] = value.intValue
        }
        
        return result
    }
    
    var oldestHistoryDate: Date? {
        return historyManager.oldestHistoryDate
    }
    
    var newestHistoryDate: Date? {
        return historyManager.newestHistoryDate
    }
}