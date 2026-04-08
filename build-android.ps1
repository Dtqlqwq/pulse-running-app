# Pulse跑步应用Android构建脚本
# 使用方法：以管理员身份运行PowerShell，执行：.\build-android.ps1

Write-Host "🔧 Pulse跑步应用Android构建脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 检查是否以管理员身份运行
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ 请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "   右键点击PowerShell，选择'以管理员身份运行'" -ForegroundColor Yellow
    pause
    exit 1
}

# 函数：检查命令是否存在
function Test-Command {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    } catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}

# 1. 检查Java安装
Write-Host "`n[1/5] 检查Java环境..." -ForegroundColor Green
$javaInstalled = Test-Command "java"
$javacInstalled = Test-Command "javac"

if (-NOT $javaInstalled -OR -NOT $javacInstalled) {
    Write-Host "❌ Java JDK未安装或未正确配置" -ForegroundColor Red
    Write-Host "   请选择安装方法：" -ForegroundColor Yellow
    Write-Host "   1. 自动安装Eclipse Temurin JDK 17" -ForegroundColor Yellow
    Write-Host "   2. 手动安装（推荐给有经验的用户）" -ForegroundColor Yellow
    Write-Host "   3. 使用GitHub Actions在线构建（无需本地安装）" -ForegroundColor Yellow

    $choice = Read-Host "请输入选项 (1/2/3)"

    if ($choice -eq "1") {
        Write-Host "正在下载Eclipse Temurin JDK 17..." -ForegroundColor Yellow
        # 下载JDK
        $jdkUrl = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.10_7.msi"
        $downloadPath = "$env:TEMP\jdk-17.msi"

        try {
            Invoke-WebRequest -Uri $jdkUrl -OutFile $downloadPath
            Write-Host "✅ JDK下载完成，开始安装..." -ForegroundColor Green

            # 静默安装
            Start-Process msiexec.exe -Wait -ArgumentList "/i `"$downloadPath`" /quiet /norestart"

            # 设置环境变量
            $jdkPath = "C:\Program Files\Eclipse Adoptium\jdk-17.0.10.7-hotspot"
            if (Test-Path $jdkPath) {
                [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "Machine")
                [Environment]::SetEnvironmentVariable("Path", "$env:Path;$jdkPath\bin", "Machine")
                Write-Host "✅ Java安装完成！需要重启终端使环境变量生效" -ForegroundColor Green
                Write-Host "   请关闭所有终端窗口，然后重新以管理员身份运行此脚本" -ForegroundColor Yellow
                pause
                exit 0
            }
        } catch {
            Write-Host "❌ Java安装失败: $_" -ForegroundColor Red
            Write-Host "   请手动下载：https://adoptium.net/temurin/releases/" -ForegroundColor Yellow
            pause
            exit 1
        }
    } elseif ($choice -eq "2") {
        Write-Host "`n请手动执行以下步骤：" -ForegroundColor Yellow
        Write-Host "1. 访问 https://adoptium.net/temurin/releases/" -ForegroundColor Cyan
        Write-Host "2. 下载 Windows x64 JDK 17" -ForegroundColor Cyan
        Write-Host "3. 运行安装程序" -ForegroundColor Cyan
        Write-Host "4. 设置环境变量：" -ForegroundColor Cyan
        Write-Host "   JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.x.x.x-hotspot" -ForegroundColor Cyan
        Write-Host "   Path += %JAVA_HOME%\bin" -ForegroundColor Cyan
        Write-Host "5. 重新打开终端并运行此脚本" -ForegroundColor Cyan
        pause
        exit 0
    } else {
        Write-Host "`nGitHub Actions在线构建方法：" -ForegroundColor Cyan
        Write-Host "1. 创建GitHub账号（如果还没有）" -ForegroundColor Yellow
        Write-Host "2. 创建新仓库" -ForegroundColor Yellow
        Write-Host "3. 上传所有代码文件" -ForegroundColor Yellow
        Write-Host "4. 进入 Actions 标签页" -ForegroundColor Yellow
        Write-Host "5. 运行 'Build Android APK' 工作流" -ForegroundColor Yellow
        Write-Host "6. 下载生成的APK文件" -ForegroundColor Yellow
        Write-Host "`n脚本目录下已包含 .github/workflows/build-android.yml 文件" -ForegroundColor Green
        pause
        exit 0
    }
} else {
    Write-Host "✅ Java已安装" -ForegroundColor Green
    $javaVersion = cmd /c "java -version 2>&1"
    Write-Host "   版本信息：$javaVersion" -ForegroundColor Cyan
}

# 2. 检查Node.js和npm
Write-Host "`n[2/5] 检查Node.js环境..." -ForegroundColor Green
if (-NOT (Test-Command "node")) {
    Write-Host "❌ Node.js未安装" -ForegroundColor Red
    Write-Host "   请从 https://nodejs.org 下载并安装Node.js 18+" -ForegroundColor Yellow
    pause
    exit 1
} else {
    Write-Host "✅ Node.js已安装" -ForegroundColor Green
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "   Node.js: $nodeVersion" -ForegroundColor Cyan
    Write-Host "   npm: $npmVersion" -ForegroundColor Cyan
}

# 3. 安装项目依赖
Write-Host "`n[3/5] 安装项目依赖..." -ForegroundColor Green
try {
    npm install
    npm install @capacitor/core @capacitor/cli @capacitor/android @capacitor/geolocation --force
    Write-Host "✅ 依赖安装完成" -ForegroundColor Green
} catch {
    Write-Host "❌ 依赖安装失败: $_" -ForegroundColor Red
    pause
    exit 1
}

# 4. 构建Web应用
Write-Host "`n[4/5] 构建Web应用..." -ForegroundColor Green
try {
    npm run build
    Write-Host "✅ Web应用构建完成" -ForegroundColor Green
} catch {
    Write-Host "❌ Web应用构建失败: $_" -ForegroundColor Red
    pause
    exit 1
}

# 5. 构建Android APK
Write-Host "`n[5/5] 构建Android APK..." -ForegroundColor Green
try {
    # 同步到Android项目
    npx cap sync android
    Write-Host "✅ 项目同步完成" -ForegroundColor Green

    # 构建APK
    cd android
    if (-NOT (Test-Path "gradlew")) {
        Write-Host "❌ gradlew文件不存在" -ForegroundColor Red
        pause
        exit 1
    }

    Write-Host "正在构建APK，这可能需要几分钟..." -ForegroundColor Yellow
    ./gradlew assembleDebug

    # 检查APK文件
    $apkPath = "app/build/outputs/apk/debug/app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "✅ APK构建成功！" -ForegroundColor Green
        Write-Host "   文件位置：$apkPath" -ForegroundColor Cyan
        Write-Host "   文件大小：$apkSize MB" -ForegroundColor Cyan
        Write-Host "`n📱 安装方法：" -ForegroundColor Yellow
        Write-Host "   1. 将APK文件复制到手机" -ForegroundColor Cyan
        Write-Host "   2. 在手机文件管理器中点击安装" -ForegroundColor Cyan
        Write-Host "   3. 如果提示'未知来源'，请允许安装" -ForegroundColor Cyan

        # 尝试打开文件所在目录
        $apkDir = Split-Path $apkPath -Parent
        explorer $apkDir
    } else {
        Write-Host "❌ APK文件未找到" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Android构建失败: $_" -ForegroundColor Red
    Write-Host "   错误详情：" -ForegroundColor Yellow
    $_
}

Write-Host "`n🔧 构建完成！" -ForegroundColor Cyan
pause