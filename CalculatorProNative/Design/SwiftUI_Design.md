# SwiftUI界面设计文档

## 🎨 设计系统

### **颜色系统**
```swift
// 颜色定义 (iOS语义颜色)
extension Color {
    // 浅色模式
    static let systemBackground = Color(uiColor: .systemBackground)
    static let secondarySystemBackground = Color(uiColor: .secondarySystemBackground)
    static let label = Color(uiColor: .label)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
    static let systemBlue = Color(uiColor: .systemBlue)
    static let systemOrange = Color(uiColor: .systemOrange)
    static let systemRed = Color(uiColor: .systemRed)
    static let systemGray = Color(uiColor: .systemGray)
    static let systemGray2 = Color(uiColor: .systemGray2)
    static let systemGray5 = Color(uiColor: .systemGray5)
    static let systemGray6 = Color(uiColor: .systemGray6)
    
    // 计算器特定颜色
    static let calculatorButtonBackground = Color("CalculatorButtonBackground")
    static let scientificButtonBackground = Color("ScientificButtonBackground")
}
```

### **字体系统**
```swift
// 字体定义
extension Font {
    // 显示区域字体
    static let calculatorDisplay = Font.system(size: 60, weight: .light, design: .default)
    static let calculatorDisplaySmall = Font.system(size: 24, weight: .regular, design: .default)
    
    // 按钮字体
    static let calculatorButton = Font.system(size: 32, weight: .medium, design: .rounded)
    static let scientificButton = Font.system(size: 20, weight: .medium, design: .default)
    
    // 标签字体
    static let tabBarLabel = Font.system(size: 10, weight: .medium, design: .default)
}
```

## 📱 主界面设计

### **CalculatorView (主视图)**
```swift
struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        ZStack {
            // 背景
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 状态栏区域
                StatusBarView()
                
                // 显示区域
                DisplayView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                
                // 科学计算按钮行 (条件显示)
                if viewModel.isScientificMode {
                    ScientificButtonRow(viewModel: viewModel)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                
                // 基础按钮网格
                ButtonGridView(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                // 标签栏
                TabBarView(selectedTab: $viewModel.selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
    }
}
```

### **DisplayView (显示区域)**
```swift
struct DisplayView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // 计算表达式
            Text(viewModel.currentExpression)
                .font(.calculatorDisplaySmall)
                .foregroundColor(themeManager.secondaryLabelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // 当前显示值
            Text(viewModel.displayValue)
                .font(.calculatorDisplay)
                .foregroundColor(themeManager.labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // 模式指示器
            if viewModel.isScientificMode {
                Text("科学计算模式")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryLabelColor)
            }
        }
        .frame(height: 120)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackgroundColor)
        )
    }
}
```

### **ButtonGridView (按钮网格)**
```swift
struct ButtonGridView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    // 按钮布局定义
    private let buttonRows: [[CalculatorButton]] = [
        [
            CalculatorButton(type: .function, title: "AC", action: { viewModel.clear() }),
            CalculatorButton(type: .function, title: "+/-", action: { viewModel.toggleSign() }),
            CalculatorButton(type: .function, title: "%", action: { viewModel.percentage() }),
            CalculatorButton(type: .operator, title: "÷", action: { viewModel.performOperation(.divide) })
        ],
        [
            CalculatorButton(type: .number, title: "7", action: { viewModel.inputDigit("7") }),
            CalculatorButton(type: .number, title: "8", action: { viewModel.inputDigit("8") }),
            CalculatorButton(type: .number, title: "9", action: { viewModel.inputDigit("9") }),
            CalculatorButton(type: .operator, title: "×", action: { viewModel.performOperation(.multiply) })
        ],
        [
            CalculatorButton(type: .number, title: "4", action: { viewModel.inputDigit("4") }),
            CalculatorButton(type: .number, title: "5", action: { viewModel.inputDigit("5") }),
            CalculatorButton(type: .number, title: "6", action: { viewModel.inputDigit("6") }),
            CalculatorButton(type: .operator, title: "-", action: { viewModel.performOperation(.subtract) })
        ],
        [
            CalculatorButton(type: .number, title: "1", action: { viewModel.inputDigit("1") }),
            CalculatorButton(type: .number, title: "2", action: { viewModel.inputDigit("2") }),
            CalculatorButton(type: .number, title: "3", action: { viewModel.inputDigit("3") }),
            CalculatorButton(type: .operator, title: "+", action: { viewModel.performOperation(.add) })
        ],
        [
            CalculatorButton(type: .number, title: "0", action: { viewModel.inputDigit("0") }, isWide: true),
            CalculatorButton(type: .number, title: ".", action: { viewModel.inputDecimal() }),
            CalculatorButton(type: .equals, title: "=", action: { viewModel.performEquals() })
        ]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(buttonRows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row) { button in
                        CalculatorButtonView(button: button)
                    }
                }
            }
        }
    }
}
```

### **CalculatorButtonView (按钮组件)**
```swift
struct CalculatorButtonView: View {
    let button: CalculatorButton
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: button.action) {
            Text(button.title)
                .font(.calculatorButton)
                .frame(maxWidth: button.isWide ? .infinity : nil)
                .frame(width: button.isWide ? nil : 72, height: 72)
                .background(buttonBackground)
                .foregroundColor(buttonForegroundColor)
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(CalculatorButtonStyle())
    }
    
    private var buttonBackground: some View {
        switch button.type {
        case .number:
            return themeManager.numberButtonColor
        case .operator:
            return themeManager.operatorButtonColor
        case .function:
            return themeManager.functionButtonColor
        case .equals:
            return themeManager.equalsButtonColor
        }
    }
    
    private var buttonForegroundColor: Color {
        switch button.type {
        case .number:
            return themeManager.labelColor
        case .operator, .equals:
            return .white
        case .function:
            return themeManager.labelColor
        }
    }
}

// 按钮样式
struct CalculatorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

### **ScientificButtonRow (科学计算按钮行)**
```swift
struct ScientificButtonRow: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private let scientificButtons: [[ScientificButton]] = [
        [
            ScientificButton(title: "sin", action: { viewModel.performScientificFunction("sin") }),
            ScientificButton(title: "cos", action: { viewModel.performScientificFunction("cos") }),
            ScientificButton(title: "tan", action: { viewModel.performScientificFunction("tan") }),
            ScientificButton(title: "log", action: { viewModel.performScientificFunction("log") }),
            ScientificButton(title: "ln", action: { viewModel.performScientificFunction("ln") })
        ],
        [
            ScientificButton(title: "√", action: { viewModel.performScientificFunction("sqrt") }),
            ScientificButton(title: "x²", action: { viewModel.performScientificFunction("square") }),
            ScientificButton(title: "π", action: { viewModel.inputConstant("π") }),
            ScientificButton(title: "e", action: { viewModel.inputConstant("e") }),
            ScientificButton(title: "xʸ", action: { viewModel.performScientificFunction("power") })
        ]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(scientificButtons, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row) { button in
                        ScientificButtonView(button: button)
                    }
                }
            }
        }
    }
}

struct ScientificButtonView: View {
    let button: ScientificButton
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: button.action) {
            Text(button.title)
                .font(.scientificButton)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(themeManager.scientificButtonColor)
                .foregroundColor(themeManager.labelColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScientificButtonStyle())
    }
}
```

### **TabBarView (标签栏)**
```swift
struct TabBarView: View {
    @Binding var selectedTab: CalculatorTab
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            ForEach(CalculatorTab.allCases) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: { selectedTab = tab }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackgroundColor)
        )
    }
}

struct TabBarItem: View {
    let tab: CalculatorTab
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20))
                
                Text(tab.title)
                    .font(.tabBarLabel)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? themeManager.accentColor : themeManager.secondaryLabelColor)
        }
    }
}
```

## 🎯 视图模型设计

### **CalculatorViewModel**
```swift
@MainActor
class CalculatorViewModel: ObservableObject {
    // 计算引擎
    private let calculator = CalculatorPro()
    
    // 发布属性
    @Published var displayValue: String = "0"
    @Published var currentExpression: String = ""
    @Published var isScientificMode: Bool = false
    @Published var selectedTab: CalculatorTab = .calculator
    
    // 计算历史
    @Published var calculationHistory: [CalculationRecord] = []
    
    // 设置
    @Published var settings = CalculatorSettings()
    
    init() {
        loadHistory()
        updateDisplay()
    }
    
    // MARK: - 基础计算
    
    func inputDigit(_ digit: Character) {
        do {
            try calculator.inputDigit(digit)
            updateDisplay()
        } catch {
            handleError(error)
        }
    }
    
    func performOperation(_ operation: Calculator.Operation) {
        do {
            try calculator.performBasicOperation(operation)
            updateDisplay()
        } catch {
            handleError(error)
        }
    }
    
    func performEquals() {
        do {
            _ = try calculator.performEquals()
            updateDisplay()
            loadHistory()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 科学计算
    
    func performScientificFunction(_ function: String) {
        do {
            let currentValue = Double(displayValue) ?? 0
            _ = try calculator.performScientificFunction(function, value: currentValue)
            updateDisplay()
            loadHistory()
        } catch {
            handleError(error)
        }
    }
    
    func inputConstant(_ constant: String) {
        if let constantValue = calculator.getConstant(constant) {
            // 将常数输入到显示区域
            displayValue = String(constantValue)
        }
    }
    
    // MARK: - 其他操作
    
    func clear() {
        calculator.clearAll()
        updateDisplay()
    }
    
    func toggleSign() {
        do {
            try calculator.performBasicOperation(.toggleSign)
            updateDisplay()
        } catch {
            handleError(error)
        }
    }
    
    func percentage() {
        do {
            try calculator.performBasicOperation(.percent)
            updateDisplay()
        } catch {
            handleError(error)
        }
    }
    
    func inputDecimal() {
        // 处理小数点输入
        if !displayValue.contains(".") {
            displayValue += "."
        }
    }
    
    // MARK: - 历史记录
    
    private func loadHistory() {
        calculationHistory = calculator.getCalculationHistory()
    }
    
    func deleteHistoryRecord(_ id: UUID) {
        calculator.deleteHistoryRecord(id)
        loadHistory()
    }
    
    func clearHistory() {
        calculator.clearHistory()
        loadHistory()
    }
    
    // MARK: - 辅助方法
    
    private func updateDisplay() {
        displayValue = formatNumber(calculator.displayValue)
        currentExpression = calculator.currentExpression
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = settings.decimalPlaces
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale.current
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func handleError(_ error: Error) {
        let errorDescription = calculator.getErrorDescription(error)
        // 在实际应用中，这里应该显示错误提示
        print("计算错误: \(errorDescription)")
    }
}
```

### **主题管理器**
```swift
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var accentColor: Color = .blue
    
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    // 动态颜色
    var backgroundColor: Color {
        isDarkMode ? .black : .white
    }
    
    var secondaryBackgroundColor: Color {
        isDarkMode ? Color(white: 0.1) : Color(white: 0.95)
    }
    
    var labelColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryLabelColor: Color {
        isDarkMode ? Color(white: 0.6) : Color(white: 0.4)
    }
    
    // 按钮颜色
    var numberButtonColor: Color {
        isDarkMode ? Color(white: 0.2) : Color(white: 0.9)
    }
    
    var operatorButtonColor: Color {
        accentColor
    }
    
    var functionButtonColor: Color {
        isDarkMode ? Color(white: 0.3) : Color(white: 0.8)
    }
    
    var equalsButtonColor: Color {
        accentColor
    }
    
    var scientificButtonColor: Color {
        isDarkMode ? Color(white: 0.25) : Color(white: 0.85)
    }
}
```

## 🎨 动画设计

### **转场动画**
```swift
// 科学计算模式切换动画
struct ScientificModeTransition: ViewModifier {
    let isScientificMode: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isScientificMode ? 1 : 0.9)
            .opacity(isScientificMode ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isScientificMode)
    }
}

// 按钮点击动画
struct ButtonPressAnimation: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed