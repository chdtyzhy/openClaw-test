//
//  SettingsView.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var calculatorManager: CalculatorManager
    @EnvironmentObject private var hapticManager: HapticFeedbackManager
    @EnvironmentObject private var animationManager: AnimationManager
    @EnvironmentObject private var performanceMonitor: PerformanceMonitor
    
    @Binding var isShowingSettings: Bool
    @State private var showingResetConfirmation = false
    @State private var showingExportOptions = false
    @State private var showingAbout = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - 外观设置
                Section("外观") {
                    // 主题设置
                    NavigationLink {
                        ThemeSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("主题")
                            
                            Spacer()
                            
                            Text(themeManager.currentTheme.rawValue)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                    
                    // 动画设置
                    NavigationLink {
                        AnimationSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "waveform.path")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            Text("动画")
                            
                            Spacer()
                            
                            Text(animationManager.animationSpeed.description)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                }
                
                // MARK: - 计算设置
                Section("计算") {
                    // 角度模式
                    Picker("角度模式", selection: $calculatorManager.angleMode) {
                        ForEach(CalculatorManager.AngleMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: calculatorManager.angleMode) { oldValue, newValue in
                        hapticManager.trigger(.modeChange)
                        calculatorManager.saveSettings()
                    }
                    
                    // 小数位数
                    Stepper(
                        "小数位数: \(calculatorManager.decimalPlaces)",
                        value: $calculatorManager.decimalPlaces,
                        in: 0...15,
                        step: 1
                    )
                    .onChange(of: calculatorManager.decimalPlaces) { oldValue, newValue in
                        calculatorManager.saveSettings()
                    }
                    
                    // 计算模式
                    Picker("计算模式", selection: $calculatorManager.currentMode) {
                        ForEach(CalculatorManager.CalculatorMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: calculatorManager.currentMode) { oldValue, newValue in
                        hapticManager.trigger(.modeChange)
                        calculatorManager.saveSettings()
                    }
                }
                
                // MARK: - 反馈设置
                Section("反馈") {
                    // 触觉反馈
                    Toggle(isOn: Binding(
                        get: { hapticManager.isEnabled },
                        set: { hapticManager.setEnabled($0) }
                    )) {
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            
                            Text("触觉反馈")
                        }
                    }
                    .onChange(of: hapticManager.isEnabled) { oldValue, newValue in
                        hapticManager.trigger(newValue ? .success : .warning)
                    }
                    
                    if hapticManager.isEnabled {
                        // 触觉强度
                        Picker("反馈强度", selection: Binding(
                            get: { hapticManager.intensity },
                            set: { hapticManager.setIntensity($0) }
                        )) {
                            ForEach(HapticFeedbackManager.HapticIntensity.allCases, id: \.self) { intensity in
                                Text(intensity.description).tag(intensity)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                    }
                    
                    // 声音反馈
                    Toggle(isOn: $calculatorManager.isSoundFeedbackEnabled) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            Text("声音反馈")
                        }
                    }
                    .onChange(of: calculatorManager.isSoundFeedbackEnabled) { oldValue, newValue in
                        calculatorManager.saveSettings()
                        hapticManager.trigger(newValue ? .success : .warning)
                    }
                }
                
                // MARK: - 数据管理
                Section("数据") {
                    // 导出数据
                    Button {
                        showingExportOptions = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("导出数据")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    // 重置数据
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .frame(width: 30)
                            
                            Text("重置所有数据")
                        }
                    }
                }
                
                // MARK: - 关于
                Section {
                    // 关于应用
                    Button {
                        showingAbout = true
                    } label: {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("关于 Calculator Pro")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    // 隐私政策
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            Text("隐私政策")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    // 服务条款
                    Button {
                        showingTermsOfService = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            
                            Text("服务条款")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // MARK: - 性能信息
                if performanceMonitor.isPerformanceOptimal {
                    Section("性能") {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("性能状态")
                                    .font(.headline)
                                
                                Text("应用运行流畅，所有指标正常")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button("查看性能报告") {
                            // 显示性能报告
                            let report = performanceMonitor.generatePerformanceReport()
                            print(report.summary)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isShowingSettings = false
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert("重置确认", isPresented: $showingResetConfirmation) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("确定要重置所有数据吗？这将清除所有历史记录和设置。")
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportDataView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
    }
    
    private func resetAllData() {
        // 重置所有数据
        calculatorManager.saveSettings()
        hapticManager.trigger(.success)
        
        // 这里可以添加重置历史记录等操作
    }
}

// MARK: - 主题设置视图
struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var hapticManager: HapticFeedbackManager
    
    var body: some View {
        List {
            Section("主题选择") {
                ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                    Button {
                        themeManager.setTheme(theme)
                        hapticManager.trigger(.themeChange)
                    } label: {
                        HStack {
                            Text(theme.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            
            Section("预览") {
                VStack(spacing: 20) {
                    // 浅色主题预览
                    if themeManager.currentTheme == .light || themeManager.currentTheme == .system {
                        ThemePreviewCard(
                            themeName: "浅色主题",
                            backgroundColor: .white,
                            textColor: .black,
                            isSelected: themeManager.currentTheme == .light
                        )
                    }
                    
                    // 深色主题预览
                    if themeManager.currentTheme == .dark || themeManager.currentTheme == .system {
                        ThemePreviewCard(
                            themeName: "深色主题",
                            backgroundColor: .black,
                            textColor: .white,
                            isSelected: themeManager.currentTheme == .dark
                        )
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Text("选择\"跟随系统\"将自动根据系统设置切换浅色/深色主题。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("主题设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemePreviewCard: View {
    let themeName: String
    let backgroundColor: Color
    let textColor: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(themeName)
                    .font(.headline)
                    .foregroundColor(textColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 12) {
                // 按钮预览
                Circle()
                    .fill(Color.blue)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text("=")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text("+")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text("7")
                            .font(.title2)
                            .foregroundColor(textColor)
                    )
                
                Spacer()
            }
            
            // 显示区域预览
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 60)
                .overlay(
                    Text("123.45")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(textColor)
                )
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - 动画设置视图
struct AnimationSettingsView: View {
    @EnvironmentObject private var animationManager: AnimationManager
    @EnvironmentObject private var hapticManager: HapticFeedbackManager
    
    var body: some View {
        List {
            Section("动画设置") {
                Toggle("启用动画", isOn: $animationManager.isAnimationsEnabled)
                    .onChange(of: animationManager.isAnimationsEnabled) { oldValue, newValue in
                        hapticManager.trigger(newValue ? .success : .warning)
                    }
                
                if animationManager.isAnimationsEnabled {
                    Picker("动画速度", selection: $animationManager.animationSpeed) {
                        ForEach(AnimationManager.AnimationSpeed.allCases, id: \.self) { speed in
                            Text(speed.description).tag(speed)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }
            }
            
            Section("动画预览") {
                AnimationPreviewView()
            }
            
            Section {
                Text("关闭动画可以提高性能，特别是在较旧的设备上。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("动画设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AnimationPreviewView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            // 按钮动画预览
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isAnimating.toggle()
                    scale = isAnimating ? 0.9 : 1.0
                }
            } label: {
                Text("点击预览动画")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .scaleEffect(scale)
            }
            
            // 数字滚动预览
            HStack {
                Text("数字动画:")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(isAnimating ? "123.45" : "0")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 模式切换预览
            HStack {
                Capsule()
                    .fill(isAnimating ? Color.blue : Color.gray)
                    .frame(width: 60, height: 30)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 26, height: 26)
                            .offset(x: isAnimating ? 15 : -15)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isAnimating.toggle()
                        }
                    }
                
                Text(isAnimating ? "科学模式" : "基础模式")
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 导出数据视图
struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat = ExportFormat.json
    @State private var includeHistory = true
    @State private var includeSettings = true
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case txt = "纯文本"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("导出选项") {
                    Picker("导出格式", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("包含历史记录", isOn: $includeHistory)
                    Toggle("包含设置", isOn: $includeSettings)
                }
                
                Section {
                    if isExporting {
                        VStack(spacing: 12) {
