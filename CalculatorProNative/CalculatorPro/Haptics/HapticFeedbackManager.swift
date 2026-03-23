//
//  HapticFeedbackManager.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import UIKit
import CoreHaptics

/// 触觉反馈管理器 - 提供丰富的物理反馈体验
@MainActor
final class HapticFeedbackManager: ObservableObject {
    
    // MARK: - 单例实例
    static let shared = HapticFeedbackManager()
    
    // MARK: - 发布属性
    @Published private(set) var isEnabled = true
    @Published private(set) var intensity: HapticIntensity = .medium
    @Published private(set) var isCoreHapticsAvailable = false
    
    // MARK: - 私有属性
    private var engine: CHHapticEngine?
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private let logger = Logger(subsystem: "com.calculatorpro.haptics", category: "Haptics")
    
    // MARK: - 反馈类型
    enum HapticType {
        // 按钮反馈
        case buttonPress
        case buttonRelease
        case buttonError
        
        // 计算反馈
        case calculationStart
        case calculationSuccess
        case calculationError
        
        // 模式切换
        case modeChange
        case themeChange
        
        // 导航反馈
        case tabSwitch
        case swipe
        
        // 系统反馈
        case success
        case warning
        case error
        
        // 自定义强度
        case custom(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat)
    }
    
    enum HapticIntensity: CGFloat, CaseIterable {
        case light = 0.3
        case medium = 0.6
        case heavy = 0.9
        
        var description: String {
            switch self {
            case .light: return "轻柔"
            case .medium: return "适中"
            case .heavy: return "强烈"
            }
        }
    }
    
    // MARK: - 初始化
    private init() {
        setupCoreHaptics()
        loadSettings()
        prepareGenerators()
        
        logger.info("触觉反馈管理器已初始化，Core Haptics可用: \(isCoreHapticsAvailable)")
    }
    
    deinit {
        stopEngine()
    }
    
    // MARK: - 公开方法
    
    /// 触发触觉反馈
    func trigger(_ type: HapticType) {
        guard isEnabled else { return }
        
        switch type {
        case .buttonPress:
            triggerButtonPress()
        case .buttonRelease:
            triggerButtonRelease()
        case .buttonError:
            triggerButtonError()
        case .calculationStart:
            triggerCalculationStart()
        case .calculationSuccess:
            triggerCalculationSuccess()
        case .calculationError:
            triggerCalculationError()
        case .modeChange:
            triggerModeChange()
        case .themeChange:
            triggerThemeChange()
        case .tabSwitch:
            triggerTabSwitch()
        case .swipe:
            triggerSwipe()
        case .success:
            triggerSuccess()
        case .warning:
            triggerWarning()
        case .error:
            triggerError()
        case .custom(let style, let intensity):
            triggerCustom(style: style, intensity: intensity)
        }
        
        // 记录用户交互
        PerformanceMonitor.shared.recordUserInteraction(.init(
            type: .buttonPress,
            element: "haptic_\(type)",
            timestamp: Date()
        ))
    }
    
    /// 启用或禁用触觉反馈
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        saveSettings()
        
        if enabled {
            prepareGenerators()
            logger.info("触觉反馈已启用")
        } else {
            logger.info("触觉反馈已禁用")
        }
    }
    
    /// 设置反馈强度
    func setIntensity(_ intensity: HapticIntensity) {
        self.intensity = intensity
        saveSettings()
        logger.info("触觉反馈强度设置为: \(intensity.description)")
    }
    
    /// 预加载反馈生成器（减少首次触发的延迟）
    func prepareGenerators() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - 私有方法
    
    private func setupCoreHaptics() {
        // 检查设备是否支持Core Haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            logger.info("设备不支持Core Haptics")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            
            // 配置引擎
            engine?.playsHapticsOnly = true
            engine?.isAutoShutdownEnabled = true
            
            // 设置停止处理程序
            engine?.stoppedHandler = { [weak self] reason in
                self?.logger.warning("Core Haptics引擎停止: \(reason)")
                self?.isCoreHapticsAvailable = false
            }
            
            // 设置重置处理程序
            engine?.resetHandler = { [weak self] in
                self?.logger.info("Core Haptics引擎重置")
                self?.startEngine()
            }
            
            // 启动引擎
            startEngine()
            isCoreHapticsAvailable = true
            
            logger.info("Core Haptics引擎初始化成功")
            
        } catch {
            logger.error("Core Haptics引擎初始化失败: \(error.localizedDescription)")
            isCoreHapticsAvailable = false
        }
    }
    
    private func startEngine() {
        do {
            try engine?.start()
            logger.info("Core Haptics引擎已启动")
        } catch {
            logger.error("启动Core Haptics引擎失败: \(error.localizedDescription)")
        }
    }
    
    private func stopEngine() {
        engine?.stop()
        logger.info("Core Haptics引擎已停止")
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isEnabled = defaults.bool(forKey: "hapticFeedbackEnabled")
        
        if let intensityRaw = defaults.string(forKey: "hapticFeedbackIntensity"),
           let intensityValue = Double(intensityRaw),
           let intensity = HapticIntensity(rawValue: CGFloat(intensityValue)) {
            self.intensity = intensity
        } else {
            intensity = .medium
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isEnabled, forKey: "hapticFeedbackEnabled")
        defaults.set(intensity.rawValue.description, forKey: "hapticFeedbackIntensity")
    }
    
    // MARK: - 具体反馈实现
    
    private func triggerButtonPress() {
        if isCoreHapticsAvailable {
            triggerCoreHapticButtonPress()
        } else {
            impactGenerator.impactOccurred(intensity: intensity.rawValue)
        }
    }
    
    private func triggerButtonRelease() {
        selectionGenerator.selectionChanged()
    }
    
    private func triggerButtonError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    private func triggerCalculationStart() {
        impactGenerator.impactOccurred(style: .medium, intensity: intensity.rawValue * 0.8)
    }
    
    private func triggerCalculationSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    private func triggerCalculationError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    private func triggerModeChange() {
        selectionGenerator.selectionChanged()
    }
    
    private func triggerThemeChange() {
        impactGenerator.impactOccurred(style: .soft, intensity: intensity.rawValue * 0.5)
    }
    
    private func triggerTabSwitch() {
        selectionGenerator.selectionChanged()
    }
    
    private func triggerSwipe() {
        impactGenerator.impactOccurred(style: .light, intensity: intensity.rawValue * 0.3)
    }
    
    private func triggerSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    private func triggerWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    private func triggerError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    private func triggerCustom(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    // MARK: - Core Haptics高级反馈
    
    private func triggerCoreHapticButtonPress() {
        guard let engine = engine else { return }
        
        do {
            // 创建按钮按下的触觉模式
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity.rawValue))
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensityParam],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            
            try player.start(atTime: 0)
            
        } catch {
            logger.error("Core Haptics按钮反馈失败: \(error.localizedDescription)")
            // 回退到传统反馈
            impactGenerator.impactOccurred(intensity: intensity.rawValue)
        }
    }
    
    private func triggerCoreHapticCalculationSuccess() {
        guard let engine = engine else { return }
        
        do {
            // 创建计算成功的复杂触觉模式
            var events: [CHHapticEvent] = []
            
            // 第一个脉冲：快速上升
            let riseSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            let riseIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [riseSharpness, riseIntensity],
                relativeTime: 0
            ))
            
            // 第二个脉冲：主反馈
            let mainSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let mainIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity.rawValue))
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [mainSharpness, mainIntensity],
                relativeTime: 0.05
            ))
            
            // 第三个脉冲：衰减
            let decaySharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            let decayIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.1)
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [decaySharpness, decayIntensity],
                relativeTime: 0.1
            ))
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            
            try player.start(atTime: 0)
            
        } catch {
            logger.error("Core Haptics计算成功反馈失败: \(error.localizedDescription)")
            notificationGenerator.notificationOccurred(.success)
        }
    }
}

// MARK: - 视图修饰器
struct HapticFeedbackModifier: ViewModifier {
    let type: HapticFeedbackManager.HapticType
    let condition: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: condition) { oldValue, newValue in
                if newValue {
                    HapticFeedbackManager.shared.trigger(type)
                }
            }
    }
}

extension View {
    /// 添加触觉反馈修饰器
    func hapticFeedback(_ type: HapticFeedbackManager.HapticType, condition: Bool) -> some View {
        modifier(HapticFeedbackModifier(type: type, condition: condition))
    }
    
    /// 按钮按下触觉反馈
    func buttonHapticFeedback(isPressed: Bool) -> some View {
        hapticFeedback(.buttonPress, condition: isPressed)
    }
}

// MARK: - 使用示例
/*
 // 在按钮中使用
 Button("计算") {
     // 计算逻辑
 }
 .buttonHapticFeedback(isPressed: true)
 
 // 在状态变化中使用
 .onChange(of: isDarkMode) { oldValue, newValue in
     HapticFeedbackManager.shared.trigger(.themeChange)
 }
 
 // 在计算完成时使用
 HapticFeedbackManager.shared.trigger(.calculationSuccess)
 */