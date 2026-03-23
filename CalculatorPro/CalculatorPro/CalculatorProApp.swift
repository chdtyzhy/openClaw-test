//
//  CalculatorProApp.swift
//  计算器应用入口
//

import SwiftUI
import Combine

@main
struct CalculatorProApp: App {
    // 暂时注释掉复杂的 AppState
    // @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // 先使用简化版视图测试
            SimpleCalculatorView()
                // .environmentObject(appState)
                .onAppear {
                    configureAppearance()
                }
        }
    }
    
    private func configureAppearance() {
        // 简化外观配置
        #if os(iOS)
        // 只在 iOS 上配置基本外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        #endif
    }
}

// MARK: - 应用状态管理
@objc class AppState: NSObject, ObservableObject {
    @objc dynamic var isActive = true
    @objc dynamic var launchCount = 0
    @objc dynamic var lastLaunchDate = Date()
    @objc dynamic var theme: AppTheme = .system
    
    init() {
        loadAppData()
    }
    
    private func loadAppData() {
        let defaults = UserDefaults.standard
        
        // 加载启动数据
        launchCount = defaults.integer(forKey: "launchCount")
        if let lastDate = defaults.object(forKey: "lastLaunchDate") as? Date {
            lastLaunchDate = lastDate
        }
        
        // 加载主题设置
        if let themeName = defaults.string(forKey: "appTheme"),
           let savedTheme = AppTheme(rawValue: themeName) {
            theme = savedTheme
        }
        
        // 更新启动数据
        launchCount += 1
        lastLaunchDate = Date()
        
        defaults.set(launchCount, forKey: "launchCount")
        defaults.set(lastLaunchDate, forKey: "lastLaunchDate")
    }
    
    func saveTheme() {
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
}

// MARK: - 主题管理
enum AppTheme: String, CaseIterable, Equatable {
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

// MARK: - 设置视图（可选）
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("主题") {
                    Picker("选择主题", selection: $appState.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: appState.theme) { _ in
                        appState.saveTheme()
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("启动次数")
                        Spacer()
                        Text("\(appState.launchCount)")
                            .foregroundColor(.gray)
                    }
                    
                    if let lastLaunch = appState.lastLaunchDate.formatted(date: .abbreviated, time: .shortened) {
                        HStack {
                            Text("上次启动")
                            Spacer()
                            Text(lastLaunch)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}