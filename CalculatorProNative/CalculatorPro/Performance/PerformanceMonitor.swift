//
//  PerformanceMonitor.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import Foundation
import QuartzCore
import os

/// 性能监控器 - 确保应用体验达到最高标准
@MainActor
final class PerformanceMonitor: ObservableObject {
    
    // MARK: - 单例实例
    static let shared = PerformanceMonitor()
    
    // MARK: - 性能指标
    @Published private(set) var currentMetrics = PerformanceMetrics()
    @Published private(set) var performanceHistory: [PerformanceMetrics] = []
    @Published private(set) var isPerformanceOptimal = true
    
    // MARK: - 私有属性
    private let logger = Logger(subsystem: "com.calculatorpro.performance", category: "Performance")
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    private var frameCount = 0
    private var lastUpdateTime = Date()
    
    private let metricsQueue = DispatchQueue(label: "com.calculatorpro.performance.metrics", qos: .userInitiated)
    private let historyLimit = 1000 // 保留最近1000条记录
    
    // MARK: - 性能目标
    struct PerformanceTargets {
        static let frameRate: Double = 120.0 // ProMotion目标
        static let frameTime: Double = 1000.0 / frameRate // 每帧时间(ms)
        static let calculationTime: Double = 1.0 // 计算时间目标(ms)
        static let memoryUsage: Double = 25.0 // 内存使用目标(MB)
        static let launchTime: Double = 300.0 // 启动时间目标(ms)
        static let responseTime: Double = 16.0 // 响应时间目标(ms) - 60fps的1帧
    }
    
    // MARK: - 初始化
    private init() {
        setupDisplayLink()
        startMemoryMonitoring()
        logger.info("性能监控器已初始化")
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    // MARK: - 公开方法
    
    /// 开始监控特定计算
    func startCalculationMeasurement(_ name: String) -> CalculationMeasurement {
        return CalculationMeasurement(name: name, monitor: self)
    }
    
    /// 记录计算性能
    func recordCalculation(_ name: String, duration: TimeInterval) {
        metricsQueue.async { [weak self] in
            guard let self = self else { return }
            
            let calculation = CalculationPerformance(
                name: name,
                duration: duration,
                timestamp: Date()
            )
            
            self.currentMetrics.calculations.append(calculation)
            
            // 检查是否达到性能目标
            if duration * 1000 > PerformanceTargets.calculationTime {
                self.logger.warning("计算性能警告: \(name) 耗时 \(duration * 1000)ms，超过目标 \(PerformanceTargets.calculationTime)ms")
                DispatchQueue.main.async {
                    self.isPerformanceOptimal = false
                }
            }
            
            // 限制历史记录数量
            if self.currentMetrics.calculations.count > 100 {
                self.currentMetrics.calculations.removeFirst(50)
            }
        }
    }
    
    /// 记录用户交互
    func recordUserInteraction(_ interaction: UserInteraction) {
        metricsQueue.async { [weak self] in
            guard let self = self else { return }
            self.currentMetrics.userInteractions.append(interaction)
            
            // 计算响应时间
            if let lastInteraction = self.currentMetrics.userInteractions.last(where: { $0.type == interaction.type }) {
                let responseTime = interaction.timestamp.timeIntervalSince(lastInteraction.timestamp)
                if responseTime * 1000 > PerformanceTargets.responseTime {
                    self.logger.warning("响应时间警告: \(interaction.type) 响应时间 \(responseTime * 1000)ms")
                }
            }
            
            // 限制历史记录数量
            if self.currentMetrics.userInteractions.count > 200 {
                self.currentMetrics.userInteractions.removeFirst(100)
            }
        }
    }
    
    /// 获取性能报告
    func generatePerformanceReport() -> PerformanceReport {
        metricsQueue.sync {
            let report = PerformanceReport(
                timestamp: Date(),
                metrics: currentMetrics,
                history: performanceHistory.suffix(100),
                recommendations: generateRecommendations()
            )
            return report
        }
    }
    
    /// 重置性能数据
    func reset() {
        metricsQueue.async { [weak self] in
            guard let self = self else { return }
            self.currentMetrics = PerformanceMetrics()
            self.performanceHistory.removeAll()
            DispatchQueue.main.async {
                self.isPerformanceOptimal = true
            }
            self.logger.info("性能数据已重置")
        }
    }
    
    // MARK: - 私有方法
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrameRate))
        displayLink?.add(to: .main, forMode: .common)
        lastFrameTime = CACurrentMediaTime()
    }
    
    @objc private func updateFrameRate() {
        let currentTime = CACurrentMediaTime()
        frameCount += 1
        
        // 每秒更新一次帧率
        if currentTime - lastUpdateTime >= 1.0 {
            let fps = Double(frameCount) / (currentTime - lastUpdateTime)
            
            metricsQueue.async { [weak self] in
                guard let self = self else { return }
                
                self.currentMetrics.frameRate = fps
                self.currentMetrics.frameTime = 1000.0 / fps
                
                // 检查帧率是否达标
                if fps < PerformanceTargets.frameRate * 0.9 { // 允许10%的误差
                    self.logger.warning("帧率警告: 当前 \(fps)fps，目标 \(PerformanceTargets.frameRate)fps")
                    DispatchQueue.main.async {
                        self.isPerformanceOptimal = false
                    }
                }
                
                // 保存到历史记录
                self.performanceHistory.append(self.currentMetrics.copy())
                if self.performanceHistory.count > self.historyLimit {
                    self.performanceHistory.removeFirst(self.historyLimit / 2)
                }
            }
            
            frameCount = 0
            lastUpdateTime = currentTime
        }
        
        lastFrameTime = currentTime
    }
    
    private func startMemoryMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func updateMemoryUsage() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
        
        let kerr = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryUsage = Double(taskInfo.resident_size) / 1024.0 / 1024.0 // 转换为MB
            
            metricsQueue.async { [weak self] in
                guard let self = self else { return }
                self.currentMetrics.memoryUsage = memoryUsage
                
                if memoryUsage > PerformanceTargets.memoryUsage {
                    self.logger.warning("内存使用警告: 当前 \(memoryUsage)MB，目标 \(PerformanceTargets.memoryUsage)MB")
                    DispatchQueue.main.async {
                        self.isPerformanceOptimal = false
                    }
                }
            }
        }
    }
    
    private func generateRecommendations() -> [PerformanceRecommendation] {
        var recommendations: [PerformanceRecommendation] = []
        
        // 分析性能数据并生成建议
        if currentMetrics.frameRate < PerformanceTargets.frameRate * 0.9 {
            recommendations.append(.init(
                type: .frameRate,
                severity: .warning,
                message: "帧率低于目标值，建议优化UI渲染",
                suggestion: "检查SwiftUI视图层次，使用LazyVStack/LazyHStack，减少不必要的视图更新"
            ))
        }
        
        if currentMetrics.memoryUsage > PerformanceTargets.memoryUsage {
            recommendations.append(.init(
                type: .memory,
                severity: .warning,
                message: "内存使用超过目标值",
                suggestion: "检查内存泄漏，使用Instruments分析内存使用，优化图像资源"
            ))
        }
        
        // 分析计算性能
        let slowCalculations = currentMetrics.calculations.filter { $0.duration * 1000 > PerformanceTargets.calculationTime }
        if !slowCalculations.isEmpty {
            recommendations.append(.init(
                type: .calculation,
                severity: .info,
                message: "发现\(slowCalculations.count)个较慢的计算",
                suggestion: "考虑使用SIMD向量化计算或Metal加速"
            ))
        }
        
        return recommendations
    }
}

// MARK: - 性能测量包装器
struct CalculationMeasurement {
    let name: String
    let monitor: PerformanceMonitor
    private let startTime: Date
    
    init(name: String, monitor: PerformanceMonitor) {
        self.name = name
        self.monitor = monitor
        self.startTime = Date()
    }
    
    func end() {
        let duration = Date().timeIntervalSince(startTime)
        monitor.recordCalculation(name, duration: duration)
    }
}

// MARK: - 数据模型

struct PerformanceMetrics: Codable {
    var timestamp = Date()
    var frameRate: Double = 0
    var frameTime: Double = 0
    var memoryUsage: Double = 0
    var calculations: [CalculationPerformance] = []
    var userInteractions: [UserInteraction] = []
    
    func copy() -> PerformanceMetrics {
        var copy = PerformanceMetrics()
        copy.timestamp = timestamp
        copy.frameRate = frameRate
        copy.frameTime = frameTime
        copy.memoryUsage = memoryUsage
        copy.calculations = calculations
        copy.userInteractions = userInteractions
        return copy
    }
}

struct CalculationPerformance: Codable {
    let name: String
    let duration: TimeInterval
    let timestamp: Date
}

struct UserInteraction: Codable {
    enum InteractionType: String, Codable {
        case buttonPress = "按钮按下"
        case swipe = "滑动"
        case tap = "轻点"
        case longPress = "长按"
        case calculation = "计算"
    }
    
    let type: InteractionType
    let element: String
    let timestamp: Date
}

struct PerformanceReport: Codable {
    let timestamp: Date
    let metrics: PerformanceMetrics
    let history: [PerformanceMetrics]
    let recommendations: [PerformanceRecommendation]
    
    var summary: String {
        """
        性能报告 - \(timestamp.formatted())
        
        当前状态:
        • 帧率: \(String(format: "%.1f", metrics.frameRate))fps
        • 帧时间: \(String(format: "%.1f", metrics.frameTime))ms
        • 内存使用: \(String(format: "%.1f", metrics.memoryUsage))MB
        • 最近计算次数: \(metrics.calculations.count)
        • 用户交互次数: \(metrics.userInteractions.count)
        
        性能建议 (\(recommendations.count)条):
        \(recommendations.map { "• \($0.message)" }.joined(separator: "\n"))
        """
    }
}

struct PerformanceRecommendation: Codable {
    enum RecommendationType: String, Codable {
        case frameRate = "帧率"
        case memory = "内存"
        case calculation = "计算性能"
        case battery = "电池"
        case startup = "启动时间"
    }
    
    enum Severity: String, Codable {
        case info = "信息"
        case warning = "警告"
        case critical = "严重"
    }
    
    let type: RecommendationType
    let severity: Severity
    let message: String
    let suggestion: String
}