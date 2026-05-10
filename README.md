# Web2App

**将任意网站一键封装为 Android App | Wrap any website into an Android App**

Fork → 改一个文件 → 推送 → 自动得到 APK

Fork → Edit one file → Push → Get APK automatically

---

## 中文说明

### 快速开始

**第一步：Fork 本仓库**

点击右上角 **Fork**，复制到自己的 GitHub 账号下。

**第二步：修改 `config.properties`**

编辑根目录的 `config.properties`：

```properties
# 目标网址（必填）
TARGET_URL=https://your-website.com

# 应用名称（显示在桌面的名字）
APP_NAME=My App

# 包名（建议改成自己的，格式：com.yourname.yourapp）
APP_ID=com.yourname.yourapp

# 版本（每次发布递增 VERSION_CODE）
VERSION_CODE=1
VERSION_NAME=1.0

# 初始缩放比例（100 = 默认，90 = 缩小到90%）
INITIAL_SCALE=100

# 图标背景色（logo.png 有透明背景时生效）
ICON_BG_COLOR=#1a1a2e
```

**第三步（可选）：自定义图标**

二选一：

- **方式一（推荐）**：将 **512×512px** 的图片命名为 `logo.png`，放到项目根目录
- **方式二**：在 `config.properties` 里填写图片 URL

```properties
LOGO_URL=https://example.com/your-logo.png
```

支持 PNG / JPG，推荐使用透明背景的 PNG。本地 `logo.png` 优先级高于 `LOGO_URL`。构建时自动生成所有尺寸，不配置则使用默认图标。

**第四步：推送，等待构建完成**

推送到 `main` 分支后，GitHub Actions 自动构建（约 3~5 分钟）。

进入仓库 → **Actions** → 最新的 workflow → 页面底部 **Artifacts** → 下载 APK。

---

### 配置签名（可选，发布到应用商店必须）

不配置签名会自动构建 **Debug APK**（可直接安装，但不能上架应用商店）。

如需签名的 **Release APK**，需要先生成签名文件，再将相关信息填入 GitHub Secrets。

#### 第一步：生成签名文件（.jks）

签名文件相当于你的"开发者身份证"，用于证明 APK 由你发布。**只需生成一次，请务必妥善保存。**

```bash
keytool -genkeypair \
  -alias mykey \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore my-release.jks \
  -dname "CN=My App, O=My Company, C=CN" \
  -storepass yourpassword \
  -keypass yourpassword
```

参数说明：
- `-alias mykey` — key 的名字，可以随意起，记住即可（对应 `KEY_ALIAS`）
- `-keystore my-release.jks` — 生成的签名文件名
- `-storepass yourpassword` — 打开签名文件的密码（对应 `KEY_STORE_PASSWORD`）
- `-keypass yourpassword` — key 自身的密码，通常与 storepass 相同（对应 `KEY_PASSWORD`）
- `-validity 10000` — 有效期天数，10000 天约 27 年

#### 第二步：将 .jks 文件转为文字（base64）

GitHub Secrets 只能存储文字，需要把二进制的 .jks 文件编码成字符串：

```bash
base64 -i my-release.jks | pbcopy     # macOS（结果自动复制到剪贴板）
base64 -w 0 my-release.jks            # Linux（手动复制输出内容）
```

#### 第三步：填入 GitHub Secrets

进入仓库 **Settings → Secrets and variables → Actions → New repository secret**，依次添加：

| Secret 名称 | 填入的内容 | 说明 |
|---|---|---|
| `KEYSTORE_BASE64` | 上一步 base64 命令的输出 | .jks 文件的编码内容，一长串字母数字 |
| `KEY_STORE_PASSWORD` | 生成时 `-storepass` 的值 | 打开签名文件的密码 |
| `KEY_ALIAS` | 生成时 `-alias` 的值 | key 的名字，如 `mykey` |
| `KEY_PASSWORD` | 生成时 `-keypass` 的值 | key 自身的密码，通常与 `KEY_STORE_PASSWORD` 相同 |

> ⚠️ `.jks` 文件和密码请单独备份到安全的地方（如密码管理器）。应用上架后，所有更新版本必须用同一个签名文件，一旦丢失将永远无法发布新版本。

---

### 功能特性

- WebView 全屏加载目标网址
- 返回键在网页历史内导航
- 支持文件上传（`<input type="file">`）
- 支持文件下载（系统 DownloadManager）
- 启动页（Splash Screen）
- 自定义图标（放入 `logo.png` 自动生成所有尺寸）
- 最低支持 Android 5.0（API 21）

---

## English

### Quick Start

**Step 1: Fork this repository**

Click **Fork** in the top-right corner to copy it to your GitHub account.

**Step 2: Edit `config.properties`**

Edit `config.properties` in the root directory:

```properties
# Target URL (required)
TARGET_URL=https://your-website.com

# App display name
APP_NAME=My App

# Package name (should be unique, format: com.yourname.yourapp)
APP_ID=com.yourname.yourapp

# Version (increment VERSION_CODE on every release)
VERSION_CODE=1
VERSION_NAME=1.0

# Initial zoom level (100 = default, 90 = 90% zoom)
INITIAL_SCALE=100

# Icon background color (used when logo.png has a transparent background)
ICON_BG_COLOR=#1a1a2e
```

**Step 3 (optional): Custom icon**

Choose one:

- **Option A (recommended)**: Place a **512×512px** image named `logo.png` in the project root
- **Option B**: Set an image URL in `config.properties`

```properties
LOGO_URL=https://example.com/your-logo.png
```

PNG/JPG supported. Transparent PNG recommended. Local `logo.png` takes priority over `LOGO_URL`. All icon sizes are generated automatically. If neither is provided, the default icon is used.

**Step 4: Push and wait for the build**

After pushing to the `main` branch, GitHub Actions will build automatically (~3–5 min).

Go to your repo → **Actions** → latest workflow run → **Artifacts** at the bottom → download APK.

---

### Code Signing (optional, required for app store publishing)

Without signing secrets, a **Debug APK** is built automatically (installable directly, but not publishable to stores).

For a signed **Release APK**, generate a keystore first, then add the details as GitHub Secrets.

#### Step 1: Generate a keystore (.jks)

A keystore is your "developer identity" — it proves the APK was published by you. **Generate it once and keep it safe forever.**

```bash
keytool -genkeypair \
  -alias mykey \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore my-release.jks \
  -dname "CN=My App, O=My Company, C=US" \
  -storepass yourpassword \
  -keypass yourpassword
```

Parameter guide:
- `-alias mykey` — a name for your key, anything you like (this becomes `KEY_ALIAS`)
- `-keystore my-release.jks` — output filename for the keystore
- `-storepass yourpassword` — password to open the keystore file (this becomes `KEY_STORE_PASSWORD`)
- `-keypass yourpassword` — password for the key itself, usually the same as storepass (this becomes `KEY_PASSWORD`)
- `-validity 10000` — validity in days (~27 years)

#### Step 2: Encode the .jks file as base64

GitHub Secrets only store text, so encode the binary .jks file as a string:

```bash
base64 -i my-release.jks | pbcopy     # macOS (result copied to clipboard automatically)
base64 -w 0 my-release.jks            # Linux (copy the output manually)
```

#### Step 3: Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret** and add:

| Secret | Value to enter | Description |
|---|---|---|
| `KEYSTORE_BASE64` | Output from the base64 command above | The encoded .jks file — a long string of letters and numbers |
| `KEY_STORE_PASSWORD` | Your `-storepass` value | Password to open the keystore |
| `KEY_ALIAS` | Your `-alias` value | Name of the key, e.g. `mykey` |
| `KEY_PASSWORD` | Your `-keypass` value | Password for the key itself, usually the same as `KEY_STORE_PASSWORD` |

> ⚠️ Back up your `.jks` file and passwords in a safe place (e.g. a password manager). Every future update must be signed with the same keystore — if you lose it, you will never be able to publish updates to the same app.

---

### Features

- Full-screen WebView loading the target URL
- Back button navigates browser history
- File upload support (`<input type="file">`)
- File download support (via system DownloadManager)
- Splash screen on launch
- Custom icon (place `logo.png` in root, all sizes auto-generated)
- Minimum Android 5.0 (API 21)
