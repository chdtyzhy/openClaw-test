# 部署指南

## 🚀 快速开始

### **环境要求**
```
✅ macOS 13.0+ (Ventura)
✅ Xcode 15.0+
✅ Swift 5.9+
✅ iOS 17.0+ SDK
✅ Apple开发者账号
```

### **一分钟部署**
```bash
# 1. 克隆项目
git clone https://github.com/yourusername/CalculatorPro.git
cd CalculatorPro

# 2. 打开Xcode项目
open CalculatorPro.xcodeproj

# 3. 选择开发团队
# 4. 选择目标设备
# 5. 点击运行按钮 (Cmd+R)
```

## 🏗️ 项目设置

### **Xcode项目配置**
1. **打开项目**: `CalculatorPro.xcodeproj`
2. **选择目标**: `CalculatorPro`
3. **General设置**:
   - Bundle Identifier: `com.yourcompany.calculatorpro`
   - Version: `1.0.0`
   - Build: `1`
   - Team: 选择你的开发团队
4. **Signing & Capabilities**:
   - 启用自动签名
   - 添加能力: iCloud, Push Notifications (可选)

### **Swift包依赖**
项目使用Swift Package Manager管理依赖，无需额外配置：
```swift
// Package.swift 已包含所有依赖
dependencies: [
    .package(url: "https://github.com/apple/swift-testing.git", from: "0.5.0")
]
```

## 🧪 测试

### **运行所有测试**
```bash
# 命令行运行
swift test

# 或使用Xcode
# 1. 选择测试目标
# 2. 按 Cmd+U
```

### **测试覆盖率**
```bash
# 生成测试覆盖率报告
xcodebuild test \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult
```

### **性能测试**
```bash
# 运行性能基准测试
swift test --filter "performance"
```

## 📱 设备测试

### **模拟器测试**
```bash
# 列出可用模拟器
xcrun simctl list devices

# 启动特定模拟器
xcrun simctl boot "iPhone 14"

# 在模拟器上运行应用
xcodebuild test \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -destination 'platform=iOS Simulator,name=iPhone 14'
```

### **真机测试**
1. **连接设备**: 通过USB连接iPhone/iPad
2. **信任设备**: 在设备上信任电脑
3. **选择设备**: 在Xcode中选择连接的设备
4. **运行应用**: 按Cmd+R运行

## 🚀 构建配置

### **调试配置 (Debug)**
```
• 优化级别: -Onone (无优化)
• 调试信息: 完整
• 代码覆盖率: 启用
• 断言: 启用
• 日志: 详细
```

### **发布配置 (Release)**
```
• 优化级别: -O (完全优化)
• 调试信息: 无
• 代码覆盖率: 禁用
• 断言: 禁用
• 日志: 仅错误
• 剥离符号: 是
```

### **构建命令**
```bash
# 调试构建
xcodebuild build \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -configuration Debug \
  -destination 'generic/platform=iOS'

# 发布构建
xcodebuild build \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -configuration Release \
  -destination 'generic/platform=iOS'
```

## 📦 打包应用

### **创建归档**
```bash
# 创建发布归档
xcodebuild archive \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -configuration Release \
  -archivePath CalculatorPro.xcarchive \
  -destination 'generic/platform=iOS'
```

### **导出IPA**
```bash
# 导出IPA文件
xcodebuild -exportArchive \
  -archivePath CalculatorPro.xcarchive \
  -exportPath CalculatorProExport \
  -exportOptionsPlist ExportOptions.plist
```

### **ExportOptions.plist示例**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <true/>
</dict>
</plist>
```

## 🚢 部署到App Store

### **使用Xcode部署**
1. **打开归档**: Xcode → Window → Organizer
2. **选择归档**: 选择CalculatorPro.xcarchive
3. **验证应用**: 点击Validate App
4. **上传到App Store**: 点击Distribute App

### **使用命令行部署**
```bash
# 验证应用
xcrun altool --validate-app \
  -f CalculatorProExport/CalculatorPro.ipa \
  -t ios \
  -u "your-apple-id@email.com" \
  -p "app-specific-password"

# 上传应用
xcrun altool --upload-app \
  -f CalculatorProExport/CalculatorPro.ipa \
  -t ios \
  -u "your-apple-id@email.com" \
  -p "app-specific-password"
```

### **使用Fastlane部署** (推荐)
```ruby
# fastlane/Fastfile
lane :appstore do
  # 增加构建号
  increment_build_number
  
  # 构建应用
  gym(
    scheme: "CalculatorPro",
    export_method: "app-store",
    clean: true
  )
  
  # 上传到App Store Connect
  deliver(
    skip_binary_upload: false,
    skip_screenshots: true,
    skip_metadata: false,
    force: true
  )
end
```

```bash
# 运行Fastlane部署
fastlane appstore
```

## 🔄 持续集成/持续部署 (CI/CD)

### **GitHub Actions配置**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Run tests
      run: |
        xcodebuild test \
          -project CalculatorPro.xcodeproj \
          -scheme CalculatorPro \
          -destination 'platform=iOS Simulator,name=iPhone 14'
    
  deploy:
    runs-on: macos-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Install Fastlane
      run: gem install fastlane
    
    - name: Deploy to TestFlight
      env:
        APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
      run: fastlane beta
```

### **环境变量配置**
```bash
# GitHub Secrets需要配置
APP_STORE_CONNECT_API_KEY
MATCH_PASSWORD
APPLE_ID
APPLE_TEAM_ID
```

## 📊 监控和分析

### **应用性能监控**
```swift
// 在关键位置添加性能监控
import os

let performanceLogger = Logger(subsystem: "com.yourcompany.calculatorpro", category: "performance")

func measurePerformance<T>(_ name: String, _ operation: () throws -> T) rethrows -> T {
    let startTime = Date()
    let result = try operation()
    let elapsedTime = Date().timeIntervalSince(startTime)
    
    performanceLogger.info("\(name): \(elapsedTime * 1000)ms")
    
    if elapsedTime > 0.1 { // 超过100ms警告
        performanceLogger.warning("\(name) took too long: \(elapsedTime * 1000)ms")
    }
    
    return result
}

// 使用示例
let result = measurePerformance("complexCalculation") {
    try calculator.performComplexCalculation()
}
```

### **崩溃报告**
```swift
// 配置崩溃报告
import FirebaseCrashlytics

func configureCrashReporting() {
    FirebaseApp.configure()
    
    // 设置用户标识
    Crashlytics.crashlytics().setUserID("user123")
    
    // 记录自定义日志
    Crashlytics.crashlytics().log("App launched")
}
```

### **使用分析**
```swift
// 跟踪用户行为
import FirebaseAnalytics

func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
    Analytics.logEvent(name, parameters: parameters)
}

// 使用示例
trackEvent("calculation_performed", parameters: [
    "type": "scientific",
    "function": "sin",
    "result": result
])
```

## 🔧 故障排除

### **常见问题**

#### **1. 代码签名错误**
```
错误: No profiles for 'com.yourcompany.calculatorpro' were found
解决方案:
1. 检查Bundle Identifier是否唯一
2. 确保在开发者门户创建了App ID
3. 下载并安装正确的配置文件
```

#### **2. 设备部署失败**
```
错误: Could not launch "CalculatorPro"
解决方案:
1. 检查设备是否信任电脑
2. 重启设备和Xcode
3. 清理构建文件夹 (Cmd+Shift+K)
```

#### **3. 测试失败**
```
错误: Test target 'CalculatorProTests' failed
解决方案:
1. 检查测试依赖是否完整
2. 确保模拟器已启动
3. 清理测试数据
```

#### **4. 上传到App Store失败**
```
错误: ITMS-90338: Non-public API usage
解决方案:
1. 检查是否使用了私有API
2. 更新到最新的SDK
3. 重新构建应用
```

### **调试技巧**

#### **启用详细日志**
```bash
# 构建时显示详细日志
xcodebuild -verbose ...

# 运行应用时显示系统日志
xcrun simctl spawn booted log stream --level debug
```

#### **内存调试**
```swift
// 检查内存泄漏
import Foundation

func checkMemoryLeaks() {
    #if DEBUG
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let memoryUsage = report_memory()
        print("内存使用: \(memoryUsage) MB")
    }
    #endif
}

func report_memory() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_,
                     task_flavor_t(MACH_TASK_BASIC_INFO),
                     $0,
                     &count)
        }
    }
    
    if kerr == KERN_SUCCESS {
        return info.resident_size / 1024 / 1024
    } else {
        return 0
    }
}
```

#### **性能分析**
```bash
# 使用Instruments分析性能
instruments -t "Time Profiler" CalculatorPro.app

# 使用Xcode内置分析器
# Product → Profile (Cmd+I)
```

## 📚 资源链接

### **官方文档**
- [Apple开发者文档](https://developer.apple.com/documentation/)
- [Swift编程语言](https://docs.swift.org/swift-book/)
- [SwiftUI教程](https://developer.apple.com/tutorials/swiftui)
- [App Store审核指南](https://developer.apple.com/app-store/review/guidelines/)

### **工具资源**
- [Fastlane文档](https://docs.fastlane.tools)
- [GitHub Actions文档](https://docs.github.com/en/actions)
- [Firebase文档](https://firebase.google.com/docs)

### **社区资源**
- [Swift论坛](https://forums.swift.org)
- [Stack Overflow Swift标签](https://stackoverflow.com/questions/tagged/swift)
- [iOS开发者社区](https://developer.apple.com/forums/)

## 🔄 更新和维护

### **版本更新流程**
1. **计划更新**: 确定更新内容和时间表
2. **开发测试**: 实现新功能并测试
3. **内部测试**: TestFlight内部测试
4. **外部测试**: TestFlight外部测试
5. **提交审核**: 提交到App Store审核
6. **发布更新**: 审核通过后发布

### **热修复流程**
1. **确认问题**: 收集用户反馈和崩溃报告
2. **紧急修复**: 快速修复关键问题
3. **测试验证**: 验证修复效果
4. **快速审核**: 申请加急审核
5. **发布修复**: 发布热修复版本

### **数据迁移**
```swift
// 版本间数据迁移
func migrateData(from oldVersion: String, to newVersion: String) {
    if oldVersion == "1.0.0" && newVersion == "1.1.0" {
        // 迁移1.0.0到1.1.0的数据
        migrateFromV1ToV1_1()
    }
    
    if oldVersion == "1.1.0" && newVersion == "2.0.0" {
        // 迁移1.1.0到2.0.0的数据
        migrateFromV1_1ToV2()
    }
}
```

## 📞 支持

### **技术支持**
- **邮箱**: support@yourcompany.com
- **网站**: https://support.yourcompany.com
- **文档**: https://docs.yourcompany.com

### **紧急联系**
- **紧急问题**: emergency@yourcompany.com
- **电话**: +86 400-123-4567
- **工作时间**: 周一至周五 9:00-18:00 (北京时间)

---

**文档版本**: 1.0.0  
**最后更新**: 2026-03-23  
**适用版本**: Calculator Pro 1.0.0+