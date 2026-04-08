#!/bin/bash
# 增量更新Android权限配置
# 此脚本检查并添加缺失的权限到AndroidManifest.xml，避免覆盖现有配置

set -e  # 遇到错误时退出

ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"

# 检查文件是否存在
if [ ! -f "$ANDROID_MANIFEST" ]; then
    echo "❌ 错误：AndroidManifest.xml 未找到在路径: $ANDROID_MANIFEST"
    exit 1
fi

echo "📱 检查Android权限配置..."

# 备份原始文件
BACKUP_FILE="${ANDROID_MANIFEST}.backup_$(date +%Y%m%d_%H%M%S)"
cp "$ANDROID_MANIFEST" "$BACKUP_FILE"
echo "✅ 原始文件已备份到: $BACKUP_FILE"

# 定义必要权限
REQUIRED_PERMISSIONS=(
    "android.permission.INTERNET"
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.ACCESS_COARSE_LOCATION"
    "android.permission.ACCESS_NETWORK_STATE"
    "android.permission.CAMERA"
    "android.permission.RECORD_AUDIO"
)

# 检查并添加缺失的权限
ADDED_COUNT=0
for perm in "${REQUIRED_PERMISSIONS[@]}"; do
    if ! grep -q "$perm" "$ANDROID_MANIFEST"; then
        echo "➕ 添加权限: $perm"
        # 在 </manifest> 标签前插入权限声明
        sed -i "/<\/manifest>/i\    <uses-permission android:name=\"$perm\" />" "$ANDROID_MANIFEST"
        ADDED_COUNT=$((ADDED_COUNT + 1))
    else
        echo "✅ 权限已存在: $perm"
    fi
done

echo "📊 权限检查完成: 添加了 $ADDED_COUNT 个新权限"

# 验证XML格式
if command -v xmllint &> /dev/null; then
    echo "🔍 验证XML格式..."
    if xmllint --noout "$ANDROID_MANIFEST" 2>/dev/null; then
        echo "✅ XML格式验证通过"
    else
        echo "❌ XML格式验证失败，恢复备份..."
        cp "$BACKUP_FILE" "$ANDROID_MANIFEST"
        echo "🔄 已从备份恢复原始文件"
        exit 1
    fi
else
    echo "⚠  xmllint未安装，跳过XML格式验证"
    echo "💡 建议安装libxml2-utils以获得更好的验证"
fi

# 显示最终权限列表
echo ""
echo "📋 当前AndroidManifest.xml中的权限列表:"
grep "uses-permission" "$ANDROID_MANIFEST" || echo "未找到权限声明"

echo ""
echo "🎉 Android权限更新完成!"
echo "💾 备份文件: $BACKUP_FILE"
echo "📁 主文件: $ANDROID_MANIFEST"