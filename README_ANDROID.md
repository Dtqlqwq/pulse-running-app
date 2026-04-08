# Pulse跑步应用 - Android安装指南

您已经成功配置了Pulse跑步应用，现在可以将其打包成Android应用安装在手机上。以下是三种构建方法：

## 📱 应用功能概述

- ✅ GPS跑步距离追踪
- ✅ 用户注册/登录（Supabase认证）
- ✅ 跑步数据统计和图表
- ✅ AI教练聊天功能
- ✅ 7天签到系统
- ✅ 离线支持（基础功能）
- ✅ 移动端优化界面

## 🚀 方法一：最简单的方法（推荐给新手）

### 使用GitHub Actions在线构建（无需安装Java）

**步骤：**

1. **创建GitHub账号**（如果还没有）
   - 访问 https://github.com
   - 点击 "Sign up" 注册

2. **创建新仓库**
   - 登录GitHub
   - 点击右上角 "+" → "New repository"
   - 仓库名：`pulse-running-app`
   - 选择 "Public"（公开）
   - 点击 "Create repository"

3. **上传代码**
   ```bash
   # 在项目目录（d:\pacex）打开Git Bash或命令提示符
   
   # 初始化git仓库
   git init
   git add .
   git commit -m "初始提交：Pulse跑步应用"
   
   # 连接到GitHub仓库
   git remote add origin https://github.com/你的用户名/pulse-running-app.git
   git branch -M main
   git push -u origin main
   ```

4. **触发构建**
   - 进入仓库页面
   - 点击 "Actions" 标签页
   - 选择 "Build Android APK" 工作流
   - 点击 "Run workflow" → "Run workflow"

5. **下载APK**
   - 等待构建完成（约5-10分钟）
   - 点击 "pulse-app-debug-apk" 下载APK文件

**优点：**
- 无需安装任何软件
- 自动处理所有依赖
- 可以在任何电脑上操作

## 💻 方法二：本地构建（适合开发者）

### 需要安装Java开发环境

**步骤：**

1. **安装Java JDK 17**
   - 下载：https://adoptium.net/temurin/releases/
   - 选择 "Windows x64" → "JDK 17"
   - 运行安装程序，使用默认设置

2. **设置环境变量**
   - 按 `Win + R`，输入 `sysdm.cpl`
   - 点击 "高级" → "环境变量"
   - 新建系统变量：
     - 变量名：`JAVA_HOME`
     - 变量值：`C:\Program Files\Eclipse Adoptium\jdk-17.x.x.x-hotspot`
   - 编辑 `Path` 变量，添加：`%JAVA_HOME%\bin`

3. **验证安装**
   ```cmd
   java -version
   javac -version
   ```

4. **运行构建脚本**
   ```powershell
   # 以管理员身份运行PowerShell
   # 切换到项目目录
   cd d:\pacex
   
   # 运行构建脚本
   .\build-android.ps1
   ```

5. **安装APK到手机**
   - 将生成的APK文件复制到手机
   - 在文件管理器中点击安装
   - 如果提示"未知来源"，请允许安装

## 🛠️ 方法三：使用Android Studio（图形界面）

### 适合喜欢可视化操作的用户

**步骤：**

1. **下载并安装Android Studio**
   - https://developer.android.com/studio
   - 运行安装程序，包含Android SDK

2. **导入项目**
   - 打开Android Studio
   - 选择 "Open an Existing Project"
   - 浏览到 `d:\pacex\android` 目录
   - 点击 "OK"

3. **构建APK**
   - 点击菜单 "Build" → "Build Bundle(s) / APK(s)" → "Build APK(s)"
   - 等待构建完成

4. **查找APK文件**
   - 构建完成后点击 "locate"
   - 或手动查找：`android/app/build/outputs/apk/debug/`

## 📲 安装后测试

安装应用后，请测试以下功能：

### 基本功能
- [ ] 应用正常启动
- [ ] 注册新账号
- [ ] 登录现有账号
- [ ] 底部导航切换正常

### GPS功能
- [ ] 允许位置权限
- [ ] 开始跑步后显示"GPS定位中"
- [ ] 移动时距离增加
- [ ] 保存跑步记录

### 其他功能
- [ ] STATS页面显示数据
- [ ] AI教练能发送和接收消息
- [ ] 离线时能打开应用

## 🔧 故障排除

### 问题：APK安装失败
**解决方法：**
1. 卸载手机上已有的同名应用
2. 确保手机开启"未知来源"安装
3. 重启手机后重试

### 问题：GPS无法定位
**解决方法：**
1. 检查手机位置服务是否开启
2. 在应用权限中允许位置访问
3. 在室外空旷区域测试

### 问题：登录失败
**解决方法：**
1. 检查网络连接
2. 确认Supabase项目正常运行
3. 尝试注册新账号

## 🎨 自定义应用

### 更换应用图标
将您的图标文件（建议512×512 PNG）复制到：
```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

### 修改应用名称
编辑 `capacitor.config.ts` 文件：
```typescript
appName: '您的应用名称',
```

## 📞 技术支持

如果遇到问题：

1. **查看日志**
   ```bash
   cd android
   ./gradlew build --stacktrace
   ```

2. **清理项目**
   ```bash
   cd android
   ./gradlew clean
   npx cap sync android
   ```

3. **检查依赖**
   ```bash
   npm outdated
   npm update
   ```

## 🎉 恭喜！

您现在已经拥有了一个功能完整的Android跑步应用。应用支持：

- **实时GPS追踪**：准确计算跑步距离
- **用户系统**：安全注册和登录
- **数据统计**：可视化跑步数据
- **AI教练**：智能跑步建议
- **离线支持**：无网络时基础功能

**下一步建议：**
1. 测试所有功能确保正常工作
2. 替换为您的品牌图标
3. 考虑发布到Google Play Store
4. 添加推送通知等高级功能

---

**文件说明：**
- `ANDROID_BUILD_GUIDE.md` - 详细构建指南
- `build-android.ps1` - 自动构建脚本
- `.github/workflows/build-android.yml` - GitHub Actions配置
- `capacitor.config.ts` - 应用配置
- `android/` - Android项目目录

祝您跑步愉快！🏃‍♂️