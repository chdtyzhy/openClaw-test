# GitHub 仓库设置指南

## 🚀 快速开始

### 步骤1: 在GitHub创建新仓库
1. 登录 [GitHub](https://github.com)
2. 点击右上角 "+" → "New repository"
3. 填写仓库信息：
   - **Repository name**: `tip-calculator-pro` (或你喜欢的名称)
   - **Description**: Tip Calculator Pro - iOS付费应用，支持完整自动化开发流水线
   - **Public** (公开) 或 **Private** (私有，推荐)
   - **不要勾选** "Initialize this repository with a README" (我们已经有README了)
4. 点击 "Create repository"

### 步骤2: 推送代码到GitHub
```bash
# 进入项目目录
cd /root/.openclaw/workspace/TipCalculatorPro

# 添加远程仓库（将YOUR_USERNAME替换为你的GitHub用户名）
git remote add origin https://github.com/YOUR_USERNAME/tip-calculator-pro.git

# 推送代码
git push -u origin master

# 如果遇到错误，可能需要先拉取（新仓库是空的，通常不需要）
# git pull origin master --allow-unrelated-histories
```

## 🔑 GitHub认证

### 方式A: HTTPS (推荐新手)
```bash
# 第一次推送时需要输入GitHub用户名和密码
# 如果启用了双因素认证，需要使用个人访问令牌(PAT)

# 生成个人访问令牌：
# 1. 登录GitHub → Settings → Developer settings → Personal access tokens
# 2. 点击 "Generate new token"
# 3. 选择权限：repo (完全控制仓库)
# 4. 复制生成的令牌，在密码提示时使用它
```

### 方式B: SSH (更安全)
```bash
# 1. 生成SSH密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 将公钥添加到GitHub
cat ~/.ssh/id_ed25519.pub
# 复制输出内容到 GitHub → Settings → SSH and GPG keys → New SSH key

# 3. 使用SSH地址添加远程仓库
git remote set-url origin git@github.com:YOUR_USERNAME/tip-calculator-pro.git
```

## 📁 项目结构说明

```
tip-calculator-pro/
├── App.tsx              # 主应用代码 (React Native + TypeScript)
├── package.json         # 依赖配置 (已优化中国网络)
├── automate.sh          # 开发自动化脚本
├── app_factory.py       # 应用工厂 (端到端自动化)
├── fastlane/           # App Store上架自动化
├── DEVELOPMENT_PLAN.md  # 7天详细开发计划
├── AUTOMATION_GUIDE.md  # 自动化使用指南
├── README.md           # 项目说明
└── .gitignore          # Git忽略文件
```

## 🌟 项目特色

### 1. 完整的自动化系统
- **开发自动化**: `./automate.sh` - 一键环境设置、测试、运行
- **应用工厂**: `app_factory.py` - 从市场调研到收入预测的完整流水线
- **上架自动化**: `fastlane/` - App Store发布自动化

### 2. 中国网络优化
- npm淘宝镜像已配置
- 详细的故障排除指南
- 针对国内开发环境的优化

### 3. 完整的文档
- 7天开发计划 (每小时任务分解)
- 收入预测和财务分析
- 市场调研报告模板
- App Store上架清单

## 🔧 环境要求

### 必需环境
- **macOS** (iOS开发必需)
- **Xcode 15+**
- **Node.js 18+**
- **Python 3.8+**
- **Apple开发者账号** (¥688/年)

### 推荐工具
- **Visual Studio Code** 或 **WebStorm**
- **GitHub Desktop** (可视化Git工具)
- **Homebrew** (macOS包管理)

## 🚀 开始开发

### 克隆仓库后
```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/tip-calculator-pro.git
cd tip-calculator-pro

# 设置执行权限
chmod +x automate.sh

# 运行完整自动化流程
./automate.sh all
```

### 开发流程
```bash
# 1. 环境设置
./automate.sh setup

# 2. 启动开发
./automate.sh ios

# 3. 代码检查
./automate.sh lint

# 4. 运行测试
./automate.sh test
```

## 📊 收入模型

### 定价策略
- **建议定价**: ¥8.00 (比竞品便宜33%)
- **苹果分成后**: ¥5.60/份
- **目标月收入**: ¥2000-4000

### 收入预测
| 月份 | 月下载量 | 月收入 (净) |
|------|----------|-------------|
| 第1个月 | 50 | ¥280 |
| 第3个月 | 150 | ¥840 |
| 第6个月 | 300 | ¥1,680 |

## ⚠️ 注意事项

### 1. 苹果开发者账号
- 需要付费账号才能真机测试和上架 (¥688/年)
- 建议先使用模拟器开发，确认商业模式后再付费

### 2. 代码签名
- iOS应用需要代码签名证书
- 可以使用Xcode自动管理证书 (推荐新手)
- 或使用fastlane match管理证书

### 3. App Store审核
- 确保应用有实际功能价值
- 提供完整的隐私政策
- 截图符合苹果要求
- 描述准确无误导

## 🔄 持续集成 (可选)

### GitHub Actions 配置
在 `.github/workflows/ci.yml` 添加:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
```

## 📞 支持与帮助

### 遇到问题？
1. **查看文档**: `AUTOMATION_GUIDE.md` 和 `DEVELOPMENT_PLAN.md`
2. **GitHub Issues**: 在仓库创建Issue
3. **React Native中文社区**: https://reactnative.cn
4. **苹果开发者论坛**: https://developer.apple.com/forums

### 紧急联系人
- 技术问题: React Native中文社区
- 上架问题: 苹果开发者支持
- Git问题: GitHub官方文档

## 🎯 成功指标

### 技术指标
- [ ] 应用无崩溃
- [ ] 启动时间 < 2秒
- [ ] 测试覆盖率 > 80%
- [ ] 代码质量评分 A

### 业务指标  
- [ ] 月下载量 > 100
- [ ] 用户评分 > 4.5
- [ ] 月收入 > ¥2000
- [ ] 用户留存率 > 40%

---

**开始你的自动化开发之旅吧！** 🚀

记住：这个项目不仅是一个iOS应用，更是一个完整的自动化开发和发布系统。你可以基于这个模板快速开发其他类型的应用。