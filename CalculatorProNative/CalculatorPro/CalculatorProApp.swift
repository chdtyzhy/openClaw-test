//
//  CalculatorProApp.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

@main
struct CalculatorProApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var calculatorManager = CalculatorManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .environmentObject(calculatorManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    // 应用启动配置
                    configureAppearance()
                }
        }
    }
    
    private func configureAppearance() {
        // 配置导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // 配置标签栏外观
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// MARK: - 应用状态管理
class AppState: ObservableObject {
    @Published var isActive = true
    @Published var launchCount = 0
    @Published var lastLaunchDate = Date()
    
    init() {
        loadLaunchData()
    }
    
    private func loadLaunchData() {
        // 从UserDefaults加载启动数据
        let defaults = UserDefaults.standard
        launchCount = defaults.integer(forKey: "launchCount")
        if let lastDate = defaults.object(forKey: "lastLaunchDate") as? Date {
            lastLaunchDate = lastDate
        }
        
        // 更新启动数据
        launchCount += 1
        lastLaunchDate = Date()
        
        defaults.set(launchCount, forKey: "launchCount")
        defaults.set(lastLaunchDate, forKey: "lastLaunchDate")
    }
}

// MARK: - 主题管理
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    @Published var colorScheme: ColorScheme? = nil
    
    enum AppTheme: String, CaseIterable {
        case light = "浅色"
        case dark = "深色"
        case system = "跟随系统"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    init() {
        loadTheme()
        updateColorScheme()
    }
    
    private func loadTheme() {
        let themeName = UserDefaults.standard.string(forKey: "appTheme") ?? "system"
        currentTheme = AppTheme(rawValue: themeName) ?? .system
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        colorScheme = currentTheme.colorScheme
    }
}

// MARK: - 计算器管理
class CalculatorManager: ObservableObject {
    @Published var currentMode: CalculatorMode = .basic
    @Published var angleMode: AngleMode = .degrees
    @Published var decimalPlaces: Int = 6
    @Published var isHapticFeedbackEnabled = true
    @Published var isSoundFeedbackEnabled = false
    
    let calculatorCore = CalculatorCore()
    let scientificEngine = ScientificEngine()
    
    enum CalculatorMode: String, CaseIterable {
        case basic = "基础计算"
        case scientific = "科学计算"
        case programmer = "程序员"
        case statistics = "统计"
    }
    
    enum AngleMode: String, CaseIterable {
        case degrees = "角度"
        case radians = "弧度"
        case gradians = "百分度"
        
        var conversionFactor: Double {
            switch self {
            case .degrees: return .pi / 180
            case .radians: return 1
            case .gradians: return .pi / 200
            }
        }
    }
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        if let modeString = defaults.string(forKey: "calculatorMode"),
           let mode = CalculatorMode(rawValue: modeString) {
            currentMode = mode
        }
        
        if let angleString = defaults.string(forKey: "angleMode"),
           let angle = AngleMode(rawValue: angleString) {
            angleMode = angle
        }
        
        decimalPlaces = defaults.integer(forKey: "decimalPlaces")
        if decimalPlaces == 0 { decimalPlaces = 6 }
        
        isHapticFeedbackEnabled = defaults.bool(forKey: "hapticFeedback")
        isSoundFeedbackEnabled = defaults.bool(forKey: "soundFeedback")
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(currentMode.rawValue, forKey: "calculatorMode")
        defaults.set(angleMode.rawValue, forKey: "angleMode")
        defaults.set(decimalPlaces, forKey: "decimalPlaces")
        defaults.set(isHapticFeedbackEnabled, forKey: "hapticFeedback")
        defaults.set(isSoundFeedbackEnabled, forKey: "soundFeedback")
    }
}