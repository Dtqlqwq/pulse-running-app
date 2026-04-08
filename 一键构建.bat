@echo off
chcp 65001 >nul
title Pulse跑步应用 - 一键构建APK
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                   Pulse跑步应用 - 一键构建APK               ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 请以管理员身份运行此脚本！
    echo    右键点击此文件，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo 📦 检查必要软件安装...
echo.

:CHECK_GIT
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Git未安装！
    echo    正在为您安装Git...

    REM 下载Git安装程序
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.45.0.windows.1/Git-2.45.0-64-bit.exe' -OutFile '%TEMP%\Git-Installer.exe' -UseBasicParsing"

    if exist "%TEMP%\Git-Installer.exe" (
        echo    正在安装Git，请稍候...
        start /wait "" "%TEMP%\Git-Installer.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS
        timeout /t 10 /nobreak >nul

        REM 添加Git到PATH
        setx PATH "%PATH%;C:\Program Files\Git\cmd" /m >nul

        echo ✅ Git安装完成！需要重启终端
        echo.
        echo    请关闭所有窗口，然后重新以管理员身份运行此脚本
        pause
        exit /b 0
    ) else (
        echo ❌ Git下载失败，请手动安装：
        echo    访问 https://git-scm.com/download/win
        pause
        exit /b 1
    )
) else (
    echo ✅ Git已安装
    git --version
)

echo.

:CHECK_NODE
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js未安装！
    echo    请手动安装Node.js 18+
    echo    访问 https://nodejs.org
    pause
    exit /b 1
) else (
    echo ✅ Node.js已安装
    node --version
)

echo.

:CHECK_ENV
echo 📝 检查环境配置...
if not exist ".env.local" (
    echo ⚠  未找到.env.local文件
    echo    请确保已配置Supabase环境变量
    goto :ASK_CONTINUE
) else (
    echo ✅ 找到环境配置文件
)

:ASK_CONTINUE
echo.
echo ========================================
echo    开始自动化构建流程
echo ========================================
echo.
echo 此脚本将帮助您：
echo 1. 自动设置Git仓库
echo 2. 创建GitHub仓库（如果还没有）
echo 3. 配置GitHub Secrets
echo 4. 推送代码到GitHub
echo 5. 触发APK构建
echo.
echo 您需要准备：
echo - GitHub用户名
echo - GitHub个人访问令牌（需要有repo权限）
echo - Supabase项目URL和密钥（从.env.local获取）
echo.
set /p CONTINUE="是否继续？(y/n): "

if /i not "%CONTINUE%"=="y" (
    echo 已取消
    pause
    exit /b 0
)

:RUN_POWERSHELL
echo.
echo 🚀 启动自动化脚本...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0automate-all.ps1"

echo.
echo ========================================
echo    自动化脚本执行完成
echo ========================================
echo.
echo 📋 后续操作：
echo 1. 如果脚本成功，请等待GitHub Actions构建完成
echo 2. 访问您的GitHub仓库 → Actions标签页
echo 3. 下载生成的APK文件
echo 4. 安装到Android手机测试
echo.
echo 📞 如需帮助：
echo - 查看 automte-all.ps1 的详细输出
echo - 或提供具体错误信息
echo.
pause