// 使用agent-browser生成应用截图
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 截图配置
const config = {
  url: 'http://localhost:8080/calculator_preview.html',
  outputDir: './screenshots',
  devices: [
    {
      name: 'iphone-14-pro-max',
      width: 1290,
      height: 2796,
      pixelRatio: 3
    }
  ],
  themes: ['light', 'dark'],
  modes: ['basic', 'scientific', 'history']
};

// 创建输出目录
if (!fs.existsSync(config.outputDir)) {
  fs.mkdirSync(config.outputDir, { recursive: true });
}

// 生成截图函数
async function generateScreenshots() {
  console.log('开始生成应用截图...');
  
  for (const device of config.devices) {
    console.log(`\n设备: ${device.name} (${device.width}x${device.height})`);
    
    for (const theme of config.themes) {
      console.log(`\n主题: ${theme === 'light' ? '浅色模式' : '深色模式'}`);
      
      for (const mode of config.modes) {
        const screenshotName = `${device.name}_${theme}_${mode}.png`;
        const outputPath = path.join(config.outputDir, screenshotName);
        
        console.log(`生成: ${mode}界面...`);
        
        try {
          // 构建agent-browser命令
          const command = [
            'agent-browser',
            'snapshot',
            '--url', config.url,
            '--viewport', `${device.width},${device.height}`,
            '--output', outputPath,
            '--wait-for', '2000', // 等待2秒确保页面加载
            '--full-page', 'false'
          ];
          
          // 添加主题参数
          if (theme === 'dark') {
            command.push('--eval', `
              document.documentElement.setAttribute('data-theme', 'dark');
              document.body.style.backgroundColor = '#000000';
            `);
          }
          
          // 添加模式参数
          let modeScript = '';
          if (mode === 'scientific') {
            modeScript = `
              const sciBtn = document.querySelector('[data-mode="scientific"]');
              if (sciBtn) sciBtn.click();
              await new Promise(resolve => setTimeout(resolve, 500));
            `;
          } else if (mode === 'history') {
            modeScript = `
              const historyBtn = document.querySelector('[data-tab="history"]');
              if (historyBtn) historyBtn.click();
              await new Promise(resolve => setTimeout(resolve, 500));
            `;
          }
          
          if (modeScript) {
            command.push('--eval', modeScript);
          }
          
          // 执行命令
          execSync(command.join(' '), { stdio: 'inherit' });
          
          console.log(`✅ 已生成: ${screenshotName}`);
          
        } catch (error) {
          console.error(`❌ 生成失败 ${screenshotName}:`, error.message);
        }
      }
    }
  }
  
  console.log('\n🎉 截图生成完成！');
  console.log(`输出目录: ${path.resolve(config.outputDir)}`);
  
  // 列出生成的文件
  const files = fs.readdirSync(config.outputDir);
  console.log('\n生成的文件:');
  files.forEach(file => {
    const filePath = path.join(config.outputDir, file);
    const stats = fs.statSync(filePath);
    console.log(`  ${file} (${(stats.size / 1024).toFixed(1)} KB)`);
  });
}

// 运行
generateScreenshots().catch(console.error);