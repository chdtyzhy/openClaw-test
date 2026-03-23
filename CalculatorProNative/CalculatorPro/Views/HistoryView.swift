//
//  HistoryView.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var calculatorManager: CalculatorManager
    @StateObject private var historyManager = HistoryManager()
    @State private var selectedHistoryItems = Set<CalculationHistory.ID>()
    @State private var isEditing = false
    @State private var searchText = ""
    @State private var showingClearConfirmation = false
    
    var filteredHistory: [CalculationHistory] {
        if searchText.isEmpty {
            return historyManager.history
        } else {
            return historyManager.history.filter { history in
                history.expression.localizedCaseInsensitiveContains(searchText) ||
                history.result.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if historyManager.history.isEmpty {
                    EmptyHistoryView()
                } else {
                    HistoryListView(
                        history: filteredHistory,
                        selectedItems: $selectedHistoryItems,
                        isEditing: $isEditing,
                        onDelete: deleteSelectedItems,
                        onSelect: selectHistoryItem
                    )
                }
            }
            .navigationTitle("计算历史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing {
                        Button("取消") {
                            withAnimation {
                                isEditing = false
                                selectedHistoryItems.removeAll()
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !historyManager.history.isEmpty {
                        if isEditing {
                            Button("删除", role: .destructive) {
                                showingClearConfirmation = true
                            }
                            .disabled(selectedHistoryItems.isEmpty)
                        } else {
                            Button(action: toggleEditing) {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                    
                    if !isEditing {
                        Menu {
                            Button(action: exportHistory) {
                                Label("导出历史", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(role: .destructive, action: clearAllHistory) {
                                Label("清除所有", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜索计算历史")
            .alert("确认删除", isPresented: $showingClearConfirmation) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteSelectedItems()
                }
            } message: {
                if selectedHistoryItems.count == 1 {
                    Text("确定要删除这条历史记录吗？")
                } else {
                    Text("确定要删除选中的 \(selectedHistoryItems.count) 条历史记录吗？")
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func toggleEditing() {
        withAnimation {
            isEditing.toggle()
            if !isEditing {
                selectedHistoryItems.removeAll()
            }
        }
    }
    
    private func deleteSelectedItems() {
        historyManager.deleteItems(with: Array(selectedHistoryItems))
        selectedHistoryItems.removeAll()
        isEditing = false
    }
    
    private func selectHistoryItem(_ history: CalculationHistory) {
        // 将历史记录应用到计算器
        // 这里可以添加将历史记录应用到当前计算器的逻辑
    }
    
    private func exportHistory() {
        // 导出历史记录
        historyManager.exportHistory()
    }
    
    private func clearAllHistory() {
        historyManager.clearAll()
    }
}

// MARK: - 历史记录列表
struct HistoryListView: View {
    let history: [CalculationHistory]
    @Binding var selectedItems: Set<CalculationHistory.ID>
    @Binding var isEditing: Bool
    let onDelete: () -> Void
    let onSelect: (CalculationHistory) -> Void
    
    var body: some View {
        List(selection: $selectedItems) {
            ForEach(history) { item in
                HistoryRow(history: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isEditing {
                            if selectedItems.contains(item.id) {
                                selectedItems.remove(item.id)
                            } else {
                                selectedItems.insert(item.id)
                            }
                        } else {
                            onSelect(item)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            // 删除单条记录
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
    }
}

// MARK: - 历史记录行
struct HistoryRow: View {
    let history: CalculationHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(history.expression)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(history.result)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text(history.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let mode = history.mode {
                    Text(mode)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 空历史视图
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .padding()
            
            Text("暂无计算历史")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("开始计算，您的计算历史将在这里显示")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - 历史记录管理器
class HistoryManager: ObservableObject {
    @Published var history: [CalculationHistory] = []
    
    init() {
        loadHistory()
    }
    
    private func loadHistory() {
        // 从UserDefaults或Core Data加载历史记录
        // 这里使用模拟数据
        history = [
            CalculationHistory(
                expression: "sin(45°)",
                result: "0.7071067812",
                mode: "科学计算"
            ),
            CalculationHistory(
                expression: "123 + 456",
                result: "579",
                mode: "基础计算"
            ),
            CalculationHistory(
                expression: "√(25)",
                result: "5",
                mode: "科学计算"
            ),
            CalculationHistory(
                expression: "π × 2",
                result: "6.283185307",
                mode: "科学计算"
            )
        ]
    }
    
    func addHistory(_ item: CalculationHistory) {
        history.insert(item, at: 0)
        saveHistory()
    }
    
    func deleteItems(with ids: [CalculationHistory.ID]) {
        history.removeAll { ids.contains($0.id) }
        saveHistory()
    }
    
    func clearAll() {
        history.removeAll()
        saveHistory()
    }
    
    func exportHistory() {
        // 导出历史记录为JSON或CSV
        // 实现导出逻辑
    }
    
    private func saveHistory() {
        // 保存历史记录到持久化存储
    }
}

// MARK: - 历史记录模型
struct CalculationHistory: Identifiable, Hashable {
    let id = UUID()
    let expression: String
    let result: String
    let timestamp = Date()
    let mode: String?
    
    init(expression: String, result: String, mode: String? = nil) {
        self.expression = expression
        self.result = result
        self.mode = mode
    }
}

#Preview {
    HistoryView()
        .environmentObject(CalculatorManager())
}