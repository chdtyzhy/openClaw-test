//
//  SettingsView_Continued.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

// 继续 SettingsView 的剩余部分

extension SettingsView {
    // MARK: - 导出数据视图继续
    struct ExportDataView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var exportFormat = ExportFormat.json
        @State private var includeHistory = true
        @State private var includeSettings = true
        @State private var isExporting = false
        @State private var exportProgress: Double = 0
        @State private var exportError: String?
        @State private var showingShareSheet = false
        @State private var exportFileURL: URL?
        
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
                                ProgressView(value: exportProgress, total: 1.0)
                                    .progressViewStyle(.linear)
                                
                                Text("正在导出数据... \(Int(exportProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        } else if let error = exportError {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("导出失败", systemImage: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                                
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    Section {
                        Button(action: startExport) {
                            HStack {
                                Spacer()
                                
                                if isExporting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Text("开始导出")
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                            }
                        }
                        .disabled(isExporting)
                        .foregroundColor(.white)
                        .listRowBackground(isExporting ? Color.blue.opacity(0.5) : Color.blue)
                    }
                    
                    if let fileURL = exportFileURL {
                        Section("导出完成") {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("数据已导出", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text("文件: \(fileURL.lastPathComponent)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("分享文件") {
                                    showingShareSheet = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .navigationTitle("导出数据")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let url = exportFileURL {
                        ShareSheet(activityItems: [url])
                    }
                }
            }
        }
        
        private func startExport() {
            isExporting = true
            exportError = nil
            exportProgress = 0
            
            // 模拟导出过程
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                exportProgress += 0.1
                
                if exportProgress >= 1.0 {
                    timer.invalidate()
                    completeExport()
                }
            }
        }
        
        private func completeExport() {
            isExporting = false
            
            // 创建模拟的导出文件
            let fileName = "CalculatorPro_Export_\(Date().formatted(date: .numeric, time: .shortened)).\(exportFormat.rawValue.lowercased())"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            // 写入模拟数据
            let exportData = """
            {
              "app": "Calculator Pro",
              "exportDate": "\(Date().formatted(date: .iso8601, time: .shortened))",
              "format": "\(exportFormat.rawValue)",
              "historyCount": 42,
              "settings": {
                "theme": "system",
                "angleMode": "degrees",
                "decimalPlaces": 6
              }
            }
            """
            
            do {
                try exportData.write(to: fileURL, atomically: true, encoding: .utf8)
                exportFileURL = fileURL
            } catch {
                exportError = error.localizedDescription
            }
        }
    }
    
    // MARK: - 关于视图
    struct AboutView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.openURL) private var openURL
        
        let appVersion = "1.0.0"
        let buildNumber = "1"
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // 应用图标和名称
                        VStack(spacing: 16) {
                            Image(systemName: "function")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                )
                            
                            Text("Calculator Pro")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("重新定义计算器体验")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // 版本信息
                        VStack(alignment: .leading, spacing: 16) {
                            InfoRow(
                                icon: "number",
                                title: "版本",
                                value: "\(appVersion) (\(buildNumber))"
                            )
                            
                            InfoRow(
                                icon: "calendar",
                                title: "发布日期",
                                value: Date().formatted(date: .long, time: .omitted)
                            )
                            
                            InfoRow(
                                icon: "apple.logo",
                                title: "系统要求",
                                value: "iOS 16.0 或更高版本"
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 功能亮点
                        VStack(alignment: .leading, spacing: 16) {
                            Text("功能亮点")
                                .font(.headline)
                            
                            FeatureRow(
                                icon: "bolt.fill",
                                color: .orange,
                                title: "极速计算",
                                description: "计算响应时间 <1ms"
                            )
                            
                            FeatureRow(
                                icon: "paintbrush.fill",
                                color: .blue,
                                title: "精美设计",
                                description: "遵循 iOS 设计规范"
                            )
                            
                            FeatureRow(
                                icon: "hand.tap.fill",
                                color: .green,
                                title: "丰富反馈",
                                description: "触觉和视觉反馈系统"
                            )
                            
                            FeatureRow(
                                icon: "chart.bar.fill",
                                color: .purple,
                                title: "完整功能",
                                description: "基础 + 科学 + 统计计算"
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 开发者信息
                        VStack(alignment: .leading, spacing: 16) {
                            Text("开发者")
                                .font(.headline)
                            
                            Button {
                                // 打开开发者网站
                                if let url = URL(string: "https://yourcompany.com") {
                                    openURL(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "safari")
                                        .foregroundColor(.blue)
                                    
                                    Text("访问官方网站")
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Button {
                                // 发送反馈
                                if let url = URL(string: "mailto:support@yourcompany.com") {
                                    openURL(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.blue)
                                    
                                    Text("发送反馈")
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 版权信息
                        VStack(spacing: 8) {
                            Text("© 2026 Your Company")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("保留所有权利")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 24)
                    }
                    .padding(.bottom, 40)
                }
                .navigationTitle("关于")
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
    
    // MARK: - 隐私政策视图
    struct PrivacyPolicyView: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("隐私政策")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("生效日期：2026年3月23日")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // 隐私政策内容
                        PrivacySection(
                            title: "1. 数据收集",
                            content: "Calculator Pro 完全离线运行，不收集任何个人信息。所有计算都在设备本地完成，数据不会上传到任何服务器。"
                        )
                        
                        PrivacySection(
                            title: "2. 本地存储",
                            content: "应用仅在您的设备本地存储计算历史和设置偏好。这些数据仅用于改善您的使用体验，不会与第三方共享。"
                        )
                        
                        PrivacySection(
                            title: "3. iCloud 同步",
                            content: "如果您启用 iCloud 同步，您的计算历史会在您的 Apple ID 下的设备间同步。这些数据受 Apple 的隐私政策保护。"
                        )
                        
                        PrivacySection(
                            title: "4. 儿童隐私",
                            content: "本应用适合所有年龄用户使用，不收集儿童的个人信息，符合儿童在线隐私保护法要求。"
                        )
                        
                        PrivacySection(
                            title: "5. 政策变更",
                            content: "如果我们决定更改本隐私政策，我们会在本页面发布更新后的版本，并在应用更新说明中提及。"
                        )
                        
                        // 联系信息
                        VStack(alignment: .leading, spacing: 12) {
                            Text("联系我们")
                                .font(.headline)
                            
                            Text("如果您对本隐私政策有任何疑问，请通过以下方式联系我们：")
                                .font(.body)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📧 邮箱: privacy@yourcompany.com")
                                Text("🌐 网站: https://yourcompany.com/privacy")
                                Text("📍 地址: 123 Main St, Beijing, China")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        Text("最后更新：2026年3月23日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .padding()
                }
                .navigationTitle("隐私政策")
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
    
    // MARK: - 辅助组件
    struct InfoRow: View {
        let icon: String
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    struct FeatureRow: View {
        let icon: String
        let color: Color
        let title: String
        let description: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.body)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    struct PrivacySection: View {
        let title: String
        let content: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
}

// MARK: - 分享 Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}

#Preview {
    SettingsView(isShowingSettings: .constant(true))
        .environmentObject(ThemeManager())
        .environmentObject(CalculatorManager())
        .environmentObject(HapticFeedbackManager.shared)
        .environmentObject(AnimationManager.shared)
        .environmentObject(PerformanceMonitor.shared)
}