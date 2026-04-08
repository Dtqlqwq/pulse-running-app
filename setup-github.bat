@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ========================================
echo    Pulse应用GitHub仓库设置向导
echo ========================================
echo.

:CHECK_GIT
echo [1/6] 检查Git安装...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Git未安装！
    echo    请先安装Git：https://git-scm.com/download/win
    echo    安装完成后重新运行此脚本
    pause
    exit /b 1
)
echo ✅ Git已安装

:CHECK_DIR
echo.
echo [2/6] 检查当前目录...
if not exist "package.json" (
    echo ❌ 未在项目根目录找到package.json
    echo    请将本脚本放在d:\pacex目录下运行
    pause
    exit /b 1
)
echo ✅ 正在正确的项目目录中

:INIT_GIT
echo.
echo [3/6] 初始化Git仓库...
if exist ".git" (
    echo ⚠  已存在Git仓库，跳过初始化
) else (
    git init
    if %errorlevel% neq 0 (
        echo ❌ Git初始化失败
        pause
        exit /b 1
    )
    echo ✅ Git仓库初始化成功
)

:CHECK_ENV
echo.
echo [4/6] 检查环境变量文件...
if not exist ".env.local" (
    echo ⚠  未找到.env.local文件
    echo    请确保您已配置Supabase环境变量
) else (
    echo ✅ 找到.env.local文件
    echo    ⚠ 重要：此文件包含敏感信息，不会上传到GitHub
)

if not exist ".env.example" (
    echo ⚠  创建.env.example模板文件...
    copy /y nul .env.example >nul
    echo # Supabase Configuration > .env.example
    echo VITE_SUPABASE_URL=https://your-project.supabase.co >> .env.example
    echo VITE_SUPABASE_ANON_KEY=your-anon-key-here >> .env.example
    echo ✅ 已创建.env.example文件
)

:ADD_FILES
echo.
echo [5/6] 添加文件到Git...
git add .
if %errorlevel% neq 0 (
    echo ❌ 添加文件失败
    pause
    exit /b 1
)

git commit -m "初始提交：Pulse跑步应用"
if %errorlevel% neq 0 (
    echo ❌ 提交失败
    pause
    exit /b 1
)
echo ✅ 文件已提交

:CONNECT_GITHUB
echo.
echo [6/6] 连接到GitHub...
echo.
echo 请按照以下步骤操作：
echo.
echo 1. 登录GitHub (https://github.com)
echo 2. 点击右上角 "+" → "New repository"
echo 3. 填写：
echo    - Repository name: pulse-running-app
echo    - Description: Pulse跑步追踪和AI教练应用
echo    - 选择 Public
echo    - 不要勾选 "Initialize with README"
echo 4. 点击 "Create repository"
echo.
echo 创建后，您会看到一个页面，上面有远程仓库地址
echo 看起来像：https://github.com/您的用户名/pulse-running-app.git
echo.
set /p GITHUB_URL="请输入您的GitHub仓库URL: "

if "%GITHUB_URL%"=="" (
    echo ⚠  未提供URL，跳过此步骤
    goto :SHOW_NEXT_STEPS
)

git remote add origin "%GITHUB_URL%"
if %errorlevel% neq 0 (
    echo ❌ 添加远程仓库失败
    echo    可能已经存在远程仓库配置
)

git branch -M main
git push -u origin main
if %errorlevel% neq 0 (
    echo ❌ 推送到GitHub失败
    echo    可能原因：
    echo    - 网络问题
    echo    - 认证问题（需要用户名/密码或个人访问令牌）
    echo.
    echo 您可以稍后手动运行：
    echo   git push -u origin main
) else (
    echo ✅ 代码已推送到GitHub！
)

:SHOW_NEXT_STEPS
echo.
echo ========================================
echo    下一步操作指南
echo ========================================
echo.
echo 1. 如果成功推送到GitHub：
echo    - 访问您的仓库: %GITHUB_URL%
echo    - 点击 "Actions" 标签页
echo    - 点击 "Build Android APK" 工作流
echo    - 点击 "Run workflow" → "Run workflow"
echo.
echo 2. 等待构建完成（约5-10分钟）
echo.
echo 3. 构建完成后：
echo    - 在 "Artifacts" 部分下载APK文件
echo    - 将APK传输到Android手机安装
echo.
echo 4. 如果需要帮助：
echo    - 查看 d:\pacex\GITHUB_SETUP_GUIDE.md 文件
echo    - 或告诉我具体遇到的问题
echo.
echo ========================================
echo    重要提示
echo ========================================
echo.
echo ⚠  确保已设置GitHub仓库的Secrets：
echo    1. 进入仓库 Settings → Secrets and variables → Actions
echo    2. 添加以下Repository secrets：
echo       - VITE_SUPABASE_URL: 您的Supabase项目URL
echo       - VITE_SUPABASE_ANON_KEY: 您的Supabase匿名密钥
echo.
pause