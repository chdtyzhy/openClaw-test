//
//  AnimationSystem.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

/// 动画系统 - 提供流畅、一致的动画体验
struct AnimationSystem {
    
    // MARK: - 动画时长
    struct Duration {
        /// 极快动画: 用于即时反馈 (50ms)
        static let ultrafast: Double = 0.05
        /// 快速动画: 用于按钮交互 (100ms)
        static let fast: Double = 0.1
        /// 标准动画: 用于一般过渡 (200ms)
        static let standard: Double = 0.2
        /// 平滑动画: 用于模式切换 (300ms)
        static let smooth: Double = 0.3
        /// 舒缓动画: 用于页面过渡 (500ms)
        static let relaxed: Double = 0.5
    }
    
    // MARK: - 缓动函数
    struct Easing {
        /// 线性缓动: 匀速运动
        static let linear = Animation.linear
        
        /// 标准缓动: 轻微加速和减速
        static let standard = Animation.easeInOut(duration: Duration.standard)
        
        /// 弹性缓动: 有弹性的效果
        static func spring(response: Double = 0.3, dampingFraction: Double = 0.7) -> Animation {
            .spring(response: response, dampingFraction: dampingFraction)
        }
        
        /// 按钮按下缓动: 快速按下，缓慢释放
        static let buttonPress = Animation.spring(response: 0.2, dampingFraction: 0.6)
        
        /// 按钮释放缓动: 有弹性的释放效果
        static let buttonRelease = Animation.spring(response: 0.3, dampingFraction: 0.7)
        
        /// 模式切换缓动: 平滑过渡
        static let modeSwitch = Animation.easeInOut(duration: Duration.smooth)
        
        /// 结果显示缓动: 数字滚动效果
        static let resultDisplay = Animation.spring(response: 0.4, dampingFraction: 0.8)
        
        /// 错误提示缓动: 震动效果
        static let errorShake = Animation.spring(response: 0.1, dampingFraction: 0.3)
    }
    
    // MARK: - 预定义动画
    
    /// 按钮按下动画
    static let buttonPress = Easing.buttonPress
    
    /// 按钮释放动画
    static let buttonRelease = Easing.buttonRelease
    
    /// 模式切换动画
    static let modeSwitch = Easing.modeSwitch
    
    /// 结果显示动画
    static let resultDisplay = Easing.resultDisplay
    
    /// 错误震动动画
    static let errorShake = Easing.errorShake
    
    /// 淡入动画
    static let fadeIn = Animation.easeIn(duration: Duration.standard)
    
    /// 淡出动画
    static let fadeOut = Animation.easeOut(duration: Duration.fast)
    
    /// 缩放动画
    static let scale = Easing.spring(response: 0.3, dampingFraction: 0.7)
    
    /// 滑动动画
    static let slide = Animation.easeInOut(duration: Duration.smooth)
}

// MARK: - 动画修饰器
struct AnimatedButtonModifier: ViewModifier {
    let isPressed: Bool
    let scaleEffect: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scaleEffect : 1.0)
            .animation(AnimationSystem.buttonPress, value: isPressed)
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    init(isShaking: Bool) {
        animatableData = isShaking ? 1 : 0
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct ShakeModifier: ViewModifier {
    let isShaking: Bool
    
    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(isShaking: isShaking))
            .animation(AnimationSystem.errorShake, value: isShaking)
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    let scale: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

struct NumberRollAnimation: ViewModifier {
    let value: String
    let oldValue: String
    @State private var animatedValue: String = ""
    
    func body(content: Content) -> some View {
        Text(animatedValue)
            .onAppear {
                animatedValue = oldValue
                animateToNewValue()
            }
            .onChange(of: value) { oldValue, newValue in
                animateToNewValue()
            }
    }
    
    private func animateToNewValue() {
        withAnimation(AnimationSystem.resultDisplay) {
            animatedValue = value
        }
    }
}

// MARK: - 视图扩展
extension View {
    /// 按钮动画修饰器
    func animatedButton(isPressed: Bool, scale: CGFloat = 0.95) -> some View {
        modifier(AnimatedButtonModifier(isPressed: isPressed, scaleEffect: scale))
    }
    
    /// 震动效果修饰器
    func shakeEffect(isShaking: Bool) -> some View {
        modifier(ShakeModifier(isShaking: isShaking))
    }
    
    /// 脉冲动画修饰器
    func pulseAnimation(scale: CGFloat = 1.1, duration: Double = 1.0) -> some View {
        modifier(PulseAnimation(scale: scale, duration: duration))
    }
    
    /// 数字滚动动画
    func numberRollAnimation(value: String, oldValue: String) -> some View {
        modifier(NumberRollAnimation(value: value, oldValue: oldValue))
    }
    
    /// 优雅出现动画
    func elegantAppear(delay: Double = 0) -> some View {
        opacity(0)
            .scaleEffect(0.9)
            .onAppear {
                withAnimation(
                    AnimationSystem.Easing.spring(response: 0.6, dampingFraction: 0.8)
                    .delay(delay)
                ) {
                    self.opacity(1)
                    self.scaleEffect(1)
                }
            }
    }
    
    /// 优雅消失动画
    func elegantDisappear() -> some View {
        transition(
            .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.9)),
                removal: .opacity.combined(with: .scale(scale: 0.9))
            )
        )
        .animation(AnimationSystem.Easing.spring(response: 0.4, dampingFraction: 0.8))
    }
}

// MARK: - 动画管理器
@MainActor
class AnimationManager: ObservableObject {
    static let shared = AnimationManager()
    
    @Published private(set) var isAnimationsEnabled = true
    @Published private(set) var animationSpeed: AnimationSpeed = .normal
    
    enum AnimationSpeed: Double, CaseIterable {
        case slow = 1.5
        case normal = 1.0
        case fast = 0.5
        case instant = 0.0
        
        var description: String {
            switch self {
            case .slow: return "慢速"
            case .normal: return "正常"
            case .fast: return "快速"
            case .instant: return "无动画"
            }
        }
        
        var multiplier: Double {
            rawValue
        }
    }
    
    private let logger = Logger(subsystem: "com.calculatorpro.animation", category: "Animation")
    
    private init() {
        loadSettings()
        logger.info("动画管理器已初始化，速度: \(animationSpeed.description)")
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isAnimationsEnabled = defaults.bool(forKey: "animationsEnabled", defaultValue: true)
        
        if let speedRaw = defaults.string(forKey: "animationSpeed"),
           let speedValue = Double(speedRaw),
           let speed = AnimationSpeed(rawValue: speedValue) {
            animationSpeed = speed
        } else {
            animationSpeed = .normal
        }
    }
    
    func setAnimationsEnabled(_ enabled: Bool) {
        isAnimationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "animationsEnabled")
        logger.info("动画已\(enabled ? "启用" : "禁用")")
    }
    
    func setAnimationSpeed(_ speed: AnimationSpeed) {
        animationSpeed = speed
        UserDefaults.standard.set(speed.rawValue.description, forKey: "animationSpeed")
        logger.info("动画速度设置为: \(speed.description)")
    }
    
    /// 获取调整后的动画时长
    func adjustedDuration(_ baseDuration: Double) -> Double {
        guard isAnimationsEnabled else { return 0 }
        return baseDuration * animationSpeed.multiplier
    }
    
    /// 创建调整后的动画
    func adjustedAnimation(_ baseAnimation: Animation, duration: Double? = nil) -> Animation {
        guard isAnimationsEnabled else { return .linear(duration: 0) }
        
        if let duration = duration {
            let adjustedDuration = adjustedDuration(duration)
            return baseAnimation.speed(1 / animationSpeed.multiplier)
        }
        
        return baseAnimation.speed(1 / animationSpeed.multiplier)
    }
}

// MARK: - 动画预设
struct AnimationPresets {
    /// 计算器按钮按下动画
    static var calculatorButtonPress: Animation {
        AnimationManager.shared.adjustedAnimation(
            AnimationSystem.buttonPress
        )
    }
    
    /// 计算器按钮释放动画
    static var calculatorButtonRelease: Animation {
        AnimationManager.shared.adjustedAnimation(
            AnimationSystem.buttonRelease
        )
    }
    
    /// 模式切换动画
    static var calculatorModeSwitch: Animation {
        AnimationManager.shared.adjustedAnimation(
            AnimationSystem.modeSwitch
        )
    }
    
    /// 结果显示动画
    static var calculatorResultDisplay: Animation {
        AnimationManager.shared.adjustedAnimation(
            AnimationSystem.resultDisplay
        )
    }
    
    /// 错误提示动画
    static var calculatorErrorShake: Animation {
        AnimationManager.shared.adjustedAnimation(
            AnimationSystem.errorShake
        )
    }
}

// MARK: - UserDefaults扩展
extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}

// MARK: - 使用示例
/*
 // 在按钮中使用
 Button("计算") {
     // 计算逻辑
 }
 .animatedButton(isPressed: isPressed)
 
 // 在错误提示中使用
 Text("错误")
     .shakeEffect(isShaking: showError)
 
 // 在加载指示器中使用
 ProgressView()
     .pulseAnimation()
 
 // 在数字显示中使用
 Text(result)
     .numberRollAnimation(value: result, oldValue: oldResult)
 
 // 控制动画速度
 AnimationManager.shared.setAnimationSpeed(.fast)
 
 // 禁用动画（用于性能模式）
 AnimationManager.shared.setAnimationsEnabled(false)
 */