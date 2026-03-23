# 开发上下文 - 本地使用场景

## 开发者环境
- **姓名**: 文源
- **系统**: macOS 26.3.1 (a) (25D771280a)
- **Xcode**: Version 26.2 (17C52)
- **Shell**: zsh (默认)
- **Git**: 已配置

## 技术偏好
### ✅ 使用
- SwiftUI + Combine
- 纯 Swift 实现
- Git 版本控制
- 简化配置

### ❌ 避免
- Swift Package Manager (SPM)
- 复杂的 CocoaPods 配置（当前有问题）
- Objective-C 混编（当前有问题）
- 复杂的项目设置

### ⚠️ 注意事项
- Combine 框架导入需要正确配置
- 使用 `.xcodeproj` 而非 `.xcworkspace`（除非修复 CocoaPods）
- iOS 17+ 兼容性

## 项目历史
### 已解决的问题
1. **ObservableObject 协议错误** - 已修复，使用纯 Swift
2. **@Published 导入错误** - 已修复，正确导入 Combine
3. **Objective-C 兼容性** - 已移除混编代码
4. **CocoaPods 依赖** - 已暂时移除，使用纯 Swift

### 当前状态
- 简化版计算器可编译运行
- 基本功能：加减乘除、清零
- 无第三方依赖
- 代码简洁

## 下次开发考虑
### 功能优先级
1. **基础功能完善**
   - 百分比计算
   - 正负号切换
   - 退格删除

2. **界面优化**
   - 更好的按钮布局
   - 主题支持（浅色/深色）
   - 历史记录显示

3. **高级功能**
   - 科学计算（平方根、幂运算等）
   - 内存功能（M+/M-/MR/MC）
   - 单位转换

### 技术决策
1. **依赖管理**
   - 优先纯 Swift 实现
   - 如需第三方库，先解决 CocoaPods 配置
   - 避免 SPM

2. **架构模式**
   - 保持 MVVM（Model-View-ViewModel）
   - 使用 ObservableObject 状态管理
   - 保持代码模块化

3. **兼容性**
   - 支持 iOS 17+
   - 适配不同屏幕尺寸
   - 考虑 iPad 布局

## 工作流程
### 开发前
```bash
git checkout dev
git pull origin dev
open CalculatorPro.xcodeproj
```

### 提交更改
```bash
git add .
git commit -m "描述更改"
git push origin dev
```

### 测试要求
- 在 iPhone 模拟器测试
- 基本功能测试用例
- 界面适配检查

## 联系方式
- **GitHub**: chdtyzhy/openClaw-test
- **分支策略**: dev 为主开发分支
- **问题反馈**: 通过会话沟通

---
*最后更新: 2026-03-24*
*维护者: 小虾米 🦐*