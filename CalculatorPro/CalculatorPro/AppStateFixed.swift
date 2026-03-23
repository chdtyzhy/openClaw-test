//
//  AppStateFixed.swift
//  修复的应用状态管理
//

import Foundation
import Combine

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

// MARK: - 应用状态管理（修复版）
class AppStateFixed: ObservableObject {
    // 使用 objectWillChange 手动通知
    let objectWillChange = ObservableObjectPublisher()
    
    private var _isActive = true
    var isActive: Bool {
        get { _isActive }
        set {
            _isActive = newValue
            objectWillChange.send()
        }
    }
    
    private var _launchCount = 0
    var launchCount: Int {
        get { _launchCount }
        set {
            _launchCount = newValue
            objectWillChange.send()
        }
    }
    
    private var _lastLaunchDate = Date()
    var lastLaunchDate: Date {
        get { _lastLaunchDate }
        set {
            _lastLaunchDate = newValue
            objectWillChange.send()
        }
    }
    
    private var _theme: AppTheme = .system
    var theme: AppTheme {
        get { _theme }
        set {
            _theme = newValue
            objectWillChange.send()
        }
    }
    
    init() {
        loadAppData()
    }
    
    private func loadAppData() {
        let defaults = UserDefaults.standard
        
        // 加载启动数据
        _launchCount = defaults.integer(forKey: "launchCount")
        if let lastDate = defaults.object(forKey: "lastLaunchDate") as? Date {
            _lastLaunchDate = lastDate
        }
        
        // 加载主题设置
        if let themeName = defaults.string(forKey: "appTheme"),
           let savedTheme = AppTheme(rawValue: themeName) {
            _theme = savedTheme
        }
        
        // 更新启动数据
        _launchCount += 1
        _lastLaunchDate = Date()
        
        defaults.set(_launchCount, forKey: "launchCount")
        defaults.set(_lastLaunchDate, forKey: "lastLaunchDate")
    }
    
    func saveTheme() {
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
}