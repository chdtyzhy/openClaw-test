# Fastlane 自动化部署配置

## 概述

Fastlane用于自动化Calculator Pro应用的构建、测试和发布流程。支持：
- iOS App Store发布
- Android Google Play发布
- 测试版本分发
- 截图生成和本地化

## 环境要求

### macOS环境
```bash
# 安装Fastlane
sudo gem install fastlane -NV

# 或使用Homebrew
brew install fastlane
```

### 项目配置
```bash
cd /root/.openclaw/workspace/CalculatorApp
fastlane init
```

## 配置文件

### Fastfile - 主配置文件
位于 `fastlane/Fastfile`，定义所有lane（任务）。

### Appfile - 应用标识配置
```ruby
app_identifier("com.yourcompany.calculatorpro")
apple_id("your-apple-id@email.com")
team_id("YOUR_TEAM_ID")
```

### Deliverfile - App Store配置
```ruby
app_identifier("com.yourcompany.calculatorpro")
username("your-apple-id@email.com")
```

### Pluginfile - 插件配置
```ruby
# 自动生成截图
gem 'fastlane-plugin-screengrab'
gem 'fastlane-plugin-frameit'

# 其他有用插件
gem 'fastlane-plugin-badge'
gem 'fastlane-plugin-versioning'
```

## 常用命令

### 测试
```bash
# 运行所有测试
fastlane test

# 运行iOS测试
fastlane ios test

# 运行Android测试
fastlane android test
```

### 构建
```bash
# 构建iOS测试版
fastlane ios build

# 构建Android测试版
fastlane android build

# 构建发布版本
fastlane ios release
fastlane android release
```

### 发布
```bash
# 提交到TestFlight
fastlane ios beta

# 提交到App Store
fastlane ios appstore

# 提交到Google Play
fastlane android deploy
```

## 自定义Lane示例

### iOS发布流程
```ruby
lane :release do
  # 1. 增加版本号
  increment_build_number
  
  # 2. 构建应用
  gym(
    scheme: "CalculatorPro",
    export_method: "app-store",
    clean: true
  )
  
  # 3. 上传到TestFlight
  pilot(
    skip_submission: true,
    skip_waiting_for_build_processing: false
  )
  
  # 4. 提交到App Store审核
  deliver(
    skip_binary_upload: true,
    skip_screenshots: true,
    skip_metadata: false,
    force: true
  )
end
```

### Android发布流程
```ruby
lane :deploy do
  # 1. 增加版本号
  android_set_version_code
  android_set_version_name
  
  # 2. 构建APK
  gradle(
    task: 'assemble',
    build_type: 'Release'
  )
  
  # 3. 上传到Google Play
  supply(
    track: 'production',
    apk: 'app/build/outputs/apk/release/app-release.apk'
  )
end
```

## 截图自动化

### 配置截图
```ruby
lane :screenshots do
  capture_screenshots(
    scheme: "CalculatorPro",
    devices: [
      "iPhone 14 Pro",
      "iPhone 14 Pro Max",
      "iPad Pro (12.9-inch)"
    ],
    languages: [
      "en-US",
      "zh-Hans"
    ]
  )
  
  frame_screenshots
end
```

### 截图场景
1. **基础计算界面**
2. **科学计算模式**
3. **历史记录页面**
4. **设置页面**
5. **深色模式界面**

## 环境变量配置

### .env文件
```bash
# Apple开发者账户
APPLE_ID=your-email@example.com
APPLE_TEAM_ID=YOUR_TEAM_ID

# App Store Connect API密钥
APP_STORE_CONNECT_API_KEY_KEY_ID=YOUR_KEY_ID
APP_STORE_CONNECT_API_KEY_ISSUER_ID=YOUR_ISSUER_ID
APP_STORE_CONNECT_API_KEY_KEY=YOUR_PRIVATE_KEY

# Google Play API
GCLOUD_SERVICE_ACCOUNT_JSON=path/to/service-account.json
```

## 故障排除

### 常见问题

1. **证书问题**
```bash
fastlane match init
fastlane match development
fastlane match appstore
```

2. **构建失败**
```bash
# 清理构建缓存
fastlane clean

# 重置模拟器
fastlane reset_simulators
```

3. **上传失败**
```bash
# 检查网络连接
# 验证API密钥
# 检查应用状态
```

## 最佳实践

### 版本管理
- 使用语义化版本控制 (SemVer)
- 每次发布前增加版本号
- 维护CHANGELOG.md

### 代码签名
- 使用match管理证书
- 团队共享证书
- 定期更新证书

### 自动化测试
- 每次提交运行测试
- 发布前运行完整测试套件
- 监控测试覆盖率

## 扩展功能

### 自定义插件
```ruby
# 创建自定义插件
fastlane new_plugin custom_task
```

### 集成其他服务
- Slack通知构建状态
- Jira集成问题跟踪
- Sentry错误监控

## 参考资料

- [Fastlane官方文档](https://docs.fastlane.tools)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [Google Play Developer API](https://developers.google.com/android-publisher)