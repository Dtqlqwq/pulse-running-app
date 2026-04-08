# Pulse跑步应用 - 全自动GitHub设置和APK构建脚本
# 使用方法：以管理员身份运行PowerShell，执行：.\automate-all.ps1

param(
    [string]$GitHubUsername,
    [string]$GitHubToken,
    [string]$SupabaseUrl,
    [string]$SupabaseKey
)

Write-Host "🔧 Pulse应用全自动部署脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 检查管理员权限
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-NOT (Test-Administrator)) {
    Write-Host "❌ 请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "   右键点击PowerShell，选择'以管理员身份运行'" -ForegroundColor Yellow
    pause
    exit 1
}

# 检查Git安装
function Test-GitInstallation {
    try {
        $gitVersion = git --version 2>$null
        return $null -ne $gitVersion
    } catch {
        return $false
    }
}

# 检查并安装Git
function Install-Git {
    Write-Host "`n📦 检查Git安装..." -ForegroundColor Green

    if (Test-GitInstallation) {
        Write-Host "✅ Git已安装" -ForegroundColor Green
        $gitVersion = git --version
        Write-Host "   版本: $gitVersion" -ForegroundColor Cyan
        return $true
    }

    Write-Host "❌ Git未安装" -ForegroundColor Red
    Write-Host "   正在下载Git安装程序..." -ForegroundColor Yellow

    $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.45.0.windows.1/Git-2.45.0-64-bit.exe"
    $installerPath = "$env:TEMP\Git-Installer.exe"

    try {
        # 下载Git安装程序
        Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $installerPath -UseBasicParsing

        Write-Host "✅ Git安装程序下载完成" -ForegroundColor Green
        Write-Host "   正在启动安装程序..." -ForegroundColor Yellow

        # 静默安装Git
        Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS" -Wait

        # 等待安装完成
        Start-Sleep -Seconds 10

        # 添加到PATH
        $gitPath = "C:\Program Files\Git\cmd"
        if (Test-Path $gitPath) {
            $env:Path += ";$gitPath"
            [Environment]::SetEnvironmentVariable("Path", $env:Path, "Machine")
        }

        Write-Host "✅ Git安装完成！需要重启终端" -ForegroundColor Green
        Write-Host "   请关闭所有终端窗口，然后重新以管理员身份运行此脚本" -ForegroundColor Yellow

        # 询问是否立即重启终端
        $choice = Read-Host "`n是否立即关闭终端并重新运行？(y/n)"
        if ($choice -eq 'y') {
            # 保存当前状态并重新运行
            $scriptPath = $MyInvocation.MyCommand.Path
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
            exit 0
        } else {
            Write-Host "`n请手动重新运行此脚本" -ForegroundColor Yellow
            pause
            exit 0
        }

    } catch {
        Write-Host "❌ Git安装失败: $_" -ForegroundColor Red
        Write-Host "   请手动下载安装: https://git-scm.com/download/win" -ForegroundColor Yellow
        return $false
    }
}

# 检查Node.js
function Test-NodeInstallation {
    try {
        $nodeVersion = node --version 2>$null
        return $null -ne $nodeVersion
    } catch {
        return $false
    }
}

# 收集用户输入
function Get-UserInput {
    Write-Host "`n📝 请提供以下信息：" -ForegroundColor Green

    # 获取GitHub用户名
    if ([string]::IsNullOrEmpty($GitHubUsername)) {
        $script:GitHubUsername = Read-Host "GitHub用户名"
    }

    # 获取GitHub Token
    if ([string]::IsNullOrEmpty($GitHubToken)) {
        Write-Host "`n🔐 需要GitHub个人访问令牌：" -ForegroundColor Yellow
        Write-Host "   1. 访问 https://github.com/settings/tokens" -ForegroundColor Cyan
        Write-Host "   2. 点击 'Generate new token'" -ForegroundColor Cyan
        Write-Host "   3. 选择 'repo' 权限" -ForegroundColor Cyan
        Write-Host "   4. 复制生成的令牌" -ForegroundColor Cyan
        $script:GitHubToken = Read-Host "GitHub个人访问令牌"
    }

    # 获取Supabase信息
    if ([string]::IsNullOrEmpty($SupabaseUrl)) {
        # 尝试从.env.local读取
        $envFile = ".env.local"
        if (Test-Path $envFile) {
            $envContent = Get-Content $envFile
            foreach ($line in $envContent) {
                if ($line -match "^VITE_SUPABASE_URL=(.+)") {
                    $script:SupabaseUrl = $matches[1]
                }
                if ($line -match "^VITE_SUPABASE_ANON_KEY=(.+)") {
                    $script:SupabaseKey = $matches[1]
                }
            }
        }

        if ([string]::IsNullOrEmpty($script:SupabaseUrl)) {
            $script:SupabaseUrl = Read-Host "Supabase项目URL (如: https://xxx.supabase.co)"
        }
        if ([string]::IsNullOrEmpty($script:SupabaseKey)) {
            $script:SupabaseKey = Read-Host "Supabase匿名密钥"
        }
    }
}

# 初始化Git仓库
function Initialize-GitRepository {
    Write-Host "`n📁 初始化Git仓库..." -ForegroundColor Green

    if (Test-Path ".git") {
        Write-Host "✅ Git仓库已存在" -ForegroundColor Green
        return $true
    }

    try {
        git init
        git add .
        git commit -m "初始提交：Pulse跑步应用"

        Write-Host "✅ Git仓库初始化完成" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Git初始化失败: $_" -ForegroundColor Red
        return $false
    }
}

# 使用GitHub API创建仓库
function Create-GitHubRepository {
    param(
        [string]$RepoName,
        [string]$Description,
        [string]$Username,
        [string]$Token
    )

    Write-Host "`n🌐 创建GitHub仓库..." -ForegroundColor Green

    $apiUrl = "https://api.github.com/user/repos"
    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
    }

    $body = @{
        name = $RepoName
        description = $Description
        private = $false
        auto_init = $false
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"

        Write-Host "✅ GitHub仓库创建成功！" -ForegroundColor Green
        Write-Host "   仓库URL: $($response.html_url)" -ForegroundColor Cyan

        return $response.clone_url
    } catch {
        Write-Host "❌ GitHub仓库创建失败: $_" -ForegroundColor Red

        # 显示详细错误
        if ($_.Exception.Response) {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            Write-Host "   错误详情: $errorBody" -ForegroundColor Red
        }

        # 提供手动创建选项
        Write-Host "`n📝 请手动创建仓库：" -ForegroundColor Yellow
        Write-Host "   1. 访问 https://github.com/new" -ForegroundColor Cyan
        Write-Host "   2. 仓库名: $RepoName" -ForegroundColor Cyan
        Write-Host "   3. 描述: $Description" -ForegroundColor Cyan
        Write-Host "   4. 选择 Public" -ForegroundColor Cyan
        Write-Host "   5. 不要勾选 'Initialize with README'" -ForegroundColor Cyan

        $repoUrl = Read-Host "`n创建后，请输入仓库URL (如: https://github.com/$Username/$RepoName.git)"

        return $repoUrl
    }
}

# 指导设置GitHub Secrets
function Guide-GitHubSecrets {
    param(
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$SupabaseUrl,
        [string]$SupabaseKey
    )

    Write-Host "`n🔐 设置GitHub Secrets（必须步骤）" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green

    Write-Host "`n📝 请按照以下步骤操作：" -ForegroundColor Yellow

    Write-Host "   1. 打开浏览器，访问：" -ForegroundColor Cyan
    Write-Host "      https://github.com/$RepoOwner/$RepoName/settings/secrets/actions" -ForegroundColor White -BackgroundColor DarkBlue

    Write-Host "`n   2. 点击 'New repository secret'" -ForegroundColor Cyan

    Write-Host "`n   3. 添加第一个Secret：" -ForegroundColor Cyan
    Write-Host "      Name: VITE_SUPABASE_URL" -ForegroundColor White
    Write-Host "      Value: $SupabaseUrl" -ForegroundColor White

    Write-Host "`n   4. 再次点击 'New repository secret'" -ForegroundColor Cyan

    Write-Host "`n   5. 添加第二个Secret：" -ForegroundColor Cyan
    Write-Host "      Name: VITE_SUPABASE_ANON_KEY" -ForegroundColor White
    Write-Host "      Value: $SupabaseKey" -ForegroundColor White

    Write-Host "`n   6. 点击 'Add secret' 保存" -ForegroundColor Cyan

    Write-Host "`n🔍 验证Secrets已设置：" -ForegroundColor Yellow
    Write-Host "   - 页面应该显示两个secrets" -ForegroundColor Cyan
    Write-Host "   - 名称: VITE_SUPABASE_URL 和 VITE_SUPABASE_ANON_KEY" -ForegroundColor Cyan

    # 询问用户是否已设置
    Write-Host "`n❓ 请确认：" -ForegroundColor Green
    Write-Host "   1. 是否已打开上述链接？" -ForegroundColor Cyan
    Write-Host "   2. 是否已添加两个secrets？" -ForegroundColor Cyan

    $choice = Read-Host "`n是否已完成Secrets设置？(y/n)"
    if ($choice -eq 'y') {
        Write-Host "✅ 继续下一步..." -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠  请先完成Secrets设置，否则构建会失败！" -ForegroundColor Red
        Write-Host "   按任意键重新打开指南..." -ForegroundColor Yellow
        pause
        return Guide-GitHubSecrets -RepoOwner $RepoOwner -RepoName $RepoName -SupabaseUrl $SupabaseUrl -SupabaseKey $SupabaseKey
    }
}

# 推送代码到GitHub
function Push-ToGitHub {
    param(
        [string]$RemoteUrl,
        [string]$Username,
        [string]$Token
    )

    Write-Host "`n📤 推送代码到GitHub..." -ForegroundColor Green

    try {
        # 添加远程仓库（如果还没有）
        $remotes = git remote -v
        if ($remotes -notmatch "origin") {
            # 在URL中包含token进行认证
            $authenticatedUrl = $RemoteUrl -replace "https://", "https://$Username:$Token@"
            git remote add origin $authenticatedUrl
        }

        # 重命名分支并推送
        git branch -M main
        git push -u origin main --force

        Write-Host "✅ 代码推送成功！" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "❌ 代码推送失败: $_" -ForegroundColor Red

        # 提供手动推送指导
        Write-Host "`n📝 请手动推送代码：" -ForegroundColor Yellow
        Write-Host "   在Git Bash中执行以下命令：" -ForegroundColor Cyan
        Write-Host "   git remote add origin $RemoteUrl" -ForegroundColor Cyan
        Write-Host "   git branch -M main" -ForegroundColor Cyan
        Write-Host "   git push -u origin main" -ForegroundColor Cyan
        Write-Host "`n   如果要求输入密码，请使用GitHub Token" -ForegroundColor Yellow

        return $false
    }
}

# 触发GitHub Actions工作流
function Trigger-GitHubActions {
    param(
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$Token
    )

    Write-Host "`n⚡ 触发GitHub Actions构建..." -ForegroundColor Green

    $workflowUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/workflows/build-android.yml/dispatches"

    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
    }

    $body = @{
        ref = "main"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $workflowUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"

        Write-Host "✅ GitHub Actions构建已触发！" -ForegroundColor Green
        Write-Host "   构建页面: https://github.com/$RepoOwner/$RepoName/actions" -ForegroundColor Cyan

        return $true
    } catch {
        Write-Host "❌ 触发构建失败: $_" -ForegroundColor Red

        Write-Host "`n📝 请手动触发构建：" -ForegroundColor Yellow
        Write-Host "   1. 访问 https://github.com/$RepoOwner/$RepoName/actions" -ForegroundColor Cyan
        Write-Host "   2. 点击 'Build Android APK' 工作流" -ForegroundColor Cyan
        Write-Host "   3. 点击 'Run workflow' → 'Run workflow'" -ForegroundColor Cyan

        return $false
    }
}

# 显示后续步骤
function Show-NextSteps {
    param(
        [string]$RepoOwner,
        [string]$RepoName
    )

    Write-Host "`n🎉 恭喜！自动化设置完成！" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan

    Write-Host "`n📋 后续步骤：" -ForegroundColor Green
    Write-Host "   1. 等待构建完成（约10分钟）" -ForegroundColor Cyan
    Write-Host "      👉 https://github.com/$RepoOwner/$RepoName/actions" -ForegroundColor Yellow
    Write-Host "`n   2. 下载APK文件" -ForegroundColor Cyan
    Write-Host "      - 构建完成后，在 'Artifacts' 区域下载" -ForegroundColor Yellow
    Write-Host "      - 文件: pulse-app-debug-apk" -ForegroundColor Yellow
    Write-Host "`n   3. 安装到手机" -ForegroundColor Cyan
    Write-Host "      - 将APK传输到Android手机" -ForegroundColor Yellow
    Write-Host "      - 在文件管理器中点击安装" -ForegroundColor Yellow
    Write-Host "      - 如果提示'未知来源'，请允许安装" -ForegroundColor Yellow
    Write-Host "`n   4. 测试应用功能" -ForegroundColor Cyan
    Write-Host "      - 注册/登录账号" -ForegroundColor Yellow
    Write-Host "      - 测试GPS跑步追踪" -ForegroundColor Yellow
    Write-Host "      - 查看数据统计" -ForegroundColor Yellow
    Write-Host "      - 与AI教练聊天" -ForegroundColor Yellow

    Write-Host "`n🔗 重要链接：" -ForegroundColor Green
    Write-Host "   📂 仓库: https://github.com/$RepoOwner/$RepoName" -ForegroundColor Cyan
    Write-Host "   ⚡ 构建: https://github.com/$RepoOwner/$RepoName/actions" -ForegroundColor Cyan
    Write-Host "   ⚙  Settings: https://github.com/$RepoOwner/$RepoName/settings" -ForegroundColor Cyan

    Write-Host "`n🆘 需要帮助？" -ForegroundColor Yellow
    Write-Host "   如果构建失败或遇到问题，请提供：" -ForegroundColor Cyan
    Write-Host "   - GitHub Actions错误日志" -ForegroundColor Yellow
    Write-Host "   - 具体错误信息" -ForegroundColor Yellow

    # 打开浏览器查看仓库
    $choice = Read-Host "`n是否立即打开GitHub仓库页面？(y/n)"
    if ($choice -eq 'y') {
        Start-Process "https://github.com/$RepoOwner/$RepoName"
    }

    pause
}

# 主函数
function Main {
    Write-Host "🔧 开始自动化部署流程..." -ForegroundColor Green

    # 检查并安装Git
    if (-NOT (Install-Git)) {
        pause
        exit 1
    }

    # 检查Node.js
    if (-NOT (Test-NodeInstallation)) {
        Write-Host "❌ Node.js未安装" -ForegroundColor Red
        Write-Host "   请从 https://nodejs.org 下载并安装Node.js 18+" -ForegroundColor Yellow
        pause
        exit 1
    }

    # 获取用户输入
    Get-UserInput

    # 初始化Git仓库
    if (-NOT (Initialize-GitRepository)) {
        pause
        exit 1
    }

    # 创建GitHub仓库
    $repoName = "pulse-running-app"
    $repoDescription = "Pulse跑步追踪和AI教练应用"

    $remoteUrl = Create-GitHubRepository -RepoName $repoName -Description $repoDescription -Username $GitHubUsername -Token $GitHubToken

    if ([string]::IsNullOrEmpty($remoteUrl)) {
        Write-Host "❌ 无法获取仓库URL" -ForegroundColor Red
        pause
        exit 1
    }

    # 设置GitHub Secrets
    Set-GitHubSecrets -RepoOwner $GitHubUsername -RepoName $repoName -Token $GitHubToken -SupabaseUrl $SupabaseUrl -SupabaseKey $SupabaseKey

    # 推送代码
    if (Push-ToGitHub -RemoteUrl $remoteUrl -Username $GitHubUsername -Token $GitHubToken) {
        # 触发构建
        Trigger-GitHubActions -RepoOwner $GitHubUsername -RepoName $repoName -Token $GitHubToken
    }

    # 显示后续步骤
    Show-NextSteps -RepoOwner $GitHubUsername -RepoName $repoName
}

# 运行主函数
try {
    Main
} catch {
    Write-Host "❌ 脚本执行失败: $_" -ForegroundColor Red
    Write-Host "   详细错误: $($_.Exception.StackTrace)" -ForegroundColor Red
    pause
    exit 1
}