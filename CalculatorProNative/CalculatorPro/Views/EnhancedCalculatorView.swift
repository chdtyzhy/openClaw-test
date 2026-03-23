//
//  EnhancedCalculatorView.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

/// 增强版计算器视图 - 集成完整的体验保证系统
struct EnhancedCalculatorView: View {
    @EnvironmentObject private var calculatorManager: CalculatorManager
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var performanceMonitor = PerformanceMonitor.shared
    @StateObject private var hapticManager = HapticFeedbackManager.shared
    @StateObject private var animationManager = AnimationManager.shared
    
    @State private var displayValue = "0"
    @State private var previousValue: String? = nil
    @State private var currentOperator: String? = nil
    @State private var isButtonPressed = false
    @State private var pressedButtonId: String? = nil
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isShowingPerformance = false
    
    // 性能测量
    @State private var calculationMeasurement: CalculationMeasurement?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 性能指示器 (调试模式)
                    if isShowingPerformance {
                        PerformanceIndicatorView()
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }
                    
                    // 显示区域
                    EnhancedDisplayView(
                        value: displayValue,
                        previousValue: previousValue,
                        currentOperator: currentOperator,
                        showError: showError
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 模式指示器
                    EnhancedModeIndicatorView()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    // 按钮网格
                    EnhancedCalculatorButtonsView(
                        displayValue: $displayValue,
                        previousValue: $previousValue,
                        currentOperator: $currentOperator,
                        pressedButtonId: $pressedButtonId,
                        onButtonPress: handleButtonPress,
                        onButtonRelease: handleButtonRelease
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Calculator Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // 性能监控开关
                        Toggle("显示性能", isOn: $isShowingPerformance)
                        
                        Divider()
                        
                        // 动画设置
                        Menu("动画速度") {
                            ForEach(AnimationManager.AnimationSpeed.allCases, id: \.self) { speed in
                                Button(speed.description) {
                                    animationManager.setAnimationSpeed(speed)
                                }
                            }
                        }
                        
                        // 触觉反馈设置
                        Menu("触觉反馈") {
                            Toggle("启用反馈", isOn: Binding(
                                get: { hapticManager.isEnabled },
                                set: { hapticManager.setEnabled($0) }
                            ))
                            
                            Divider()
                            
                            ForEach(HapticFeedbackManager.HapticIntensity.allCases, id: \.self) { intensity in
                                Button(intensity.description) {
                                    hapticManager.setIntensity(intensity)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // 性能报告
                        Button("性能报告") {
                            showPerformanceReport()
                        }
                        
                        // 重置性能数据
                        Button("重置性能数据", role: .destructive) {
                            performanceMonitor.reset()
                        }
                    } label: {
                        Image(systemName: "gauge.with.dots.needle.67percent")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert("计算错误", isPresented: $showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // 启动性能监控
            performanceMonitor.recordUserInteraction(.init(
                type: .calculation,
                element: "app_launch",
                timestamp: Date()
            ))
        }
    }
    
    // MARK: - 按钮处理
    
    private func handleButtonPress(_ button: CalculatorButton) {
        // 开始性能测量
        calculationMeasurement = performanceMonitor.startCalculationMeasurement("button_\(button.label)")
        
        // 触觉反馈
        hapticManager.trigger(.buttonPress)
        
        // 按钮按下状态
        withAnimation(AnimationPresets.calculatorButtonPress) {
            pressedButtonId = button.id
            isButtonPressed = true
        }
        
        // 记录用户交互
        performanceMonitor.recordUserInteraction(.init(
            type: .buttonPress,
            element: button.label,
            timestamp: Date()
        ))
    }
    
    private func handleButtonRelease(_ button: CalculatorButton) {
        // 结束性能测量
        calculationMeasurement?.end()
        
        // 触觉反馈
        hapticManager.trigger(.buttonRelease)
        
        // 按钮释放状态
        withAnimation(AnimationPresets.calculatorButtonRelease) {
            pressedButtonId = nil
            isButtonPressed = false
        }
        
        // 处理按钮逻辑
        processButtonAction(button)
    }
    
    private func processButtonAction(_ button: CalculatorButton) {
        let measurement = performanceMonitor.startCalculationMeasurement("process_\(button.label)")
        defer { measurement.end() }
        
        do {
            switch button {
            case .number(let value, _):
                handleNumberPress(value)
            case .operator(let symbol, _):
                handleOperatorPress(symbol)
            case .function(let symbol, _):
                handleFunctionPress(symbol)
            case .equals:
                handleEqualsPress()
            }
            
            // 成功反馈
            hapticManager.trigger(.calculationSuccess)
            
        } catch {
            // 错误处理
            showCalculationError(error.localizedDescription)
            hapticManager.trigger(.calculationError)
        }
    }
    
    private func handleNumberPress(_ number: String) {
        if displayValue == "0" || displayValue == "错误" {
            displayValue = number
        } else {
            displayValue += number
        }
    }
    
    private func handleOperatorPress(_ operatorSymbol: String) {
        previousValue = displayValue
        currentOperator = operatorSymbol
        displayValue = "0"
        
        // 模式切换反馈
        hapticManager.trigger(.modeChange)
    }
    
    private func handleFunctionPress(_ function: String) {
        switch function {
        case "C":
            handleClearPress()
        case "+/-":
            toggleSign()
        case "%":
            calculatePercentage()
        default:
            break
        }
    }
    
    private func handleEqualsPress() {
        guard let prevValue = previousValue,
              let prevDouble = Double(prevValue),
              let currentDouble = Double(displayValue),
              let operatorSymbol = currentOperator else {
            return
        }
        
        let measurement = performanceMonitor.startCalculationMeasurement("calculate_\(operatorSymbol)")
        
        do {
            let result = try performCalculation(
                a: prevDouble,
                b: currentDouble,
                operator: operatorSymbol
            )
            
            displayValue = formatResult(result)
            previousValue = nil
            currentOperator = nil
            
            measurement.end()
            
            // 成功反馈
            hapticManager.trigger(.calculationSuccess)
            
        } catch {
            measurement.end()
            showCalculationError(error.localizedDescription)
            hapticManager.trigger(.calculationError)
        }
    }
    
    private func handleClearPress() {
        displayValue = "0"
        previousValue = nil
        currentOperator = nil
    }
    
    private func toggleSign() {
        if let value = Double(displayValue) {
            displayValue = String(-value)
        }
    }
    
    private func calculatePercentage() {
        if let value = Double(displayValue) {
            displayValue = String(value / 100)
        }
    }
    
    private func performCalculation(a: Double, b: Double, operator: String) throws -> Double {
        switch `operator` {
        case "+":
            return calculatorManager.calculatorCore.add(a, b)
        case "-":
            return calculatorManager.calculatorCore.subtract(a, b)
        case "×":
            return calculatorManager.calculatorCore.multiply(a, b)
        case "÷":
            return try calculatorManager.calculatorCore.divide(a, b)
        default:
            throw CalculationError.invalidOperator
        }
    }
    
    private func formatResult(_ value: Double) -> String {
        if value.isNaN || value.isInfinite {
            return "错误"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = calculatorManager.decimalPlaces
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        
        if let formatted = formatter.string(from: NSNumber(value: value)) {
            return formatted
        }
        
        return String(format: "%.\(min(calculatorManager.decimalPlaces, 10))e", value)
    }
    
    private func showCalculationError(_ message: String) {
        errorMessage = message
        showError = true
        
        // 错误动画
        withAnimation(AnimationPresets.calculatorErrorShake) {
            self.showError = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                self.showError = false
            }
        }
    }
    
    private func showPerformanceReport() {
        let report = performanceMonitor.generatePerformanceReport()
        print(report.summary)
        
        // 这里可以显示性能报告弹窗或分享报告
    }
}

// MARK: - 增强显示视图
struct EnhancedDisplayView: View {
    let value: String
    let previousValue: String?
    let currentOperator: String?
    let showError: Bool
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if let previous = previousValue, let op = currentOperator {
                Text("\(previous) \(op)")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .transition(.opacity.combined(with: .slide))
            }
            
            Text(value)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(showError ? .red : .primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(.vertical, 4)
                .shakeEffect(isShaking: showError)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .opacity
                ))
                .animation(AnimationPresets.calculatorResultDisplay, value: value)
        }
    }
}

// MARK: - 增强模式指示器
struct EnhancedModeIndicatorView: View {
    @EnvironmentObject private var calculatorManager: CalculatorManager
    
    var body: some View {
        HStack {
            Text(calculatorManager.currentMode.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .transition(.opacity)
            
            if calculatorManager.currentMode == .scientific {
                Text("•")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(calculatorManager.angleMode.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .transition(.slide)
            }
            
            Spacer()
        }
        .animation(AnimationPresets.calculatorModeSwitch, value: calculatorManager.currentMode)
    }
}

// MARK: - 性能指示器
struct PerformanceIndicatorView: View {
    @StateObject private var monitor = PerformanceMonitor.shared
    
    var body: some View {
        HStack {
            // 帧率指示器
            IndicatorItem(
                label: "FPS",
                value: String(format: "%.0f", monitor.currentMetrics.frameRate),
                color: monitor.currentMetrics.frameRate > 100 ? .green : 
                       monitor.currentMetrics.frameRate > 60 ? .yellow : .red
            )
            
            // 内存指示器
            IndicatorItem(
                label: "内存",
                value: String(format: "%.1fMB", monitor.currentMetrics.memoryUsage),
                color: monitor.currentMetrics.memoryUsage < 20 ? .green :
                       monitor.currentMetrics.memoryUsage < 30 ? .yellow : .red
            )
            
            // 性能状态
            Image(systemName: monitor.isPerformanceOptimal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(monitor.isPerformanceOptimal ? .green : .orange)
                .font(.system(size: 12))
        }
        .padding(8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .font(.system(size: 11, weight: .medium))
    }
}

struct IndicatorItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundColor(.secondary)
            Text(value)
                .foregroundColor(color)
        }
    }
}

// MARK: - 错误类型
enum CalculationError: LocalizedError {
    case invalidOperator
    case divisionByZero
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .invalidOperator:
            return "无效的操作符"
        case .divisionByZero:
            return "不能除以零"
        case .invalidInput:
            return "无效的输入值"
        }
    }
}

#Preview {
    EnhancedCalculatorView()
        .environmentObject(CalculatorManager())
        .environmentObject(ThemeManager())
}