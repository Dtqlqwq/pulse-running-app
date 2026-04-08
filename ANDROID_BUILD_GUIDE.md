# Android APK构建指南

## 概述
本指南将帮助您完成Java环境安装和APK构建，使您可以在Android手机上安装Pulse跑步应用。

## 步骤1：安装Java开发环境

### Windows用户

#### 选项A：安装Eclipse Temurin JDK（推荐）
1. 访问 [Eclipse Temurin下载页面](https://adoptium.net/temurin/releases/)
2. 选择 **Windows x64** 版本，下载 **JDK 17**（LTS版本）
3. 运行安装程序，使用默认设置
4. 设置环境变量：
   - 按 `Win + X`，选择 **终端（管理员）**
   - 运行以下命令（根据您的安装路径调整）：
     ```powershell
     setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.0.0-hotspot"
     setx PATH "%PATH%;%JAVA_HOME%\bin"
     ```
   - 重启终端窗口

#### 选项B：使用Chocolatey包管理器（快速安装）
如果您已安装Chocolatey，运行：
```powershell
choco install temurin17
```

### 验证Java安装
打开新的命令提示符或PowerShell，运行：
```bash
java -version
javac -version
```
应该显示Java版本信息。

## 步骤2：构建APK

### 构建调试版APK（用于测试）
```bash
cd android
./gradlew assembleDebug
```

构建完成后，APK文件位于：
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### 构建发布版APK（用于分发）
```bash
cd android
./gradlew assembleRelease
```

首次构建发布版APK需要签名密钥。如果没有，请先创建：

## 步骤3：创建签名密钥（仅发布版需要）

### 生成密钥库
```bash
cd android/app
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
```

按照提示输入信息：
- 密钥库密码：设置一个安全密码
- 姓名：您的名字
- 组织单位：您的组织
- 组织名称：您的公司名
- 城市：所在城市
- 州/省：所在州/省
- 国家代码：CN（中国）

### 配置Gradle使用密钥库
编辑 `android/app/build.gradle`，在 `android` 部分添加：
```gradle
signingConfigs {
    release {
        storeFile file("my-release-key.jks")
        storePassword "您设置的密码"
        keyAlias "my-alias"
        keyPassword "您设置的密码"
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

## 步骤4：安装APK到手机

### 方法A：使用ADB（推荐）
1. 在手机上启用 **开发者选项** 和 **USB调试**
2. 连接手机到电脑
3. 安装ADB工具（如果未安装）：
   ```bash
   # Windows用户可以从这里下载：https://developer.android.com/studio/releases/platform-tools
   ```
4. 安装APK：
   ```bash
   adb install android/app/build/outputs/apk/debug/app-debug.apk
   ```

### 方法B：手动传输
1. 将APK文件复制到手机（通过USB、蓝牙或云存储）
2. 在手机上打开文件管理器
3. 点击APK文件进行安装
4. 如果提示"禁止安装来自未知来源的应用"，请允许安装

## 步骤5：测试应用功能

安装后请测试以下功能：

### 基本功能测试
- [ ] 应用正常启动
- [ ] 注册新账号
- [ ] 登录现有账号
- [ ] 底部导航栏切换正常

### GPS功能测试
- [ ] 跑步页面显示"当前跑步距离"
- [ ] 点击"▶"按钮开始跑步
- [ ] 系统请求位置权限（允许）
- [ ] 显示"📍 GPS定位中..."
- [ ] 移动时距离增加

### 数据功能测试
- [ ] 点击"完成 & 保存"保存跑步记录
- [ ] STATS页面显示统计数据
- [ ] PROFILE页面显示个人信息
- [ ] AI COACH页面能发送消息

### 离线功能测试
- [ ] 关闭网络后应用仍能打开
- [ ] 显示基本界面

## 常见问题解决

### 问题1：`'gradlew' 不是内部或外部命令`
**原因**：Java环境未正确安装或PATH未设置
**解决**：
1. 确认Java已安装：`java -version`
2. 检查JAVA_HOME环境变量
3. 确保`gradlew`文件存在于`android`目录

### 问题2：构建失败，显示"Could not find tools.jar"
**原因**：安装了JRE而不是JDK
**解决**：卸载JRE，安装完整的JDK

### 问题3：APK安装失败，显示"应用未安装"
**原因**：签名冲突或Android版本不兼容
**解决**：
1. 卸载手机上已存在的同名应用
2. 确保APK与手机架构兼容（通常为arm64-v8a）
3. 尝试构建调试版APK

### 问题4：GPS无法定位
**原因**：位置权限未授予或设备GPS关闭
**解决**：
1. 检查手机位置服务是否开启
2. 在应用权限设置中允许位置访问
3. 在室外空旷区域测试

## 优化建议

### 应用图标优化
将 `public/icon-512.png` 复制到以下位置，替换默认图标：
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### 启动画面优化
创建启动画面图片，放置到 `android/app/src/main/res/drawable/` 目录

## 下一步：发布到Google Play Store

如果您希望将应用发布到Google Play Store：

1. **准备材料**：
   - 应用图标（512×512）
   - 截图（至少2张，1280×720）
   - 应用描述（中英文）
   - 隐私政策链接

2. **构建应用包**：
   ```bash
   cd android
   ./gradlew bundleRelease
   ```
   生成AAB文件：`android/app/build/outputs/bundle/release/app-release.aab`

3. **创建Google Play开发者账号**（需要一次性费用$25）

4. **提交审核**：通过Google Play Console提交应用

## 技术支持

如果在构建过程中遇到问题：

1. **检查日志**：构建失败时查看完整错误信息
2. **清理项目**：
   ```bash
   cd android
   ./gradlew clean
   ```
3. **重新同步**：
   ```bash
   npx cap sync android
   ```
4. **更新依赖**：
   ```bash
   cd android
   ./gradlew build --refresh-dependencies
   ```

---

**恭喜！** 您现在已经拥有了一个功能完整的Android跑步应用。应用支持GPS追踪、用户认证、数据统计和AI教练功能，可以在Android 8.0+设备上运行。