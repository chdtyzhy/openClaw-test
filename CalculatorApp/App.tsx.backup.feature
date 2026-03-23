import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  StatusBar,
  Platform,
  Dimensions,
  ScrollView,
  Modal,
  TextInput,
  Alert,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

// iOS语义颜色定义
const Colors = {
  // 浅色模式
  light: {
    systemBackground: '#FFFFFF',
    secondarySystemBackground: '#F2F2F7',
    tertiarySystemBackground: '#FFFFFF',
    label: '#000000',
    secondaryLabel: 'rgba(60,60,67,0.6)',
    systemBlue: '#007AFF',
    systemOrange: '#FF9500',
    systemRed: '#FF3B30',
    systemGray: '#8E8E93',
    systemGray2: '#C6C6C8',
    systemGray5: '#E5E5EA',
    systemGray6: '#F2F2F7',
  },
  // 深色模式
  dark: {
    systemBackground: '#000000',
    secondarySystemBackground: '#1C1C1E',
    tertiarySystemBackground: '#2C2C2E',
    label: '#FFFFFF',
    secondaryLabel: 'rgba(235,235,245,0.6)',
    systemBlue: '#0A84FF',
    systemOrange: '#FF9F0A',
    systemRed: '#FF453A',
    systemGray: '#8E8E93',
    systemGray2: '#38383A',
    systemGray5: '#3A3A3C',
    systemGray6: '#2C2C2E',
  },
};

// 计算历史记录类型
interface CalculationHistory {
  id: string;
  expression: string;
  result: string;
  timestamp: Date;
}

// 计算器按钮类型
type ButtonType = 'number' | 'operator' | 'function' | 'equals' | 'clear';

interface CalculatorButton {
  label: string;
  type: ButtonType;
  span?: number; // 占据的列数
}

// 计算器按钮布局
const buttons: CalculatorButton[][] = [
  [
    { label: 'AC', type: 'clear' },
    { label: '+/-', type: 'function' },
    { label: '%', type: 'function' },
    { label: '÷', type: 'operator' },
  ],
  [
    { label: '7', type: 'number' },
    { label: '8', type: 'number' },
    { label: '9', type: 'number' },
    { label: '×', type: 'operator' },
  ],
  [
    { label: '4', type: 'number' },
    { label: '5', type: 'number' },
    { label: '6', type: 'number' },
    { label: '-', type: 'operator' },
  ],
  [
    { label: '1', type: 'number' },
    { label: '2', type: 'number' },
    { label: '3', type: 'number' },
    { label: '+', type: 'operator' },
  ],
  [
    { label: '0', type: 'number', span: 2 },
    { label: '.', type: 'number' },
    { label: '=', type: 'equals' },
  ],
];

// 历史记录存储键
const HISTORY_STORAGE_KEY = '@calculator_history';

export default function App() {
  // 计算器状态
  const [displayValue, setDisplayValue] = useState('0');
  const [previousValue, setPreviousValue] = useState<string | null>(null);
  const [operator, setOperator] = useState<string | null>(null);
  const [waitingForNewValue, setWaitingForNewValue] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isScientificMode, setIsScientificMode] = useState(false);
  
  // 历史记录状态
  const [history, setHistory] = useState<CalculationHistory[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  const [activeTab, setActiveTab] = useState<'calculator' | 'history' | 'settings'>('calculator');

  const colors = isDarkMode ? Colors.dark : Colors.light;

  // 加载历史记录
  useEffect(() => {
    loadHistory();
  }, []);

  // 加载历史记录
  const loadHistory = async () => {
    try {
      const storedHistory = await AsyncStorage.getItem(HISTORY_STORAGE_KEY);
      if (storedHistory) {
        const parsedHistory = JSON.parse(storedHistory);
        // 转换timestamp字符串回Date对象
        const historyWithDates = parsedHistory.map((item: any) => ({
          ...item,
          timestamp: new Date(item.timestamp),
        }));
        setHistory(historyWithDates);
      }
    } catch (error) {
      console.error('加载历史记录失败:', error);
    }
  };

  // 保存历史记录
  const saveHistory = async (expression: string, result: string) => {
    try {
      const newHistoryItem: CalculationHistory = {
        id: Date.now().toString(),
        expression,
        result,
        timestamp: new Date(),
      };

      const updatedHistory = [newHistoryItem, ...history.slice(0, 49)]; // 最多保存50条
      setHistory(updatedHistory);
      
      await AsyncStorage.setItem(HISTORY_STORAGE_KEY, JSON.stringify(updatedHistory));
    } catch (error) {
      console.error('保存历史记录失败:', error);
    }
  };

  // 清除所有历史记录
  const clearAllHistory = async () => {
    Alert.alert(
      '确认清除',
      '确定要清除所有历史记录吗？',
      [
        { text: '取消', style: 'cancel' },
        {
          text: '清除',
          style: 'destructive',
          onPress: async () => {
            try {
              await AsyncStorage.removeItem(HISTORY_STORAGE_KEY);
              setHistory([]);
            } catch (error) {
              console.error('清除历史记录失败:', error);
            }
          },
        },
      ]
    );
  };

  // 删除单条历史记录
  const deleteHistoryItem = async (id: string) => {
    try {
      const updatedHistory = history.filter(item => item.id !== id);
      setHistory(updatedHistory);
      await AsyncStorage.setItem(HISTORY_STORAGE_KEY, JSON.stringify(updatedHistory));
    } catch (error) {
      console.error('删除历史记录失败:', error);
    }
  };

  // 重用历史记录
  const reuseHistory = (result: string) => {
    setDisplayValue(result);
    setShowHistory(false);
    setActiveTab('calculator');
  };

  // 输入数字
  const handleNumberPress = (num: string) => {
    if (waitingForNewValue) {
      setDisplayValue(num);
      setWaitingForNewValue(false);
    } else {
      setDisplayValue(displayValue === '0' ? num : displayValue + num);
    }
  };

  // 处理操作
  const handleOperatorPress = (op: string) => {
    const inputValue = parseFloat(displayValue);
    
    if (previousValue === null) {
      setPreviousValue(displayValue);
    } else if (operator) {
      const prevValue = parseFloat(previousValue);
      let result = prevValue;
      
      switch (operator) {
        case '+': result = prevValue + inputValue; break;
        case '-': result = prevValue - inputValue; break;
        case '×': result = prevValue * inputValue; break;
        case '÷': result = prevValue / inputValue; break;
      }
      
      setDisplayValue(String(result));
      setPreviousValue(String(result));
    }
    
    setWaitingForNewValue(true);
    setOperator(op);
  };

  // 处理等号
  const handleEqualsPress = () => {
    const inputValue = parseFloat(displayValue);
    
    if (previousValue !== null && operator) {
      const prevValue = parseFloat(previousValue);
      let result = prevValue;
      
      switch (operator) {
        case '+': result = prevValue + inputValue; break;
        case '-': result = prevValue - inputValue; break;
        case '×': result = prevValue * inputValue; break;
        case '÷': result = prevValue / inputValue; break;
      }
      
      const expression = `${previousValue} ${getOperatorSymbol(operator)} ${displayValue}`;
      const resultStr = String(result);
      
      setDisplayValue(resultStr);
      setPreviousValue(null);
      setOperator(null);
      setWaitingForNewValue(true);
      
      // 保存到历史记录
      saveHistory(expression, resultStr);
    }
  };

  // 清除计算器
  const handleClearPress = () => {
    setDisplayValue('0');
    setPreviousValue(null);
    setOperator(null);
    setWaitingForNewValue(false);
  };

  // 切换正负
  const toggleSign = () => {
    const newValue = String(-parseFloat(displayValue));
    setDisplayValue(newValue);
  };

  // 计算百分比
  const calculatePercent = () => {
    const newValue = String(parseFloat(displayValue) / 100);
    setDisplayValue(newValue);
  };

  // 添加小数点
  const addDecimal = () => {
    if (!displayValue.includes('.')) {
      const newValue = displayValue + '.';
      setDisplayValue(newValue);
    }
  };

  // 处理功能按钮
  const handleFunctionPress = (func: string) => {
    switch (func) {
      case 'AC':
        handleClearPress();
        break;
      case '+/-':
        toggleSign();
        break;
      case '%':
        calculatePercent();
        break;
    }
  };

  // 处理科学计算函数
  const handleScientificFunction = (func: string) => {
    const value = parseFloat(displayValue);
    let result: number;
    let expression = '';
    
    try {
      switch (func) {
        case 'sin':
          result = Math.sin(value * Math.PI / 180); // 角度制
          expression = `sin(${value}°)`;
          break;
        case 'cos':
          result = Math.cos(value * Math.PI / 180);
          expression = `cos(${value}°)`;
          break;
        case 'tan':
          result = Math.tan(value * Math.PI / 180);
          expression = `tan(${value}°)`;
          break;
        case 'log':
          result = Math.log10(value);
          expression = `log(${value})`;
          break;
        case 'ln':
          result = Math.log(value);
          expression = `ln(${value})`;
          break;
        case '√':
          result = Math.sqrt(value);
          expression = `√(${value})`;
          break;
        case 'x²':
          result = Math.pow(value, 2);
          expression = `(${value})²`;
          break;
        case 'π':
          result = Math.PI;
          expression = 'π';
          break;
        case 'e':
          result = Math.E;
          expression = 'e';
          break;
        default:
          return;
      }
      
      if (isNaN(result) || !isFinite(result)) {
        Alert.alert('计算错误', '无法计算该表达式');
        return;
      }
      
      const resultStr = String(result);
      setDisplayValue(resultStr);
      saveHistory(expression, resultStr);
    } catch (error) {
      Alert.alert('计算错误', '执行计算时发生错误');
    }
  };

  // 处理按钮点击
  const handleButtonPress = (button: CalculatorButton) => {
    switch (button.type) {
      case 'number':
        handleNumberPress(button.label);
        break;
      case 'operator':
        handleOperatorPress(button.label);
        break;
      case 'equals':
        handleEqualsPress();
        break;
      case 'clear':
      case 'function':
        handleFunctionPress(button.label);
        break;
    }
  };

  // 获取操作符符号
  const getOperatorSymbol = (op: string) => {
    const symbols = {
      'add': '+',
      'subtract': '-',
      'multiply': '×',
      'divide': '÷',
      '+': '+',
      '-': '-',
      '×': '×',
      '÷': '÷',
    };
    return symbols[op] || op;
  };

  // 格式化时间
  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('zh-CN', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  // 获取按钮样式
  const getButtonStyle = (type: ButtonType) => {
    switch (type) {
      case 'number':
        return [styles.button, styles.numberButton, { backgroundColor: colors.systemGray6 }];
      case 'operator':
        return [styles.button, styles.operatorButton, { backgroundColor: colors.systemBlue }];
      case 'equals':
        return [styles.button, styles.equalsButton, { backgroundColor: colors.systemOrange }];
      case 'function':
        return [styles.button, styles.functionButton, { backgroundColor: colors.systemGray5 }];
      case 'clear':
        return [styles.button, styles.clearButton, { backgroundColor: colors.systemRed }];
      default:
        return [styles.button, { backgroundColor: colors.systemGray6 }];
    }
  };

  // 获取按钮文字样式
  const getButtonTextStyle = (type: ButtonType) => {
    switch (type) {
      case 'operator':
      case 'equals':
      case 'clear':
        return [styles.buttonText, styles.lightButtonText];
      default:
        return [styles.buttonText, { color: colors.label }];
    }
  };

  // 渲染计算器界面
  const renderCalculator = () => (
    <>
      {/* 顶部控制栏 */}
      <View style={styles.topControls}>
        <TouchableOpacity
          style={styles.themeToggle}
          onPress={() => setIsDarkMode(!isDarkMode)}
        >
          <Text style={{ color: colors.systemBlue }}>
            {isDarkMode ? '🌙' : '☀️'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.modeToggle, { backgroundColor: colors.systemBlue }]}
          onPress={() => setIsScientificMode(!isScientificMode)}
        >
          <Text style={styles.lightButtonText}>
            {isScientificMode ? '基础模式 🔢' : '科学模式 🔬'}
          </Text>
        </TouchableOpacity>
      </View>

      {/* 结果显示区域 */}
      <View style={styles.displayContainer}>
        <Text style={[styles.previousText, { color: colors.secondaryLabel }]}>
          {previousValue} {operator && getOperatorSymbol(operator)}
        </Text>
        <Text style={[styles.displayText, { color: colors.label }]}>
          {displayValue}
        </Text>
        <Text style={[styles.modeIndicator, { color: colors.secondaryLabel }]}>
          {isScientificMode ? '科学计算模式' : '基础计算模式'}
        </Text>
      </View>

      {/* 科学计算按钮行 */}
      {isScientificMode && (
        <View style={styles.scientificRow}>
          {['sin', 'cos', 'tan', 'log', 'ln', '√', 'x²', 'π', 'e'].map((func) => (
            <TouchableOpacity
              key={func}
              style={[styles.scientificButton, { backgroundColor: colors.systemGray5 }]}
              onPress={() => handleScientificFunction(func)}
            >
              <Text style={[styles.scientificButtonText, { color: colors.label }]}>
                {func}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* 按钮网格 */}
      <View style={styles.buttonsContainer}>
        {buttons.map((row, rowIndex) => (
          <View key={rowIndex} style={styles.row}>
            {row.map((button, colIndex) => (
              <TouchableOpacity
                key={colIndex}
                style={[
                  ...getButtonStyle(button.type),
                  button.span === 2 && styles.doubleWidthButton,
                ]}
                onPress={() => handleButtonPress(button)}
                activeOpacity={0.7}
              >
                <Text style={getButtonTextStyle(button.type)}>
                  {button.label}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        ))}
      </View>
    </>
  );

  // 渲染历史记录界面
  const renderHistory = () => (
    <View style={styles.historyContainer}>
      <View style={styles.historyHeader}>
        <Text style={[styles.historyTitle, { color: colors.label }]}>
          计算历史 ({history.length})
        </Text>
        {history.length > 0 && (
          <TouchableOpacity
            style={styles.clearHistoryButton}
            onPress={clearAllHistory}
          >
            <Text style={{ color: colors.systemRed, fontSize: 14, fontWeight: '500' }}>
              清除全部
            </Text>
          </TouchableOpacity>
        )}
      </View>

      {history.length === 0 ? (
        <View style={styles.emptyHistory}>
          <Text style={[styles.emptyHistoryText, { color: colors.secondaryLabel }]}>
            暂无计算历史
          </Text>
          <Text style={[styles.emptyHistorySubtext, { color: colors.secondaryLabel }]}>
            开始计算后，历史记录将显示在这里
          </Text>
        </View>
      ) : (
        <ScrollView style={styles.historyList}>
          {history.map((item) => (
            <TouchableOpacity
              key={item.id}
              style={[styles.historyItem, { backgroundColor: colors.secondarySystemBackground }]}
              onPress={() => reuseHistory(item.result)}
              onLongPress={() => deleteHistoryItem(item.id)}
            >
              <View style={styles.historyItemContent}>
                <Text style={[styles.historyExpression, { color: colors.label }]}>
                  {item.expression} =
                </Text>
                <Text style={[styles.historyResult, { color: colors.systemBlue }]}>
                  {item.result}
                </Text>
              </View>
              <Text style={[styles.historyTime, { color: colors.secondaryLabel }]}>
                {formatTime(item.timestamp)}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      )}
    </View>
  );

  // 渲染设置界面
  const renderSettings = () => (
    <View style={styles.settingsContainer}>
      <Text style={[styles.settingsTitle, { color: colors.label }]}>
        设置
      </Text>
      
      <View style={[styles.settingItem, { backgroundColor: colors.secondarySystemBackground }]}>
        <Text style={[styles.settingLabel, { color: colors.label }]}>主题模式</Text>
        <TouchableOpacity
          style={[styles.themeToggleButton, { backgroundColor: colors.systemBlue }]}
          onPress={() => setIsDarkMode(!isDarkMode)}
        >
          <Text style={styles.lightButtonText}>
            {isDarkMode ? '切换到浅色模式' : '切换到深色模式'}
          </Text>
        </TouchableOpacity>
      </View>

      <View style={[styles.settingItem, { backgroundColor: colors.secondarySystemBackground }]}>
        <Text style={[styles.settingLabel, { color: colors.label }]}>历史记录</Text>
        <Text style={[styles.settingValue, { color: colors.secondaryLabel }]}>
          {history.length} 条记录
        </Text>
      </View>

      <View style={[styles.settingItem, { backgroundColor: colors.secondarySystemBackground }]}>
        <Text style={[styles.settingLabel, { color: colors.label }]}>版本信息</Text>
        <Text style={[styles.settingValue, { color: colors.secondaryLabel }]}>
          Calculator Pro v1.0.0
        </Text>
      </View>

      <TouchableOpacity
        style={[styles.clearHistoryButton, styles.clearHistoryButtonFull]}
        onPress={clearAllHistory}
      >
        <Text style={{ color: colors.systemRed, fontSize: 16, fontWeight: '600' }}>
          清除所有历史记录
        </Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.systemBackground }]}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      
      {/* 主内容区域 */}
      <View style={styles.mainContent}>
        {activeTab === 'calculator' && renderCalculator()}
        {activeTab === 'history' && renderHistory()}
        {activeTab === 'settings' && renderSettings()}
      </View>

      {/* 标签栏 */}
      <View style={[styles.tabBar, { backgroundColor: colors.secondarySystemBackground }]}>
        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => setActiveTab('calculator')}
        >
          <Text style={[
            styles.tabIcon,
            { color: activeTab === 'calculator' ? colors.systemBlue : colors.secondaryLabel }
          ]}>
            🧮
          </Text>
          <Text style={[
            styles.tabText,
            { color: activeTab === 'calculator' ? colors.systemBlue : colors.secondaryLabel }
          ]}>
            计算器
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => setActiveTab('history')}
        >
          <Text style={[
            styles.tabIcon,
            { color: activeTab === 'history' ? colors.systemBlue : colors.secondaryLabel }
          ]}>
            📊
          </Text>
          <Text style={[
            styles.tabText,
            { color: activeTab === 'history' ? colors.systemBlue : colors.secondaryLabel }
          ]}>
            历史
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => setActiveTab('settings')}
        >
          <Text style={[
            styles.tabIcon,
            { color: activeTab === 'settings' ? colors.systemBlue : colors.secondaryLabel }
          ]}>
            ⚙️
          </Text>
          <Text style={[
            styles.tabText,
            { color: activeTab === 'settings' ? colors.systemBlue : colors.secondaryLabel }
          ]}>
            设置
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const { width } = Dimensions.get('window');
const buttonSize = (width - 80) / 4;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0,
  },
  mainContent: {
    flex: 1,
  },
  topControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 16,
  },
  themeToggle: {
    padding: 8,
  },
  modeToggle: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  displayContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
    paddingHorizontal: 32,
    paddingBottom: 32,
    maxHeight: 200,
  },
  displayText: {
    fontSize: 60,
    fontFamily: 'SF Pro Display',
    fontWeight: '600',
    textAlign: 'right',
  },
  modeIndicator: {
    fontSize: 14,
    fontFamily: 'SF Pro Text',
    fontWeight: '500',
    marginTop: 8,
    textAlign: 'right',
  },
  previousText: {
    fontSize: 20,
    fontFamily: 'SF Pro Text',
    fontWeight: '400',
    marginBottom: 8,
    textAlign: 'right',
  },
  scientificRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  scientificButton: {
    width: '10%',
    minWidth: 60,
    height: 40,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    margin: 4,
  },
  scientificButtonText: {
    fontSize: 14,
    fontFamily: 'SF Pro Text',
    fontWeight: '500',
  },
  buttonsContainer: {
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  button: {
    width: buttonSize,
    height: buttonSize,
    borderRadius: buttonSize / 2,
    justifyContent: 'center',
    alignItems: 'center',
  },
  doubleWidthButton: {
    width: buttonSize * 2 + 8,
  },
  buttonText: {
    fontSize: 24,
    fontFamily: 'SF Pro Text',
    fontWeight: '500',
  },
  lightButtonText: {
    color: '#FFFFFF',
  },
  numberButton: {},
  operatorButton: {},
  equalsButton: {},
  functionButton: {},
  clearButton: {},
  // 历史记录样式
  historyContainer: {
    flex: 1,
    padding: 16,
  },
  historyHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0,0,0,0.1)',
  },
  historyTitle: {
    fontSize: 24,
    fontWeight: '700',
    fontFamily: 'SF Pro Display',
  },
  clearHistoryButton: {
    padding: 8,
  },
  clearHistoryButtonFull: {
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 20,
    borderWidth: 1,
    borderColor: 'rgba(255,59,48,0.3)',
  },
  emptyHistory: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyHistoryText: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 8,
  },
  emptyHistorySubtext: {
    fontSize: 14,
    textAlign: 'center',
    paddingHorizontal: 40,
  },
  historyList: {
    flex: 1,
  },
  historyItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  historyItemContent: {
    flex: 1,
  },
  historyExpression: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 4,
  },
  historyResult: {
    fontSize: 20,
    fontWeight: '700',
  },
  historyTime: {
    fontSize: 12,
    fontWeight: '500',
  },
  // 设置样式
  settingsContainer: {
    flex: 1,
    padding: 16,
  },
  settingsTitle: {
    fontSize: 24,
    fontWeight: '700',
    fontFamily: 'SF Pro Display',
    marginBottom: 24,
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  settingLabel: {
    fontSize: 16,
    fontWeight: '500',
  },
  settingValue: {
    fontSize: 14,
    fontWeight: '500',
  },
  themeToggleButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  // 标签栏样式
  tabBar: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    height: 49,
    borderTopWidth: 1,
    borderTopColor: 'rgba(0,0,0,0.1)',
  },
  tabItem: {
    alignItems: 'center',
    padding: 8,
    flex: 1,
  },
  tabIcon: {
    fontSize: 20,
    marginBottom: 4,
  },
  tabText: {
    fontSize: 12,
    fontWeight: '500',
  },
});