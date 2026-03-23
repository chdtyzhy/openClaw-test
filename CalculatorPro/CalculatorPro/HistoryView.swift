//
//  HistoryView.swift
//  历史记录视图
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var calculator: SimpleCalculator
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if calculator.history.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("计算历史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !calculator.history.isEmpty {
                        Button("清空") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("清空历史记录", isPresented: $showingClearAlert) {
                Button("取消", role: .cancel) { }
                Button("清空", role: .destructive) {
                    calculator.clearHistory()
                }
            } message: {
                Text("确定要清空所有历史记录吗？此操作无法撤销。")
            }
        }
    }
    
    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无历史记录")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("开始计算后，这里会显示您的计算历史")
                .font(.body)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - 历史记录列表
    private var historyListView: some View {
        List {
            ForEach(calculator.history) { item in
                HistoryRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        calculator.useHistoryItem(item)
                        dismiss()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            if let index = calculator.history.firstIndex(where: { $0.id == item.id }) {
                                calculator.history.remove(at: index)
                            }
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - 历史记录行
struct HistoryRow: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 表达式
            Text(item.expression)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
            
            HStack {
                // 结果
                Text("= \(item.result)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 时间
                Text(formatTime(item.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 预览
#Preview {
    let calculator = SimpleCalculator()
    
    // 添加一些测试数据
    let testCalculator = SimpleCalculator()
    testCalculator.history = [
        HistoryItem(expression: "123 + 456", result: "579"),
        HistoryItem(expression: "789 × 2", result: "1,578"),
        HistoryItem(expression: "100 ÷ 25", result: "4"),
        HistoryItem(expression: "50 - 30", result: "20"),
        HistoryItem(expression: "√(144)", result: "12")
    ]
    
    return HistoryView(calculator: testCalculator)
}