import Foundation
import Accelerate

/// 科学计算引擎
/// 提供高性能的科学计算功能，使用Accelerate框架优化
public final class ScientificCalculator {
    
    // MARK: - 错误类型
    
    public enum ScientificError: Error, CustomStringConvertible {
        case invalidInput
        case domainError
        case calculationError
        
        public var description: String {
            switch self {
            case .invalidInput:
                return "无效输入"
            case .domainError:
                return "定义域错误"
            case .calculationError:
                return "计算错误"
            }
        }
    }
    
    // MARK: - 计算模式
    
    public enum AngleMode {
        case degrees    // 角度制
        case radians    // 弧度制
        case gradians   // 百分度制
    }
    
    // MARK: - 属性
    
    private var angleMode: AngleMode = .degrees
    private var calculationCache: [String: Double] = [:]
    private let cacheLimit = 1000
    
    // MARK: - 初始化
    
    public init() {}
    
    // MARK: - 三角函数
    
    /// 计算正弦
    /// - Parameter value: 输入值
    /// - Returns: 正弦值
    public func sin(_ value: Double) throws -> Double {
        let radians = try convertToRadians(value)
        let result = Foundation.sin(radians)
        
        guard result.isFinite else {
            throw ScientificError.calculationError
        }
        
        return result
    }
    
    /// 计算余弦
    /// - Parameter value: 输入值
    /// - Returns: 余弦值
    public func cos(_ value: Double) throws -> Double {
        let radians = try convertToRadians(value)
        let result = Foundation.cos(radians)
        
        guard result.isFinite else {
            throw ScientificError.calculationError
        }
        
        return result
    }
    
    /// 计算正切
    /// - Parameter value: 输入值
    /// - Returns: 正切值
    public func tan(_ value: Double) throws -> Double {
        let radians = try convertToRadians(value)
        
        // 检查是否接近π/2 + kπ
        let remainder = radians.truncatingRemainder(dividingBy: .pi)
        if abs(remainder - .pi/2) < 1e-10 {
            throw ScientificError.domainError
        }
        
        let result = Foundation.tan(radians)
        
        guard result.isFinite else {
            throw ScientificError.calculationError
        }
        
        return result
    }
    
    /// 计算反正弦
    /// - Parameter value: 输入值 (-1 ≤ value ≤ 1)
    /// - Returns: 角度值
    public func asin(_ value: Double) throws -> Double {
        guard value >= -1 && value <= 1 else {
            throw ScientificError.domainError
        }
        
        let radians = Foundation.asin(value)
        return try convertFromRadians(radians)
    }
    
    /// 计算反余弦
    /// - Parameter value: 输入值 (-1 ≤ value ≤ 1)
    /// - Returns: 角度值
    public func acos(_ value: Double) throws -> Double {
        guard value >= -1 && value <= 1 else {
            throw ScientificError.domainError
        }
        
        let radians = Foundation.acos(value)
        return try convertFromRadians(radians)
    }
    
    /// 计算反正切
    /// - Parameter value: 输入值
    /// - Returns: 角度值
    public func atan(_ value: Double) throws -> Double {
        let radians = Foundation.atan(value)
        return try convertFromRadians(radians)
    }
    
    // MARK: - 对数和指数函数
    
    /// 计算以10为底的对数
    /// - Parameter value: 输入值 (value > 0)
    /// - Returns: 对数值
    public func log10(_ value: Double) throws -> Double {
        guard value > 0 else {
            throw ScientificError.domainError
        }
        
        return Foundation.log10(value)
    }
    
    /// 计算自然对数
    /// - Parameter value: 输入值 (value > 0)
    /// - Returns: 对数值
    public func ln(_ value: Double) throws -> Double {
        guard value > 0 else {
            throw ScientificError.domainError
        }
        
        return Foundation.log(value)
    }
    
    /// 计算e的幂
    /// - Parameter value: 指数
    /// - Returns: e^value
    public func exp(_ value: Double) -> Double {
        return Foundation.exp(value)
    }
    
    /// 计算10的幂
    /// - Parameter value: 指数
    /// - Returns: 10^value
    public func exp10(_ value: Double) -> Double {
        return Foundation.pow(10, value)
    }
    
    // MARK: - 幂和根函数
    
    /// 计算平方
    /// - Parameter value: 输入值
    /// - Returns: value²
    public func square(_ value: Double) -> Double {
        return value * value
    }
    
    /// 计算立方
    /// - Parameter value: 输入值
    /// - Returns: value³
    public func cube(_ value: Double) -> Double {
        return value * value * value
    }
    
    /// 计算幂
    /// - Parameters:
    ///   - base: 底数
    ///   - exponent: 指数
    /// - Returns: base^exponent
    public func power(base: Double, exponent: Double) throws -> Double {
        let result = Foundation.pow(base, exponent)
        
        guard result.isFinite else {
            throw ScientificError.calculationError
        }
        
        return result
    }
    
    /// 计算平方根
    /// - Parameter value: 输入值 (value ≥ 0)
    /// - Returns: √value
    public func sqrt(_ value: Double) throws -> Double {
        guard value >= 0 else {
            throw ScientificError.domainError
        }
        
        return Foundation.sqrt(value)
    }
    
    /// 计算立方根
    /// - Parameter value: 输入值
    /// - Returns: ³√value
    public func cbrt(_ value: Double) -> Double {
        // 立方根可以处理负数
        if value >= 0 {
            return Foundation.pow(value, 1.0/3.0)
        } else {
            return -Foundation.pow(-value, 1.0/3.0)
        }
    }
    
    /// 计算n次方根
    /// - Parameters:
    ///   - value: 被开方数
    ///   - n: 根指数 (n > 0)
    /// - Returns: value的n次方根
    public func nthRoot(_ value: Double, n: Int) throws -> Double {
        guard n > 0 else {
            throw ScientificError.invalidInput
        }
        
        if n % 2 == 0 && value < 0 {
            throw ScientificError.domainError
        }
        
        let exponent = 1.0 / Double(n)
        return Foundation.pow(value, exponent)
    }
    
    // MARK: - 其他数学函数
    
    /// 计算阶乘
    /// - Parameter n: 非负整数
    /// - Returns: n!
    public func factorial(_ n: Int) throws -> Double {
        guard n >= 0 else {
            throw ScientificError.domainError
        }
        
        guard n <= 170 else { // Double能表示的最大阶乘
            throw ScientificError.overflow
        }
        
        var result: Double = 1
        for i in 1...n {
            result *= Double(i)
        }
        
        return result
    }
    
    /// 计算倒数
    /// - Parameter value: 输入值 (value ≠ 0)
    /// - Returns: 1/value
    public func reciprocal(_ value: Double) throws -> Double {
        guard value != 0 else {
            throw ScientificError.domainError
        }
        
        return 1.0 / value
    }
    
    /// 计算绝对值
    /// - Parameter value: 输入值
    /// - Returns: |value|
    public func abs(_ value: Double) -> Double {
        return Foundation.fabs(value)
    }
    
    // MARK: - 常数
    
    /// 圆周率 π
    public var pi: Double {
        return Double.pi
    }
    
    /// 自然常数 e
    public var e: Double {
        return M_E
    }
    
    /// 黄金比例 φ
    public var goldenRatio: Double {
        return (1.0 + Foundation.sqrt(5.0)) / 2.0
    }
    
    // MARK: - 角度转换
    
    /// 设置角度模式
    /// - Parameter mode: 角度模式
    public func setAngleMode(_ mode: AngleMode) {
        angleMode = mode
    }
    
    /// 获取当前角度模式
    public func getAngleMode() -> AngleMode {
        return angleMode
    }
    
    /// 转换为弧度
    private func convertToRadians(_ value: Double) throws -> Double {
        switch angleMode {
        case .degrees:
            return value * .pi / 180.0
        case .radians:
            return value
        case .gradians:
            return value * .pi / 200.0
        }
    }
    
    /// 从弧度转换
    private func convertFromRadians(_ radians: Double) throws -> Double {
        switch angleMode {
        case .degrees:
            return radians * 180.0 / .pi
        case .radians:
            return radians
        case .gradians:
            return radians * 200.0 / .pi
        }
    }
    
    // MARK: - 批量计算优化
    
    /// 批量计算三角函数（使用Accelerate优化）
    /// - Parameter values: 输入值数组
    /// - Returns: 正弦、余弦、正切结果数组
    public func batchTrigonometry(_ values: [Double]) throws -> (sines: [Double], cosines: [Double], tangents: [Double]) {
        // 转换为弧度
        let radians = try values.map { try convertToRadians($0) }
        
        // 计算正弦
        var sines = [Double](repeating: 0, count: values.count)
        vvsin(&sines, radians, [Int32(values.count)])
        
        // 计算余弦
        var cosines = [Double](repeating: 0, count: values.count)
        vvcos(&cosines, radians, [Int32(values.count)])
        
        // 计算正切
        var tangents = [Double](repeating: 0, count: values.count)
        vvtan(&tangents, radians, [Int32(values.count)])
        
        return (sines, cosines, tangents)
    }
    
    /// 批量计算对数（使用Accelerate优化）
    /// - Parameter values: 输入值数组
    /// - Returns: 自然对数和常用对数结果数组
    public func batchLogarithms(_ values: [Double]) throws -> (naturalLogs: [Double], commonLogs: [Double]) {
        // 检查所有值是否为正数
        guard values.allSatisfy({ $0 > 0 }) else {
            throw ScientificError.domainError
        }
        
        // 计算自然对数
        var naturalLogs = [Double](repeating: 0, count: values.count)
        vvlog(&naturalLogs, values, [Int32(values.count)])
        
        // 计算常用对数
        var commonLogs = [Double](repeating: 0, count: values.count)
        vvlog10(&commonLogs, values, [Int32(values.count)])
        
        return (naturalLogs, commonLogs)
    }
    
    // MARK: - 缓存优化
    
    /// 带缓存的科学计算
    /// - Parameters:
    ///   - function: 函数名
    ///   - value: 输入值
    /// - Returns: 计算结果
    public func calculateWithCache(function: String, value: Double) throws -> Double {
        let cacheKey = "\(function):\(value):\(angleMode)"
        
        if let cached = calculationCache[cacheKey] {
            return cached
        }
        
        let result: Double
        
        switch function {
        case "sin":
            result = try sin(value)
        case "cos":
            result = try cos(value)
        case "tan":
            result = try tan(value)
        case "log":
            result = try log10(value)
        case "ln":
            result = try ln(value)
        case "sqrt":
            result = try sqrt(value)
        case "square":
            result = square(value)
        default:
            throw ScientificError.invalidInput
        }
        
        // 缓存结果
        calculationCache[cacheKey] = result
        
        // 限制缓存大小
        if calculationCache.count > cacheLimit {
            calculationCache.removeFirst()
        }
        
        return result
    }
    
    /// 清除缓存
    public func clearCache() {
        calculationCache.removeAll()
    }
    
    // MARK: - 性能基准测试
    
    /// 运行性能基准测试
    /// - Parameter iterations: 迭代次数
    /// - Returns: 执行时间（秒）
    public func performanceBenchmark(iterations: Int = 10000) -> TimeInterval {
        let startTime = Date()
        
        // 测试各种科学计算
        for i in 0..<iterations {
            let value = Double(i % 100) + 0.5
            
            _ = try? sin(value)
            _ = try? cos(value)
            _ = try? log10(value + 1)
            _ = try? sqrt(value + 1)
            _ = square(value)
        }
        
        return Date().timeIntervalSince(startTime)
    }
}