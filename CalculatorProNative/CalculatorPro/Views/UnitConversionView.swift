//
//  UnitConversionView.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

struct UnitConversionView: View {
    @StateObject private var unitManager = UnitConversionManager.shared
    @EnvironmentObject private var hapticManager: HapticFeedbackManager
    @EnvironmentObject private var performanceMonitor: PerformanceMonitor
    
    @State private var selectedUnitType: UnitConverter.UnitType = .length
    @State private var inputValue: String = "1"
    @State private var sourceUnit: String = ""
    @State private var targetUnit: String = ""
    @State private var conversionResult: String = ""
    @State private var isConverting = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingRecentConversions = false
    
    // 可用的单位
    private var availableUnits: [String] {
        unitManager.converter.availableUnits(for: selectedUnitType)
    }
    
    // 用户偏好
    private var userPreference: (String, String)? {
        unitManager.getPreference(for: selectedUnitType)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 单位类型选择
                    UnitTypeSelector(selectedType: $selectedUnitType)
                        .padding(.horizontal)
                    
                    // 输入区域
                    InputSection(
                        value: $inputValue,
                        sourceUnit: $sourceUnit,
                        targetUnit: $targetUnit,
                        availableUnits: availableUnits,
                        userPreference: userPreference,
                        onUnitChange: handleUnitChange
                    )
                    .padding(.horizontal)
                    
                    // 换算按钮
                    ConversionButton(
                        isConverting: $isConverting,
                        onConvert: performConversion
                    )
                    .padding(.horizontal)
                    
                    // 结果显示
                    if !conversionResult.isEmpty {
                        ResultSection(
                            result: conversionResult,
                            sourceValue: inputValue,
                            sourceUnit: sourceUnit,
                            targetUnit: targetUnit,
                            onCopy: copyResult,
                            onSwap: swapUnits
                        )
                        .padding(.horizontal)
                    }
                    
                    // 最近换算记录
                    if !unitManager.recentConversions.isEmpty {
                        RecentConversionsSection(
                            conversions: unitManager.recentConversions,
                            showingAll: $showingRecentConversions,
                            onSelect: selectRecentConversion,
                            onClear: clearRecentConversions
                        )
                        .padding(.horizontal)
                    }
                    
                    // 单位说明
                    UnitDescriptionSection(unitType: selectedUnitType)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("单位换算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("保存当前偏好") {
                            saveCurrentPreference()
                        }
                        
                        Button("重置所有偏好") {
                            resetPreferences()
                        }
                        
                        if !unitManager.recentConversions.isEmpty {
                            Divider()
                            
                            Button("清除历史记录", role: .destructive) {
                                clearRecentConversions()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("换算错误", isPresented: $showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                setupInitialUnits()
            }
            .onChange(of: selectedUnitType) { oldValue, newValue in
                handleUnitTypeChange(newValue)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - 事件处理
    
    private func setupInitialUnits() {
        let units = availableUnits
        guard !units.isEmpty else { return }
        
        if let preference = userPreference {
            sourceUnit = preference.0
            targetUnit = preference.1
        } else {
            sourceUnit = units.first ?? ""
            targetUnit = units.count > 1 ? units[1] : units.first ?? ""
        }
    }
    
    private func handleUnitTypeChange(_ newType: UnitConverter.UnitType) {
        hapticManager.trigger(.modeChange)
        
        // 重置输入和结果
        inputValue = "1"
        conversionResult = ""
        
        // 设置新类型的单位
        setupInitialUnits()
    }
    
    private func handleUnitChange() {
        // 单位变化时清空结果
        conversionResult = ""
    }
    
    private func performConversion() {
        guard !isConverting else { return }
        
        // 验证输入
        guard let value = Double(inputValue) else {
            showError("请输入有效的数字")
            return
        }
        
        guard !sourceUnit.isEmpty, !targetUnit.isEmpty else {
            showError("请选择源单位和目标单位")
            return
        }
        
        guard sourceUnit != targetUnit else {
            showError("源单位和目标单位不能相同")
            return
        }
        
        isConverting = true
        
        // 开始性能测量
        let measurement = performanceMonitor.startCalculationMeasurement("unit_conversion")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try unitManager.convert(
                    value,
                    unitType: selectedUnitType,
                    from: sourceUnit,
                    to: targetUnit
                )
                
                DispatchQueue.main.async {
                    conversionResult = result.formatted()
                    isConverting = false
                    measurement.end()
                    
                    // 成功反馈
                    hapticManager.trigger(.calculationSuccess)
                }
                
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                    isConverting = false
                    measurement.end()
                    
                    // 错误反馈
                    hapticManager.trigger(.calculationError)
                }
            }
        }
    }
    
    private func copyResult() {
        UIPasteboard.general.string = conversionResult
        hapticManager.trigger(.success)
        
        // 可以添加复制成功的提示
    }
    
    private func swapUnits() {
        let temp = sourceUnit
        sourceUnit = targetUnit
        targetUnit = temp
        
        // 如果有结果，重新计算
        if !conversionResult.isEmpty, let value = Double(inputValue) {
            performConversion()
        }
        
        hapticManager.trigger(.modeChange)
    }
    
    private func selectRecentConversion(_ record: ConversionRecord) {
        selectedUnitType = record.unitType
        inputValue = record.value.formatted()
        sourceUnit = record.sourceUnit
        targetUnit = record.targetUnit
        
        // 自动重新计算
        performConversion()
        
        hapticManager.trigger(.tabSwitch)
    }
    
    private func clearRecentConversions() {
        unitManager.clearRecentConversions()
        hapticManager.trigger(.success)
    }
    
    private func saveCurrentPreference() {
        unitManager.savePreference(for: selectedUnitType, source: sourceUnit, target: targetUnit)
        hapticManager.trigger(.success)
    }
    
    private func resetPreferences() {
        // 重置所有偏好
        for unitType in UnitConverter.UnitType.allCases {
            let units = unitManager.converter.availableUnits(for: unitType)
            if units.count >= 2 {
                unitManager.savePreference(for: unitType, source: units[0], target: units[1])
            }
        }
        
        setupInitialUnits()
        hapticManager.trigger(.success)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - 子视图

struct UnitTypeSelector: View {
    @Binding var selectedType: UnitConverter.UnitType
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择单位类型")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(UnitConverter.UnitType.allCases, id: \.self) { unitType in
                    UnitTypeButton(
                        unitType: unitType,
                        isSelected: selectedType == unitType
                    ) {
                        selectedType = unitType
                    }
                }
            }
        }
    }
}

struct UnitTypeButton: View {
    let unitType: UnitConverter.UnitType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: unitType.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(unitType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct InputSection: View {
    @Binding var value: String
    @Binding var sourceUnit: String
    @Binding var targetUnit: String
    let availableUnits: [String]
    let userPreference: (String, String)?
    let onUnitChange: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 数值输入
            VStack(alignment: .leading, spacing: 8) {
                Text("输入数值")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("输入数值", text: $value)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 32, weight: .light))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
            
            // 单位选择
            HStack(spacing: 16) {
                UnitPicker(
                    title: "从",
                    selection: $sourceUnit,
                    units: availableUnits,
                    onSelectionChange: onUnitChange
                )
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 40)
                
                UnitPicker(
                    title: "到",
                    selection: $targetUnit,
                    units: availableUnits,
                    onSelectionChange: onUnitChange
                )
            }
            
            // 用户偏好提示
            if let preference = userPreference,
               preference.0 == sourceUnit && preference.1 == targetUnit {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("已保存为偏好设置")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct UnitPicker: View {
    let title: String
    @Binding var selection: String
    let units: [String]
    let onSelectionChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker(title, selection: $selection) {
                ForEach(units, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .onChange(of: selection) { oldValue, newValue in
                onSelectionChange()
            }
        }
    }
}

struct ConversionButton: View {
    @Binding var isConverting: Bool
    let onConvert: () -> Void
    
    var body: some View {
        Button(action: onConvert) {
            HStack {
                Spacer()
                
                if isConverting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("开始换算")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            .frame(height: 56)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isConverting)
        .scaleEffect(isConverting ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isConverting)
    }
}

struct ResultSection: View {
    let result: String
    let sourceValue: String
    let sourceUnit: String
    let targetUnit: String
    let onCopy: () -> Void
    let onSwap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("换算结果")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // 结果显示
                Text(result)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                
                // 换算公式
                Text("\(sourceValue) \(sourceUnit) = \(result) \(targetUnit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 操作按钮
            HStack(spacing: 16) {
                Button(action: onCopy) {
                    Label("复制结果", systemImage: "doc.on.doc")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(10)
                }
                
                Button(action: onSwap) {
                    Label("交换单位", systemImage: "arrow.left.arrow.right")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct RecentConversionsSection: View {
    let conversions: [ConversionRecord]
    @Binding var showingAll: Bool
    let onSelect: (ConversionRecord) -> Void
    let onClear: () -> Void
    
    var displayConversions: [ConversionRecord] {
        showingAll ? conversions : Array(conversions.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近换算")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if conversions.count > 3 {
                    Button(showingAll ? "显示较少" : "显示全部") {
                        showingAll.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                Button("清除") {
                    onClear()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            ForEach(displayConversions) { record in
                RecentConversionRow(record: record) {
                    onSelect(record)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct RecentConversionRow: View {
    let record: ConversionRecord
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: record.unitType.iconName)
                    .foregroundColor(.blue)
                    .font(.body)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.description)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct UnitDescriptionSection: View {
    let unitType: UnitConverter.UnitType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("单位说明")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(UnitConverter().unitDescription(for: unitType))
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    UnitConversionView()
        .environmentObject(HapticFeedbackManager.shared)
        .environmentObject