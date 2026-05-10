#!/bin/bash
set -e

# 优先使用 JDK 17（sdkmanager 要求）
if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# ─── 配置 ────────────────────────────────────────────────────────────────────
ANDROID_HOME="$HOME/android-sdk"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-mac-14742923_latest.zip"
BUILD_TOOLS_VERSION="34.0.0"
PLATFORM_VERSION="android-35"
# ─────────────────────────────────────────────────────────────────────────────

echo "==> 检查 Java..."
java -version 2>&1 | head -1
echo ""

# 1. 下载 SDK 命令行工具（如果还没有）
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "==> 下载 Android SDK 命令行工具..."
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    TMP_ZIP="/tmp/cmdline-tools.zip"
    curl -L "$CMDLINE_TOOLS_URL" -o "$TMP_ZIP"
    unzip -q "$TMP_ZIP" -d "$ANDROID_HOME/cmdline-tools"
    # Google 解压后目录名是 "cmdline-tools"，需重命名为 "latest"
    mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" 2>/dev/null || true
    rm "$TMP_ZIP"
    echo "==> 命令行工具安装完毕"
fi

SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

# 2. 接受许可证 & 安装构建工具
echo "==> 接受 Android 许可证（自动同意）..."
yes | "$SDKMANAGER" --sdk_root="$ANDROID_HOME" --licenses > /dev/null 2>&1 || true

echo "==> 安装 build-tools 和 platform（首次运行需要几分钟）..."
"$SDKMANAGER" --sdk_root="$ANDROID_HOME" \
    "build-tools;$BUILD_TOOLS_VERSION" \
    "platforms;$PLATFORM_VERSION" \
    "platform-tools"

echo ""
echo "==> SDK 安装完成，开始编译..."

# 3. 设置环境变量并编译
export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

cd "$(dirname "$0")"

# 4. 生成图标（如果存在 logo.png）
bash generate_icons.sh

chmod +x gradlew
./gradlew assembleDebug --no-daemon

echo ""
echo "================================================================"
echo "  编译成功！APK 路径："
find . -name "*.apk" -path "*/debug/*" | head -5
echo "================================================================"
