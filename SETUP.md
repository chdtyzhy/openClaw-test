# 项目设置指南

## 环境要求（基于开发者环境）
- **macOS**: 26.3.1+ (与开发者环境一致)
- **Xcode**: 26.2+ (Version 17C52)
- **iOS**: 17.0+ 模拟器或设备
- **注意**: 项目使用纯 Swift 实现，无复杂依赖

## 快速开始（针对本地环境优化）

### 1. 克隆仓库
```bash
git clone https://github.com/chdtyzhy/openClaw-test.git
cd openClaw-test
git checkout dev
```

### 2. 打开项目（简化版无依赖）
```bash
cd CalculatorPro
open CalculatorPro.xcodeproj  # 使用 .xcodeproj（无 CocoaPods 依赖）
```

### 3. 配置（如果需要 CocoaPods）
```bash
# 如果需要安装依赖（当前项目已简化，不需要）
# pod install
# open CalculatorPro.xcworkspace  # 使用 .xcworkspace
```

### 4. 配置项目
1. 选择正确的签名团队（Team）
2. 选择目标设备或模拟器
3. 点击运行 (⌘R)

## 项目结构
```
CalculatorPro/
├── CalculatorPro.xcodeproj     # Xcode 项目文件
├── CalculatorPro.xcworkspace   # CocoaPods 工作空间
├── Podfile                    # CocoaPods 依赖配置
├── Podfile.lock              # 依赖版本锁定（自动生成）
└── CalculatorPro/            # 源代码目录
    ├── CalculatorProApp.swift # 应用入口
    ├── CalculatorSimple.swift # 计算器模型
    ├── SimpleCalculatorView.swift # 主界面
    └── Config.template.swift  # 配置模板
```

## 常见问题

### Q: 编译错误 "Missing required module 'Combine'"
A: 确保：
1. 使用 `.xcworkspace` 而不是 `.xcodeproj`
2. 已运行 `pod install`
3. 清理构建文件夹：Product → Clean Build Folder (⇧⌘K)

### Q: 签名错误
A: 在 Xcode 中：
1. 选择项目 → Signing & Capabilities
2. 选择正确的 Team
3. 修改 Bundle Identifier 为唯一值

### Q: CocoaPods 安装失败
A: 确保已安装 CocoaPods：
```bash
sudo gem install cocoapods
pod repo update
```

## 开发规范
1. 始终从 `dev` 分支开始新功能
2. 提交前运行测试
3. 保持代码风格一致
4. 添加有意义的提交信息

## 联系方式
- 项目维护者：[你的名字]
- 问题反馈：GitHub Issues
- 文档更新：提交 Pull Request