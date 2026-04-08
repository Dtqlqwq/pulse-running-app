# GitHub Actions构建APK - 详细操作指南

## 📋 准备工作

### 需要安装的软件（如果还没有）：
1. **Git** - 版本控制工具
   - 下载：https://git-scm.com/download/win
   - 安装时选择默认选项即可

2. **GitHub账号** - 您已经拥有

## 🚀 完整操作步骤

### 步骤1：在GitHub创建新仓库

1. 登录GitHub：https://github.com
2. 点击右上角 "+" → "New repository"
3. 填写仓库信息：
   - **Repository name**: `pulse-running-app`（或其他名称）
   - **Description**: `Pulse跑步追踪和AI教练应用`
   - 选择 **Public**（公开，免费）
   - **不要勾选** "Initialize this repository with a README"
   - 点击 **Create repository**

### 步骤2：在本地准备代码

**重要：保护敏感信息**
您的 `.env.local` 文件包含Supabase密钥，**不要上传到GitHub**！

1. **创建.gitignore文件**（我已经为您创建好了）
   - 检查 `d:\pacex\.gitignore` 文件
   - 确保包含以下内容：
     ```
     # 环境变量
     .env.local
     .env.*.local
     
     # 依赖目录
     node_modules/
     
     # 构建输出
     dist/
     android/build/
     android/app/build/
     
     # 系统文件
     .DS_Store
     Thumbs.db
     
     # IDE文件
     .vscode/
     .idea/
     
     # 日志文件
     npm-debug.log*
     yarn-debug.log*
     yarn-error.log*
     ```

2. **创建用于GitHub的.env.example文件**
   ```bash
   # 在项目根目录创建.env.example文件，内容如下：
   VITE_SUPABASE_URL=您的Supabase项目URL
   VITE_SUPABASE_ANON_KEY=您的Supabase匿名密钥
   ```

### 步骤3：初始化git仓库并推送代码

#### 方法A：使用Git Bash（推荐）

1. **打开Git Bash**
   - 在 `d:\pacex` 目录右键 → "Git Bash Here"

2. **执行以下命令**：
   ```bash
   # 1. 初始化git仓库
   git init
   
   # 2. 添加所有文件（除了.gitignore中排除的）
   git add .
   
   # 3. 提交代码
   git commit -m "初始提交：Pulse跑步应用"
   
   # 4. 连接到GitHub仓库
   # 将 YOUR_USERNAME 替换为您的GitHub用户名
   git remote add origin https://github.com/YOUR_USERNAME/pulse-running-app.git
   
   # 5. 推送代码
   git branch -M main
   git push -u origin main
   ```

#### 方法B：使用命令提示符（CMD）

1. **打开命令提示符**
   - 按 `Win + R`，输入 `cmd`，按回车
   - 切换到项目目录：
     ```cmd
     cd d:\pacex
     ```

2. **执行以下命令**：
   ```cmd
   :: 1. 初始化git仓库
   git init
   
   :: 2. 添加所有文件
   git add .
   
   :: 3. 提交代码
   git commit -m "初始提交：Pulse跑步应用"
   
   :: 4. 连接到GitHub仓库
   :: 将 YOUR_USERNAME 替换为您的GitHub用户名
   git remote add origin https://github.com/YOUR_USERNAME/pulse-running-app.git
   
   :: 5. 推送代码
   git branch -M main
   git push -u origin main
   ```

#### 方法C：使用GitHub Desktop（图形界面）

1. **下载GitHub Desktop**：https://desktop.github.com
2. **安装并登录**您的GitHub账号
3. **添加仓库**：
   - 点击 "File" → "Add Local Repository"
   - 选择 `d:\pacex` 目录
   - 点击 "Add Repository"
4. **提交代码**：
   - 在左侧勾选所有文件
   - 填写提交信息："初始提交：Pulse跑步应用"
   - 点击 "Commit to main"
5. **发布到GitHub**：
   - 点击 "Publish repository"
   - 仓库名：`pulse-running-app`
   - 选择 "Public"
   - 点击 "Publish Repository"

### 步骤4：触发GitHub Actions构建

1. **进入GitHub仓库页面**
   - 地址：https://github.com/YOUR_USERNAME/pulse-running-app

2. **点击"Actions"标签页**
   - 在顶部导航栏中点击"Actions"

3. **运行工作流**
   - 您会看到 "Build Android APK" 工作流
   - 点击右侧 "Run workflow"
   - 点击绿色 "Run workflow" 按钮

4. **等待构建完成**
   - 构建过程大约需要5-10分钟
   - 您可以看到实时构建日志

### 步骤5：下载APK文件

1. **构建完成后**
   - 工作流状态变为绿色 ✓
   - 点击工作流名称查看详情

2. **下载APK**
   - 在 "Artifacts" 部分找到 "pulse-app-debug-apk"
   - 点击下载

3. **安装到手机**
   - 将APK文件传输到Android手机
   - 在文件管理器中点击安装
   - 如果提示"未知来源"，请允许安装

## 🔧 常见问题解决

### 问题1：git push 要求用户名和密码
**解决**：使用个人访问令牌代替密码
1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token"
3. 选择 "repo" 权限
4. 复制生成的令牌
5. 在git push时使用令牌作为密码

### 问题2：文件太大无法推送
**解决**：检查.gitignore是否正确
```bash
# 删除已缓存的大文件
git rm -r --cached node_modules
git rm -r --cached android/build
git rm -r --cached android/app/build

# 重新提交
git add .
git commit -m "移除大文件"
git push
```

### 问题3：GitHub Actions构建失败
**解决**：查看错误日志
1. 点击失败的工作流
2. 查看红色❌的步骤
3. 常见原因：
   - 缺少环境变量
   - Java版本不兼容
   - 网络问题

## 📝 环境变量配置（如果需要）

GitHub Actions工作流需要Supabase环境变量才能正常工作：

1. **进入仓库Settings**
   - 点击 "Settings" → "Secrets and variables" → "Actions"

2. **添加环境变量**
   - 点击 "New repository secret"
   - 添加以下两个变量：
     - `VITE_SUPABASE_URL`: 您的Supabase项目URL
     - `VITE_SUPABASE_ANON_KEY`: 您的Supabase匿名密钥

3. **更新工作流文件**
   我已经为您配置的工作流会自动使用这些环境变量。

## ✅ 验证构建成功

构建完成后，您应该看到：
1. ✅ 所有步骤显示绿色对勾
2. 📦 "Artifacts" 部分有APK文件可供下载
3. 📱 APK文件大小约15-25MB

## 🆘 需要帮助？

如果遇到问题：

1. **检查步骤**：确保严格按照指南操作
2. **查看错误信息**：GitHub Actions会显示详细的错误日志
3. **重新运行**：有时网络问题会导致失败，可以重新运行工作流
4. **联系支持**：将错误信息截图，我可以帮您分析

## 🎉 恭喜！

成功完成以上步骤后，您将获得：
1. 一个功能完整的Android跑步应用APK
2. 自动化的构建流水线
3. 代码托管在GitHub，便于后续更新

**接下来**：安装APK到手机，测试所有功能是否正常工作！