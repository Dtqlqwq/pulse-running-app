# 一键式GitHub设置指南

## 🎯 目标：让您10分钟内获得APK文件

### 您需要准备的东西：
1. ✅ **GitHub账号**（您已经有了）
2. ⏳ **15分钟时间**
3. 📱 **Android手机**（用于安装测试）

## 📝 第一步：收集必要信息

在开始之前，请打开您的 `.env.local` 文件，找到以下两个值：

```
VITE_SUPABASE_URL=https://ofocnypllewqnthrimda.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**请复制这两个值**，稍后需要粘贴到GitHub。

## 🚀 第二步：运行自动化脚本

### 如果已经安装Git：
1. 在 `d:\pacex` 目录右键 → "Git Bash Here"
2. 运行：
   ```bash
   ./setup-github.bat
   ```

### 如果未安装Git：
1. **下载Git**：https://git-scm.com/download/win
2. 运行安装程序，**全部使用默认选项**
3. 安装完成后重启电脑
4. 然后运行上面的脚本

## 🌐 第三步：在GitHub创建仓库

### 方法A：使用脚本自动创建（如果脚本支持）
按照脚本提示操作。

### 方法B：手动创建
1. 访问：https://github.com/new
2. 填写：
   - **Repository name**: `pulse-running-app`
   - **Description**: `Pulse跑步追踪和AI教练应用`
   - 选择 **Public**（公开）
   - **不要勾选** "Initialize with README"
3. 点击 **Create repository**

## 🔐 第四步：设置GitHub Secrets（最重要！）

**这是构建成功的关键**，否则应用无法连接Supabase。

### 详细步骤：
1. 进入您的仓库页面：`https://github.com/您的用户名/pulse-running-app`
2. 点击 **Settings**（在仓库名称下方）
   ![](https://docs.github.com/assets/cb-77744/mw-1440/images/help/repository/repo-actions-settings.webp)
3. 左侧点击 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**

### 添加第一个Secret：
- **Name**: `VITE_SUPABASE_URL`
- **Value**: 从 `.env.local` 复制的URL
  `https://ofocnypllewqnthrimda.supabase.co`
- 点击 **Add secret**

### 添加第二个Secret：
- **Name**: `VITE_SUPABASE_ANON_KEY`
- **Value**: 从 `.env.local` 复制的长字符串
  以 `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` 开头
- 点击 **Add secret**

**完成后的截图应该显示两个secrets**。

## 📤 第五步：上传代码到GitHub

### 如果脚本成功运行：
代码应该已经上传。检查仓库页面是否有文件。

### 如果需要手动上传：
```bash
# 在Git Bash中运行
cd d:\pacex
git add .
git commit -m "初始提交"
git branch -M main
git push -u origin main
```

**如果要求输入用户名密码**：
- 用户名：您的GitHub用户名
- 密码：使用 **Personal Access Token**
  - 生成Token：https://github.com/settings/tokens
  - 选择 `repo` 权限
  - 复制Token作为密码

## ⚙️ 第六步：触发构建

1. 进入仓库页面：`https://github.com/您的用户名/pulse-running-app`
2. 点击顶部 **Actions** 标签
   ![](https://docs.github.com/assets/cb-29107/mw-1440/images/help/repository/actions-tab.webp)
3. 您会看到 **Build Android APK** 工作流
4. 点击右侧 **Run workflow** → 再次点击 **Run workflow**

## ⏳ 第七步：等待构建完成

**构建过程**：
- ✅ 设置环境（约1分钟）
- ✅ 安装依赖（约2分钟）
- ✅ 构建Web应用（约1分钟）
- ✅ 配置Android（约2分钟）
- ✅ 构建APK（约3分钟）
- ✅ 上传APK（约1分钟）

**总共约10分钟**。

**如何查看进度**：
- 点击运行中的工作流
- 查看实时日志输出
- 等待所有步骤变绿 ✓

## 📥 第八步：下载APK

构建完成后：
1. 在工作流页面找到 **Artifacts** 区域
2. 点击 **pulse-app-debug-apk**
3. 下载 `app-debug.apk` 文件

**文件位置**：`android/app/build/outputs/apk/debug/app-debug.apk`

## 📱 第九步：安装到手机

### 方法A：USB传输
1. 连接手机到电脑
2. 复制APK到手机
3. 在手机文件管理器中点击安装

### 方法B：云存储传输
1. 上传APK到百度网盘/Google Drive
2. 在手机上下载
3. 点击安装

### 方法C：邮件发送
1. 将APK作为邮件附件发送给自己
2. 在手机上接收邮件
3. 下载并安装

## 🧪 第十步：测试应用

### 基本功能测试：
- [ ] 应用正常启动
- [ ] 点击"注册"创建账号
- [ ] 登录后显示跑步页面
- [ ] 点击底部导航切换页面

### GPS功能测试：
- [ ] 点击"▶"开始跑步
- [ ] 允许位置权限
- [ ] 显示"📍 GPS定位中..."
- [ ] 移动时距离增加

### 其他功能测试：
- [ ] STATS页面显示数据
- [ ] PROFILE页面显示个人信息
- [ ] AI COACH能发送消息

## 🆘 故障排除

### 问题1：构建失败
**常见原因**：
- ❌ 未设置GitHub Secrets
- ❌ Supabase密钥错误
- ❌ 网络问题

**解决方案**：
1. 检查工作流日志中的错误信息
2. 确保Secrets正确设置
3. 重新运行工作流

### 问题2：APK安装失败
**解决方案**：
1. 卸载手机上已有的同名应用
2. 开启"未知来源"安装权限
3. 重启手机后重试

### 问题3：GPS无法定位
**解决方案**：
1. 检查手机位置服务是否开启
2. 在应用权限中允许位置访问
3. 在室外空旷区域测试

## 📞 需要进一步帮助？

如果您在以下步骤卡住：

### 步骤1-3（Git和仓库设置）
提供以下信息：
1. Git是否安装成功？
2. 能否打开Git Bash？
3. 仓库是否创建成功？

### 步骤4（GitHub Secrets设置）
提供以下信息：
1. 能否找到Settings → Secrets？
2. 是否成功添加了两个secrets？
3. 截图显示什么错误？

### 步骤5-6（代码上传和构建）
提供以下信息：
1. 代码上传是否成功？
2. GitHub Actions工作流是否显示？
3. 构建日志中的错误信息是什么？

### 步骤7-8（APK下载和安装）
提供以下信息：
1. 能否看到Artifacts区域？
2. APK文件是否成功下载？
3. 手机安装时显示什么错误？

## 🎉 恭喜！

成功完成以上步骤后，您将拥有：

1. ✅ 一个自动化的Android应用构建流水线
2. ✅ 可在任何Android 8.0+设备上安装的APK
3. ✅ 完整的跑步追踪和AI教练功能
4. ✅ 代码托管在GitHub，便于后续更新

**每次更新代码后**，只需：
1. 推送代码到GitHub
2. GitHub Actions会自动构建新APK
3. 下载新版APK安装

---

## ⚡ 快速检查清单

- [ ] 已安装Git
- [ ] 已运行 `setup-github.bat`
- [ ] 已在GitHub创建仓库
- [ ] 已设置两个GitHub Secrets
- [ ] 代码已推送到GitHub
- [ ] 已触发GitHub Actions构建
- [ ] 已下载APK文件
- [ ] 已安装到手机测试

**现在就开始吧！** 按照以上步骤操作，您很快就能在手机上使用自己的跑步应用了。🏃‍♂️