// 简单截图脚本 - 通过修改HTML状态来截图
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 创建临时HTML文件函数
function createTempHtml(theme, mode, tab) {
  const originalHtml = fs.readFileSync('calculator_preview.html', 'utf8');
  
  // 修改主题
  let modifiedHtml = originalHtml;
  if (theme === 'dark') {
    modifiedHtml = modifiedHtml.replace(
      'document.documentElement.setAttribute(\'data-theme\', \'light\');',
      'document.documentElement.setAttribute(\'data-theme\', \'dark\');'
    );
    modifiedHtml = modifiedHtml.replace(
      'theme = \'light\';',
      'theme = \'dark\';'
    );
  }
  
  // 修改模式
  if (mode === 'scientific') {
    modifiedHtml = modifiedHtml.replace(
      'isScientificMode = false;',
      'isScientificMode = true;'
    );
    modifiedHtml = modifiedHtml.replace(
      'modeIndicator.textContent = \'基础计算模式\';',
      'modeIndicator.textContent = \'科学计算模式\';'
    );
  }
  
  // 修改标签页
  if (tab === 'history') {
    modifiedHtml = modifiedHtml.replace(
      'activeTab = \'calculator\';',
      'activeTab = \'history\';'
    );
  } else if (tab === 'settings') {
    modifiedHtml = modifiedHtml.replace(
      'activeTab = \'calculator\';',
      'activeTab = \'settings\';'
    );
  }
  
  const tempFileName = `temp_${theme}_${mode}_${tab}.html`;
  fs.writeFileSync(tempFileName, modifiedHtml);
  return tempFileName;
}

// 生成截图
async function generateScreenshots() {
  console.log('开始生成应用截图...');
  
  const screenshots = [
    { theme: 'light', mode: 'basic', tab: 'calculator', name: '浅色模式_基础计算' },
    { theme: 'light', mode: 'scientific', tab: 'calculator', name: '浅色模式_科学计算' },
    { theme: 'light', mode: 'basic', tab: 'history', name: '浅色模式_历史记录' },
    { theme: 'dark', mode: 'basic', tab: 'calculator', name: '深色模式_基础计算' },
    { theme: 'dark', mode: 'scientific', tab: 'calculator', name: '深色模式_科学计算' },
    { theme: 'dark', mode: 'basic', tab: 'history', name: '深色模式_历史记录' },
  ];
  
  const outputDir = './screenshots';
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // 设备配置
  const device = {
    width: 1290,
    height: 2796
  };
  
  for (const config of screenshots) {
    console.log(`\n生成: ${config.name}...`);
    
    try {
      // 创建临时HTML文件
      const tempFile = createTempHtml(config.theme, config.mode, config.tab);
      
      // 构建agent-browser命令
      const command = [
        'agent-browser',
        'snapshot',
        '--url', `http://localhost:8080/${tempFile}`,
        '--viewport', `${device.width},${device.height}`,
        '--output', path.join(outputDir, `${config.name}.png`),
        '--wait-for', '3000', // 等待3秒确保页面完全加载
        '--full-page', 'false',
        '--quality', '90'
      ];
      
      // 执行命令
      execSync(command.join(' '), { stdio: 'pipe' });
      
      // 清理临时文件
      fs.unlinkSync(tempFile);
      
      console.log(`✅ 已生成: ${config.name}.png`);
      
    } catch (error) {
      console.error(`❌ 生成失败 ${config.name}:`, error.message);
    }
  }
  
  console.log('\n🎉 截图生成完成！');
  console.log(`输出目录: ${path.resolve(outputDir)}`);
  
  // 列出生成的文件
  const files = fs.readdirSync(outputDir);
  console.log('\n生成的文件:');
  files.forEach(file => {
    const filePath = path.join(outputDir, file);
    const stats = fs.statSync(filePath);
    console.log(`  ${file} (${(stats.size / 1024).toFixed(1)} KB)`);
  });
}

// 运行
generateScreenshots().catch(console.error);