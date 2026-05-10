#!/bin/bash
# 根据 logo.png 或 LOGO_URL 生成所有尺寸的 Android 图标
# 用法: ./generate_icons.sh [logo路径]  默认读取项目根目录的 logo.png

set -e

LOGO="${1:-logo.png}"
RES_DIR="app/src/main/res"

# ── 如果本地没有 logo.png，尝试从 LOGO_URL 下载 ───────────────────────────
if [ ! -f "$LOGO" ]; then
    LOGO_URL=$(grep '^LOGO_URL=' config.properties 2>/dev/null | cut -d'=' -f2-)
    LOGO_URL=$(echo "$LOGO_URL" | tr -d '[:space:]')

    if [ -n "$LOGO_URL" ]; then
        echo "==> 从 URL 下载图标：$LOGO_URL"
        LOGO="/tmp/web2app_logo_download"
        curl -fsSL "$LOGO_URL" -o "$LOGO" || {
            echo "警告：图标下载失败，跳过图标生成"
            exit 0
        }
        echo "   下载完成 ✓"
    else
        echo "跳过图标生成：未找到 logo.png，且 LOGO_URL 未配置"
        exit 0
    fi
fi

# ── 检测 ImageMagick 命令（兼容 v6 的 convert 和 v7 的 magick）──────────────
if command -v magick &>/dev/null; then
    IM="magick"
elif command -v convert &>/dev/null; then
    IM="convert"
else
    echo "警告：未安装 ImageMagick，跳过图标生成"
    echo "  macOS 安装: brew install imagemagick"
    echo "  Ubuntu 安装: sudo apt-get install imagemagick"
    exit 0
fi

# ── 读取背景色 ────────────────────────────────────────────────────────────────
BG_COLOR=$(grep '^ICON_BG_COLOR=' config.properties 2>/dev/null | cut -d'=' -f2-)
BG_COLOR=$(echo "${BG_COLOR:-#1a1a2e}" | tr -d '[:space:]')

echo "==> 生成 Android 图标（背景色: ${BG_COLOR}）..."

# ── 生成各密度传统图标（带背景色）────────────────────────────────────────────
declare -A SIZES=([mdpi]=48 [hdpi]=72 [xhdpi]=96 [xxhdpi]=144 [xxxhdpi]=192)

for DENSITY in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    SIZE=${SIZES[$DENSITY]}
    LOGO_SIZE=$((SIZE * 3 / 4))   # logo 占图标 75%，四周留白
    DIR="${RES_DIR}/mipmap-${DENSITY}"
    mkdir -p "$DIR"

    # 方形图标
    $IM -size ${SIZE}x${SIZE} xc:"${BG_COLOR}" \
        \( "$LOGO" -resize ${LOGO_SIZE}x${LOGO_SIZE} \) \
        -gravity center -composite \
        "${DIR}/ic_launcher.png"

    # 圆形图标（裁成圆）
    $IM -size ${SIZE}x${SIZE} xc:none \
        -fill "${BG_COLOR}" -draw "circle $((SIZE/2)),$((SIZE/2)) $((SIZE/2)),0" \
        \( "$LOGO" -resize ${LOGO_SIZE}x${LOGO_SIZE} \) \
        -gravity center -composite \
        "${DIR}/ic_launcher_round.png"

    echo "   ${DENSITY}: ${SIZE}x${SIZE} ✓"
done

# ── 生成 Adaptive Icon 前景图（432x432，logo 在 72dp 安全区内）──────────────
# 432px = xxxhdpi 下 108dp；安全区 72dp = 288px；两侧各留 72px
DRAWABLE_DIR="${RES_DIR}/drawable"
mkdir -p "$DRAWABLE_DIR"

$IM -size 432x432 xc:none \
    \( "$LOGO" -resize 216x216 \) \
    -gravity center -composite \
    "${DRAWABLE_DIR}/ic_launcher_foreground.png"

# 如果存在同名 XML 向量图，移除以避免资源冲突
rm -f "${DRAWABLE_DIR}/ic_launcher_foreground.xml"
echo "   adaptive foreground: 432x432 ✓"

echo "==> 图标生成完成！"
