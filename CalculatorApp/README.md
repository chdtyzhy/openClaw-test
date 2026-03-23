# Calculator Pro - iOS原生风格计算器应用

## 🎯 项目概述

Calculator Pro 是一个遵循 Apple 人机界面指南 (HIG) 的 iOS 原生风格计算器应用。采用 React Native + 原生模块架构，提供流畅的 iOS 原生体验。

## 📱 设计特色

### iOS 原生设计规范
- ✅ 严格遵循 Apple HIG 设计标准
- ✅ 使用 iOS 语义颜色系统
- ✅ SF Pro 字体系统
- ✅ 深色/浅色模式完整支持
- ✅ 动态字体大小适配
- ✅ 可访问性优先设计

### 计算器功能
- 基本四则运算（+ - × ÷）
- 百分比计算
- 正负切换
- 清除功能
- 实时计算结果显示
- 计算过程显示

## 🏗️ 技术架构

### 技术栈
- **React Native 0.75.0** - 跨平台框架
- **TypeScript** - 类型安全
- **iOS 原生模块** - 高性能计算引擎
- **React Native Async Storage** - 本地数据存储
- **React Native Safe Area Context** - 全面屏适配

### 项目结构
```
CalculatorPro/
├── App.tsx              # 主应用组件
├── app.json             # 应用配置
├── package.json         # 依赖配置
├── tsconfig.json        # TypeScript 配置
├── babel.config.js      # Babel 配置
├── metro.config.js      # Metro 配置
├── index.js            # 应用入口
├── design/             # 设计文档
│   ├── 01_竞品分析报告.md
│   ├── 02_用户流程图.md
│   ├── 03_线框图与布局设计.md
│   ├── 04_交互设计规范.md
│   └── 05_视觉设计规范.md
└── fastlane/           # App Store 上架自动化
```

## 🚀 快速开始

### 环境要求
- Node.js >= 16
- npm 或 yarn
- iOS 开发环境 (Xcode, CocoaPods)
- Android 开发环境 (可选)

### 安装步骤
```bash
# 克隆项目
git clone <repository-url>
cd CalculatorPro

# 安装依赖
npm install

# iOS 运行
cd ios && pod install
cd .. && npx react-native run-ios

# Android 运行
npx react-native run-android
```

### 开发脚本
```bash
npm start          # 启动 Metro 打包器
npm run ios        # 运行 iOS 应用
npm run android    # 运行 Android 应用
npm test           # 运行测试
npm run lint       # 代码检查
```

## 🎨 设计系统

### 颜色系统
遵循 iOS 语义颜色，支持深色/浅色模式：
- **主色调**: systemBlue (#007AFF / #0A84FF)
- **等号按钮**: systemOrange (#FF9500 / #FF9F0A)
- **清除按钮**: systemRed (#FF3B30 / #FF453A)
- **数字按钮**: systemGray6 (#F2F2F7 / #2C2C2E)

### 字体系统
- **显示字体**: SF Pro Display, Semibold, 60pt
- **按钮字体**: SF Pro Text, Medium, 24pt
- **标签字体**: SF Pro Text, Regular, 17pt

### 布局系统
- **8pt 倍数系统** - 所有间距基于 8pt 倍数
- **圆形按钮** - 72×72pt 圆形按钮
- **响应式布局** - 适配不同屏幕尺寸

## 🔧 功能实现

### 计算逻辑
- 实时表达式解析
- 错误处理机制
- 历史记录缓存
- 精度控制

### 用户界面
- 标签栏导航（计算器、历史、设置）
- 主题切换（深色/浅色）
- 动画反馈
- 手势支持

### 数据持久化
- 计算历史存储
- 用户偏好设置
- 主题状态保存

## 📱 设备支持

### iOS 设备
- iPhone (全面屏和传统屏)
- iPad (分屏和多任务)
- 支持 iOS 15+

### 功能适配
- 深色模式
- 动态字体
- 可访问性功能
- 全面屏安全区域

## 🚀 开发计划

### MVP 1.0 (当前版本)
- [x] 基础计算功能
- [x] iOS 原生 UI 设计
- [x] 深色/浅色主题
- [x] 响应式布局

### 1.1 版本计划
- [ ] 科学计算功能
- [ ] 历史记录系统
- [ ] 单位换算
- [ ] 表达式编辑

### 1.2 版本计划
- [ ] iOS Widget 支持
- [ ] Apple Watch 应用
- [ ] iCloud 同步
- [ ] 高级主题定制

## 🤝 贡献指南

### 开发流程
1. Fork 项目仓库
2. 创建功能分支 (`feature/your-feature`)
3. 提交代码变更
4. 创建 Pull Request
5. 代码审查和合并

### 代码规范
- 使用 TypeScript 严格模式
- 遵循 React Native 最佳实践
- 编写单元测试
- 保持代码可读性

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- Apple 人机界面指南
- React Native 社区
- 所有贡献者和用户

---

**项目状态**: 开发中  
**最后更新**: 2026-03-23  
**版本**: 1.0.0