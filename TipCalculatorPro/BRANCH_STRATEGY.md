# 分支规范策略

## 🎯 分支结构

### 主分支
- **`main`** - 生产就绪代码
  - 保护分支，禁止直接推送
  - 只能通过Pull Request合并
  - 对应生产环境
  - 每个提交都应该可发布

- **`develop`** - 开发集成分支
  - 功能开发集成
  - 持续集成测试
  - 预发布环境
  - 从`feature/*`分支合并

### 支持分支
- **`feature/*`** - 功能开发分支
  - 命名：`feature/功能名称-简短描述`
  - 示例：`feature/add-dark-mode`, `feature/calculator-logic`
  - 从`develop`分支创建
  - 完成后合并回`develop`

- **`release/*`** - 发布准备分支
  - 命名：`release/v1.2.3`
  - 版本号遵循语义化版本控制
  - 从`develop`分支创建
  - 只进行bug修复和文档更新
  - 完成后合并到`main`和`develop`

- **`hotfix/*`** - 紧急修复分支
  - 命名：`hotfix/紧急问题描述`
  - 示例：`hotfix/login-crash`, `hotfix/security-patch`
  - 从`main`分支创建
  - 修复后合并到`main`和`develop`

## 📋 分支生命周期

### 功能开发流程
```
1. git checkout develop                  # 切换到开发分支
2. git pull origin develop               # 更新最新代码
3. git checkout -b feature/xxx           # 创建功能分支
4. 开发、测试、提交代码                   # 在功能分支工作
5. git push -u origin feature/xxx        # 推送到远程
6. 在GitHub创建Pull Request到develop     # 代码审查
7. 合并后删除功能分支                     # 清理
```

### 发布流程
```
1. git checkout develop                  # 确保在开发分支
2. git checkout -b release/v1.2.3        # 创建发布分支
3. 更新版本号、CHANGELOG、文档            # 准备发布
4. 测试、修复问题                         # 质量保证
5. git checkout main                     # 切换到主分支
6. git merge --no-ff release/v1.2.3      # 合并到主分支
7. git tag -a v1.2.3 -m "Release v1.2.3" # 打标签
8. git checkout develop                  # 切换到开发分支
9. git merge --no-ff release/v1.2.3      # 合并回开发分支
10. git branch -d release/v1.2.3          # 删除本地发布分支
11. git push origin --delete release/v1.2.3 # 删除远程分支
```

### 紧急修复流程
```
1. git checkout main                     # 切换到主分支
2. git pull origin main                  # 更新最新代码
3. git checkout -b hotfix/xxx            # 创建热修复分支
4. 修复问题、测试                         # 紧急修复
5. git checkout main                     # 切换到主分支
6. git merge --no-ff hotfix/xxx          # 合并到主分支
7. git tag -a v1.2.4 -m "Hotfix v1.2.4"  # 打标签
8. git checkout develop                  # 切换到开发分支
9. git merge --no-ff hotfix/xxx          # 合并到开发分支
10. git branch -d hotfix/xxx              # 删除本地热修复分支
11. git push origin --delete hotfix/xxx   # 删除远程分支
```

## 🔧 分支保护规则

### GitHub分支保护设置
- **`main`分支**：
  - 要求Pull Request审核
  - 要求状态检查通过
  - 禁止强制推送
  - 要求线性提交历史

- **`develop`分支**：
  - 要求状态检查通过
  - 建议Pull Request审核

### 提交信息规范
```
类型(范围): 简短描述

详细描述（可选）

解决的问题/关闭的Issue: #123

类型包括：
- feat: 新功能
- fix: bug修复
- docs: 文档更新
- style: 代码格式（不影响功能）
- refactor: 代码重构
- test: 测试相关
- chore: 构建过程或辅助工具
```

## 🚀 快速开始

### 初始化项目
```bash
# 克隆项目
git clone git@github.com:chdtyzhy/openClaw-test.git
cd openClaw-test

# 设置分支上游
git checkout main
git branch -u origin/main

git checkout develop
git branch -u origin/develop
```

### 开始新功能开发
```bash
# 1. 更新开发分支
git checkout develop
git pull origin develop

# 2. 创建功能分支
git checkout -b feature/add-dark-mode

# 3. 开发并提交
git add .
git commit -m "feat(theme): 添加深色主题支持"

# 4. 推送到远程
git push -u origin feature/add-dark-mode

# 5. 在GitHub创建Pull Request到develop
```

### 日常开发流程
```bash
# 早上开始工作
git checkout develop
git pull origin develop
git checkout -b feature/your-feature

# 提交更改
git add .
git commit -m "类型(范围): 描述"

# 推送到远程
git push origin feature/your-feature

# 晚上结束工作前
git checkout develop
git pull origin develop
git checkout feature/your-feature
git rebase develop
```

## 📊 分支状态检查

### 查看分支状态
```bash
# 查看所有分支
git branch -a

# 查看分支关系图
git log --oneline --all --graph

# 查看未合并的分支
git branch --no-merged

# 查看已合并的分支
git branch --merged
```

### 清理旧分支
```bash
# 删除已合并的本地分支
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "develop" | xargs -n 1 git branch -d

# 删除远程已合并的分支
git branch -r --merged | grep -v "main" | grep -v "develop" | sed 's/origin\///' | xargs -n 1 git push origin --delete
```

## ⚠️ 注意事项

### 禁止的操作
1. **禁止直接推送到`main`分支**
2. **禁止在`main`分支上直接开发**
3. **禁止强制推送保护分支**
4. **禁止合并有冲突的代码**
5. **禁止跳过代码审查**

### 推荐的操作
1. **定期从`develop`分支拉取更新**
2. **保持功能分支小而专注**
3. **及时删除已合并的分支**
4. **编写有意义的提交信息**
5. **创建Pull Request前进行自测**

## 🔄 迁移说明

### 从旧分支结构迁移
如果项目之前使用`master`作为主分支：
```bash
# 1. 重命名本地分支
git branch -m master main

# 2. 推送到远程
git push -u origin main

# 3. 设置GitHub默认分支为main
# （需要在GitHub网页设置）

# 4. 删除旧的master分支
git push origin --delete master
```

### 创建开发分支
```bash
# 从main创建develop分支
git checkout main
git checkout -b develop
git push -u origin develop
```

## 📞 问题解决

### 常见问题
1. **"您的分支基于'origin/master'，但上游已消失"**
   ```bash
   git branch --unset-upstream
   git branch -u origin/main
   ```

2. **无法推送到保护分支**
   - 创建Pull Request而不是直接推送
   - 确保有合适的权限

3. **合并冲突**
   ```bash
   git fetch origin
   git checkout your-branch
   git rebase origin/develop
   # 解决冲突后
   git rebase --continue
   ```

4. **分支落后太多**
   ```bash
   git checkout your-branch
   git merge origin/develop
   # 或
   git rebase origin/develop
   ```

## 🎯 成功指标

### 分支健康度
- [ ] 功能分支平均寿命 < 2周
- [ ] 发布分支平均寿命 < 1周
- [ ] 热修复分支平均寿命 < 2天
- [ ] 分支合并冲突率 < 5%

### 代码质量
- [ ] 所有合并都有代码审查
- [ ] 所有提交都有有意义的描述
- [ ] 主分支始终保持可发布状态
- [ ] 开发分支测试通过率 > 95%

---

**最后更新**：2026-03-23  
**当前分支状态**：
- ✅ `main` - 生产分支（保护）
- ✅ `develop` - 开发分支  
- 🔄 `feature/*` - 按需创建
- 🔄 `release/*` - 发布时创建
- 🔄 `hotfix/*` - 紧急时创建