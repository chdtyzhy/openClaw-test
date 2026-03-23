//
//  UnitConverter.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import Foundation

/// 单位换算器 - 支持多种单位的精确换算
public class UnitConverter {
    
    // MARK: - 单位类型
    public enum UnitType: String, CaseIterable {
        case length = "长度"
        case weight = "重量"
        case temperature = "温度"
        case area = "面积"
        case volume = "体积"
        case speed = "速度"
        case time = "时间"
        case data = "数据存储"
        case currency = "货币" // 需要网络连接
        
        var description: String {
            return self.rawValue
        }
        
        var iconName: String {
            switch self {
            case .length: return "ruler"
            case .weight: return "scalemass"
            case .temperature: return "thermometer"
            case .area: return "square"
            case .volume: return "cube"
            case .speed: return "speedometer"
            case .time: return "clock"
            case .data: return "internaldrive"
            case .currency: return "dollarsign.circle"
            }
        }
    }
    
    // MARK: - 长度单位
    public enum LengthUnit: String, CaseIterable {
        case meters = "米"
        case kilometers = "千米"
        case centimeters = "厘米"
        case millimeters = "毫米"
        case miles = "英里"
        case yards = "码"
        case feet = "英尺"
        case inches = "英寸"
        case nauticalMiles = "海里"
        
        var conversionFactor: Double {
            switch self {
            case .meters: return 1.0
            case .kilometers: return 1000.0
            case .centimeters: return 0.01
            case .millimeters: return 0.001
            case .miles: return 1609.344
            case .yards: return 0.9144
            case .feet: return 0.3048
            case .inches: return 0.0254
            case .nauticalMiles: return 1852.0
            }
        }
    }
    
    // MARK: - 重量单位
    public enum WeightUnit: String, CaseIterable {
        case kilograms = "千克"
        case grams = "克"
        case milligrams = "毫克"
        case pounds = "磅"
        case ounces = "盎司"
        case tons = "吨"
        case metricTons = "公吨"
        
        var conversionFactor: Double {
            switch self {
            case .kilograms: return 1.0
            case .grams: return 0.001
            case .milligrams: return 0.000001
            case .pounds: return 0.45359237
            case .ounces: return 0.028349523125
            case .tons: return 907.18474
            case .metricTons: return 1000.0
            }
        }
    }
    
    // MARK: - 温度单位
    public enum TemperatureUnit: String, CaseIterable {
        case celsius = "摄氏度"
        case fahrenheit = "华氏度"
        case kelvin = "开尔文"
        
        func convert(_ value: Double, to target: TemperatureUnit) -> Double {
            switch (self, target) {
            case (.celsius, .celsius):
                return value
            case (.celsius, .fahrenheit):
                return value * 9/5 + 32
            case (.celsius, .kelvin):
                return value + 273.15
                
            case (.fahrenheit, .celsius):
                return (value - 32) * 5/9
            case (.fahrenheit, .fahrenheit):
                return value
            case (.fahrenheit, .kelvin):
                return (value - 32) * 5/9 + 273.15
                
            case (.kelvin, .celsius):
                return value - 273.15
            case (.kelvin, .fahrenheit):
                return (value - 273.15) * 9/5 + 32
            case (.kelvin, .kelvin):
                return value
            }
        }
    }
    
    // MARK: - 面积单位
    public enum AreaUnit: String, CaseIterable {
        case squareMeters = "平方米"
        case squareKilometers = "平方千米"
        case squareCentimeters = "平方厘米"
        case squareMillimeters = "平方毫米"
        case hectares = "公顷"
        case acres = "英亩"
        case squareMiles = "平方英里"
        case squareFeet = "平方英尺"
        case squareInches = "平方英寸"
        
        var conversionFactor: Double {
            switch self {
            case .squareMeters: return 1.0
            case .squareKilometers: return 1_000_000.0
            case .squareCentimeters: return 0.0001
            case .squareMillimeters: return 0.000001
            case .hectares: return 10_000.0
            case .acres: return 4046.8564224
            case .squareMiles: return 2_589_988.110336
            case .squareFeet: return 0.09290304
            case .squareInches: return 0.00064516
            }
        }
    }
    
    // MARK: - 公开方法
    
    /// 换算长度
    public func convertLength(_ value: Double, from source: LengthUnit, to target: LengthUnit) -> Double {
        let valueInMeters = value * source.conversionFactor
        return valueInMeters / target.conversionFactor
    }
    
    /// 换算重量
    public func convertWeight(_ value: Double, from source: WeightUnit, to target: WeightUnit) -> Double {
        let valueInKilograms = value * source.conversionFactor
        return valueInKilograms / target.conversionFactor
    }
    
    /// 换算温度
    public func convertTemperature(_ value: Double, from source: TemperatureUnit, to target: TemperatureUnit) -> Double {
        return source.convert(value, to: target)
    }
    
    /// 换算面积
    public func convertArea(_ value: Double, from source: AreaUnit, to target: AreaUnit) -> Double {
        let valueInSquareMeters = value * source.conversionFactor
        return valueInSquareMeters / target.conversionFactor
    }
    
    /// 通用换算方法
    public func convert(_ value: Double, unitType: UnitType, from source: String, to target: String) throws -> Double {
        switch unitType {
        case .length:
            guard let sourceUnit = LengthUnit(rawValue: source),
                  let targetUnit = LengthUnit(rawValue: target) else {
                throw ConversionError.invalidUnit
            }
            return convertLength(value, from: sourceUnit, to: targetUnit)
            
        case .weight:
            guard let sourceUnit = WeightUnit(rawValue: source),
                  let targetUnit = WeightUnit(rawValue: target) else {
                throw ConversionError.invalidUnit
            }
            return convertWeight(value, from: sourceUnit, to: targetUnit)
            
        case .temperature:
            guard let sourceUnit = TemperatureUnit(rawValue: source),
                  let targetUnit = TemperatureUnit(rawValue: target) else {
                throw ConversionError.invalidUnit
            }
            return convertTemperature(value, from: sourceUnit, to: targetUnit)
            
        case .area:
            guard let sourceUnit = AreaUnit(rawValue: source),
                  let targetUnit = AreaUnit(rawValue: target) else {
                throw ConversionError.invalidUnit
            }
            return convertArea(value, from: sourceUnit, to: targetUnit)
            
        default:
            throw ConversionError.unsupportedUnitType
        }
    }
    
    /// 获取所有可用单位
    public func availableUnits(for type: UnitType) -> [String] {
        switch type {
        case .length:
            return LengthUnit.allCases.map { $0.rawValue }
        case .weight:
            return WeightUnit.allCases.map { $0.rawValue }
        case .temperature:
            return TemperatureUnit.allCases.map { $0.rawValue }
        case .area:
            return AreaUnit.allCases.map { $0.rawValue }
        case .volume:
            return ["升", "毫升", "立方米", "立方厘米", "加仑", "品脱"]
        case .speed:
            return ["米/秒", "千米/时", "英里/时", "节"]
        case .time:
            return ["秒", "分钟", "小时", "天", "周", "月", "年"]
        case .data:
            return ["字节", "千字节", "兆字节", "千兆字节", "太字节"]
        case .currency:
            return ["人民币", "美元", "欧元", "日元", "英镑", "港元"]
        }
    }
    
    /// 获取单位类型描述
    public func unitDescription(for type: UnitType) -> String {
        switch type {
        case .length:
            return "长度单位换算"
        case .weight:
            return "重量单位换算"
        case .temperature:
            return "温度单位换算"
        case .area:
            return "面积单位换算"
        case .volume:
            return "体积单位换算"
        case .speed:
            return "速度单位换算"
        case .time:
            return "时间单位换算"
        case .data:
            return "数据存储单位换算"
        case .currency:
            return "货币换算（需要网络）"
        }
    }
    
    // MARK: - 错误类型
    public enum ConversionError: LocalizedError {
        case invalidUnit
        case unsupportedUnitType
        case conversionFailed
        
        public var errorDescription: String? {
            switch self {
            case .invalidUnit:
                return "无效的单位"
            case .unsupportedUnitType:
                return "不支持的单位类型"
            case .conversionFailed:
                return "单位换算失败"
            }
        }
    }
}

// MARK: - 单位换算管理器
public class UnitConversionManager {
    public static let shared = UnitConversionManager()
    
    private let converter = UnitConverter()
    private let logger = Logger(subsystem: "com.calculatorpro.units", category: "UnitConversion")
    
    /// 最近使用的换算记录
    @Published public var recentConversions: [ConversionRecord] = []
    private let maxRecentConversions = 20
    
    /// 用户偏好的单位类型
    @Published public var preferredUnits: [UnitConverter.UnitType: (String, String)] = [:]
    
    public init() {
        loadPreferences()
        logger.info("单位换算管理器已初始化")
    }
    
    /// 执行单位换算
    public func convert(_ value: Double, unitType: UnitConverter.UnitType, from source: String, to target: String) throws -> Double {
        let startTime = Date()
        
        do {
            let result = try converter.convert(value, unitType: unitType, from: source, to: target)
            
            // 记录换算
            let record = ConversionRecord(
                value: value,
                result: result,
                unitType: unitType,
                sourceUnit: source,
                targetUnit: target,
                timestamp: Date()
            )
            
            addRecentConversion(record)
            
            // 记录性能
            let duration = Date().timeIntervalSince(startTime)
            logger.info("单位换算完成: \(value) \(source) → \(result) \(target) (\(duration * 1000)ms)")
            
            return result
            
        } catch {
            logger.error("单位换算失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 添加最近换算记录
    private func addRecentConversion(_ record: ConversionRecord) {
        recentConversions.insert(record, at: 0)
        
        // 限制记录数量
        if recentConversions.count > maxRecentConversions {
            recentConversions.removeLast()
        }
        
        saveRecentConversions()
    }
    
    /// 清除最近换算记录
    public func clearRecentConversions() {
        recentConversions.removeAll()
        saveRecentConversions()
    }
    
    /// 保存用户偏好
    public func savePreference(for unitType: UnitConverter.UnitType, source: String, target: String) {
        preferredUnits[unitType] = (source, target)
        savePreferences()
        logger.info("保存单位偏好: \(unitType.rawValue) - \(source) → \(target)")
    }
    
    /// 获取用户偏好
    public func getPreference(for unitType: UnitConverter.UnitType) -> (String, String)? {
        return preferredUnits[unitType]
    }
    
    // MARK: - 持久化
    
    private func loadPreferences() {
        let defaults = UserDefaults.standard
        
        // 加载最近换算记录
        if let data = defaults.data(forKey: "recentConversions"),
           let records = try? JSONDecoder().decode([ConversionRecord].self, from: data) {
            recentConversions = records
        }
        
        // 加载单位偏好
        if let data = defaults.data(forKey: "unitPreferences"),
           let preferences = try? JSONDecoder().decode([String: [String]].self, from: data) {
            for (key, value) in preferences where value.count == 2 {
                if let unitType = UnitConverter.UnitType(rawValue: key) {
                    preferredUnits[unitType] = (value[0], value[1])
                }
            }
        }
    }
    
    private func saveRecentConversions() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(recentConversions) {
            defaults.set(data, forKey: "recentConversions")
        }
    }
    
    private func savePreferences() {
        let defaults = UserDefaults.standard
        
        // 保存单位偏好
        var preferences: [String: [String]] = [:]
        for (unitType, (source, target)) in preferredUnits {
            preferences[unitType.rawValue] = [source, target]
        }
        
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: "unitPreferences")
        }
    }
}

// MARK: - 数据模型

/// 换算记录
public struct ConversionRecord: Codable, Identifiable {
    public let id = UUID()
    public let value: Double
    public let result: Double
    public let unitType: UnitConverter.UnitType
    public let sourceUnit: String
    public let targetUnit: String
    public let timestamp: Date
    
    public var description: String {
        return "\(value.formatted()) \(sourceUnit) = \(result.formatted()) \(targetUnit)"
    }
}

// MARK: - 扩展

extension Double {
    func formatted(maxFractionDigits: Int = 6) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}