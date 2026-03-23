#!/bin/bash

# 截图生成脚本
echo "开始生成Calculator Pro应用截图..."

# 创建截图目录
SCREENSHOT_DIR="./app_store_screenshots"
mkdir -p "$SCREENSHOT_DIR"

# iPhone 14 Pro Max 尺寸
WIDTH=1290
HEIGHT=2796

# 基础URL
BASE_URL="http://localhost:8080/calculator_preview.html"

# 生成浅色模式截图
echo "生成浅色模式截图..."

# 1. 基础计算界面
echo "  1. 基础计算界面..."
agent-browser snapshot \
  --url "$BASE_URL" \
  --viewport "$WIDTH,$HEIGHT" \
  --output "$SCREENSHOT_DIR/light_basic.png" \
  --wait-for 2000 \
  --full-page false

# 2. 科学计算界面
echo "  2. 科学计算界面..."
agent-browser snapshot \
  --url "$BASE_URL" \
  --viewport "$WIDTH,$HEIGHT" \
  --output "$SCREENSHOT_DIR/light_scientific.png" \
  --wait-for 2000 \
  --full-page false \
  --eval "
    // 切换到科学计算模式
    const sciBtn = document.querySelector('button[onclick*=\"toggleScientificMode\"]');
    if (sciBtn) {
      sciBtn.click();
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    // 输入一些计算
    const buttons = document.querySelectorAll('button');
    const sevenBtn = Array.from(buttons).find(btn => btn.textContent === '7');
    const sinBtn = Array.from(buttons).find(btn => btn.textContent === 'sin');
    
    if (sevenBtn && sinBtn) {
      sevenBtn.click();
      await new Promise(resolve => setTimeout(resolve, 300));
      sinBtn.click();
    }
  "

# 3. 历史记录界面
echo "  3. 历史记录界面..."
agent-browser snapshot \
  --url "$BASE_URL" \
  --viewport "$WIDTH,$HEIGHT" \
  --output "$SCREENSHOT_DIR/light_history.png" \
  --wait-for 2000 \
  --full-page false \
  --eval "
    // 切换到历史记录标签
    const historyTab = document.querySelector('[data-tab=\"history\"]');
    if (historyTab) {
      historyTab.click();
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  "

# 生成深色模式截图
echo "生成深色模式截图..."

# 4. 深色模式基础计算界面
echo "  4. 深色模式基础计算界面..."
agent-browser snapshot \
  --url "$BASE_URL" \
  --viewport "$WIDTH,$HEIGHT" \
  --output "$SCREENSHOT_DIR/dark_basic.png" \
  --wait-for 2000 \
  --full-page false \
  --eval "
    // 切换到深色模式
    document.documentElement.setAttribute('data-theme', 'dark');
    document.body.style.backgroundColor = '#000000';
    await new Promise(resolve => setTimeout(resolve, 500));
  "

# 5. 深色模式科学计算界面
echo "  5. 深色模式科学计算界面..."
agent-browser snapshot \
  --url "$BASE_URL" \
  --viewport "$WIDTH,$HEIGHT" \
  --output "$SCREENSHOT_DIR/dark_scientific.png" \
  --wait-for 2000 \
  --full-page false \
  --eval "
    // 切换到深色模式
    document.documentElement.setAttribute('data-theme', 'dark');
    document.body.style.backgroundColor = '#000000';
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // 切换到科学计算模式
    const sciBtn = document.querySelector('button[onclick*=\"toggleScientificMode\"]');
    if (sciBtn) {
      sciBtn.click();
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  "

# 6. 深色模式历史记录界面
echo "  6. 深色模式历史记录界面..."
agent-browser snapshot \
  --url "$BASE_URL" \
  --viewport "$WIDTH,$HEIGHT" \
  --output "$SCREENSHOT_DIR/dark_history.png" \
  --wait-for 2000 \
  --full-page false \
  --eval "
    // 切换到深色模式
    document.documentElement.setAttribute('data-theme', 'dark');
    document.body.style.backgroundColor = '#000000';
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // 切换到历史记录标签
    const historyTab = document.querySelector('[data-tab=\"history\"]');
    if (historyTab) {
      historyTab.click();
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  "

echo "截图生成完成！"
echo "输出目录: $SCREENSHOT_DIR"
echo ""
echo "生成的文件:"
ls -la "$SCREENSHOT_DIR" | grep -E "\.(png|jpg|jpeg)$"