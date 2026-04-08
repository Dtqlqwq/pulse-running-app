# 🚀 极速构建指南 - 5步获得APK

## ⏱️ 预计时间：15分钟

### 第一步：安装Git（如果已安装请跳过）
1. 下载：https://git-scm.com/download/win
2. 双击安装，**全部点"Next"**使用默认设置
3. 安装完成后**重启电脑**

### 第二步：复制Supabase信息
打开文件 `d:\pacex\.env.local`，复制：
1. **URL**：`https://ofocnypllewqnthrimda.supabase.co`
2. **密钥**：以 `eyJhbGciOiJ...` 开头的长字符串

**保存这两个值**，下一步需要粘贴。

### 第三步：一键设置GitHub
1. 双击运行 `d:\pacex\setup-github.bat`
2. 按屏幕提示操作
3. 脚本会帮您完成大部分设置

### 第四步：设置GitHub Secrets（最关键！）
1. 访问：https://github.com/您的用户名/pulse-running-app/settings/secrets/actions
2. 点击 **New repository secret**
3. 添加第一个：
   - Name: `VITE_SUPABASE_URL`
   - Value: 粘贴第一步复制的URL
4. 再次点击 **New repository secret**
5. 添加第二个：
   - Name: `VITE_SUPABASE_ANON_KEY`
   - Value: 粘贴第一步复制的密钥

### 第五步：触发构建并下载APK
1. 访问：https://github.com/您的用户名/pulse-running-app/actions
2. 点击 **Build Android APK**
3. 点击 **Run workflow** → **Run workflow**
4. 等待10分钟构建完成
5. 点击 **Artifacts** → 下载 `pulse-app-debug-apk`

## 📱 安装到手机
1. 将下载的APK文件发送到手机
2. 在手机文件管理器中点击安装
3. 如果提示"未知来源"，请允许安装

## 🆘 常见问题速解

### ❌ 脚本运行失败
**解决**：手动执行以下命令（在 `d:\pacex` 目录右键选"Git Bash Here"）：
```bash
git init
git add .
git commit -m "初始提交"
git remote add origin https://github.com/您的用户名/pulse-running-app.git
git branch -M main
git push -u origin main
```

### ❌ git push 要求密码
**解决**：使用**个人访问令牌**代替密码：
1. 访问：https://github.com/settings/tokens
2. 点击 **Generate new token**
3. 勾选 **repo** 权限
4. 复制生成的令牌
5. 在git push时使用令牌作为密码

### ❌ GitHub Actions构建失败
**解决**：
1. 检查是否设置了两个Secrets
2. 查看构建日志中的错误信息
3. 重新运行工作流

### ❌ APK安装失败
**解决**：
1. 卸载手机上已有的Pulse应用
2. 开启手机"未知来源"安装权限
3. 重新安装

## ✅ 成功标志
- ✅ GitHub Actions所有步骤显示绿色✓
- ✅ Artifacts区域有APK文件可下载
- ✅ APK能在Android 8.0+手机安装
- ✅ 应用能正常启动和注册登录

## 📞 需要帮助？
告诉我您卡在哪一步，我会提供具体解决方案。

**现在就开始吧！只需15分钟，您就能在手机上使用自己的跑步应用。** 🏃‍♂️