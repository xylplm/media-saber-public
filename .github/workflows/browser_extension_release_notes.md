# Media Saber 浏览器扩展（Media Saber Tools）

构建版本：**__VERSION__**
构建时间：__BUILD_TIME__

Media Saber Tools 是一款支持站点同步、云存储管理、下载管理、数据统计等功能的综合浏览器扩展，可在主流浏览器中辅助使用 Media Saber。

> 本页面为最新版构建，旧版本会被自动清理，始终只保留一个最新版本。

---

## 📦 本版本包含 9 个浏览器安装包

Chrome 与 Edge 各提供三种格式；Firefox 与 Safari 各提供一种格式。Chrome 安装包同时适用于大多数 Chromium 内核浏览器。普通用户优先使用扩展商店版本，只有无法访问商店或有特殊需求时才使用本页手动安装包。

| 文件 | 适用浏览器 | Manifest 版本 | 说明 |
|---|---|:---:|---|
| `media-saber-tools-chrome.zip` | Chrome / Brave / Vivaldi / Opera / Arc / Yandex / Chromium 等 | MV3 | 解压后通过开发者模式加载 |
| `media-saber-tools-chrome.crx` | Chrome 及其他 Chromium 浏览器 | MV3 | CRX 打包文件，部分浏览器可直接拖入扩展管理页 |
| `media-saber-tools-chrome.crx.zip` | Chrome 及其他 Chromium 浏览器 | MV3 | 内含 CRX 文件，适合浏览器拦截 CRX 直链下载时使用 |
| `media-saber-tools-edge.zip` | Microsoft Edge | MV3 | 解压后通过开发者模式加载 |
| `media-saber-tools-edge.crx` | Microsoft Edge / Chromium 内核浏览器 | MV3 | CRX 打包文件，具体安装方式取决于浏览器策略 |
| `media-saber-tools-edge.crx.zip` | Microsoft Edge / Chromium 内核浏览器 | MV3 | 内含 CRX 文件，适合浏览器拦截 CRX 直链下载时使用 |
| `media-saber-tools-firefox.zip` | Firefox（MV2） | MV2 | 临时加载或开发版 / ESR 手动安装 |
| `media-saber-tools-firefox-mv3.zip` | Firefox（MV3） | MV3 | 临时加载或开发版 / ESR 手动安装 |
| `media-saber-tools-safari.zip` | Safari | MV2 | macOS 下需经 Xcode 打包后安装 |

任选与你浏览器对应的一个包下载即可。Brave、Vivaldi、Opera / Opera GX、Arc、Yandex、Chromium 等 Chromium 内核浏览器通常直接使用 Chrome 安装包；360、QQ 等浏览器因版本和扩展策略差异较大，建议优先实际测试 `.zip` 包。

> 当前没有为每个 Chromium 浏览器重复制作独立包，因为它们通常使用相同的 Chrome MV3 扩展格式。Opera 如需提交 Opera 扩展商店，也可以使用 Chrome `.zip` 包进行单独提交测试。

## 🏪 首选：从扩展商店安装

Chrome 和 Edge 版本已经发布到官方扩展商店，并由商店负责更新与安全校验。除非无法访问商店、需要测试临时版本或有其他特殊需求，否则建议直接安装扩展商店版本：

- [Chrome 网上应用店](https://chromewebstore.google.com/detail/media-saber-tools/ibflljhbofedginadhkfehbpbefijfid)
- [Microsoft Edge 加载项](https://microsoftedge.microsoft.com/addons/detail/hlpcdobmkgdflggmhpmgoejbfjndpadb)

## 🚀 手动安装方式

### Chromium 内核浏览器

Chrome、Edge、Brave、Vivaldi、Opera、Opera GX、Arc、Yandex、Chromium 等浏览器通常可以使用 Chrome 安装包。360、QQ 等浏览器请先确认其扩展管理页支持 Manifest V3 和对应权限，再进行手动安装。

#### 方式一：`.zip` 解压加载（推荐手动安装方式）

1. 下载对应的 `.zip` 文件并解压到一个**固定目录**（升级时不要删除该目录，直接覆盖即可）。如果下载的是 `.crx.zip`，先解压一次得到 `.crx` 文件。
2. 打开浏览器扩展管理页：
   - Chrome：`chrome://extensions/`
   - Edge：`edge://extensions/`
   - 其他 Chromium 浏览器：在浏览器设置中打开「扩展」页面，或查找类似「扩展管理」的入口。
3. 打开右上角的「开发者模式」。
4. 点击「加载已解压的扩展程序」，选择解压出来的文件夹（含 `manifest.json` 的目录）。
5. 扩展图标会出现在工具栏，点击即可使用。

#### 方式二：`.crx` 打包安装

1. 打开 `chrome://extensions/` 或 `edge://extensions/`，开启「开发者模式」。
2. 尝试将 `.crx` 文件拖入扩展管理页。
3. 如果浏览器拒绝安装，这是浏览器的安全策略限制，不是安装包损坏；请改用对应的 `.zip` 解压加载，或使用扩展商店版本。

> 提示：Chrome、Edge 及其他 Chromium 内核浏览器的 CRX 直装策略可能不同；部分浏览器只允许商店或企业策略安装 CRX。

### Firefox

1. 下载对应的 `.zip` 文件并解压。
2. 打开 Firefox，地址栏输入 `about:debugging#/runtime/this-firefox`。
3. 点击「临时载入附加组件…」，选择解压目录中的 `manifest.json`（或任一 `.js` 文件）。
4. 临时加载后即可在工具栏使用。

> 注意：Firefox 的「临时载入」会在浏览器关闭后失效。如需长期使用，请关注后续上架 Mozilla Add-ons 商店的正式版本，或使用 Firefox 开发者版 / ESR 版本进行持久化安装。

### Safari

Safari 扩展需要先通过 Xcode 打包为 `.app` 后才能安装：

1. 下载 `media-saber-tools-safari.zip` 并解压。
2. 在 macOS 上使用 Xcode 将其封装为 Safari App Extension。
3. 在「系统设置 → Safari → 扩展」中启用。

> Safari 安装流程相对繁琐，推荐非 macOS 用户优先使用 Chrome / Edge / Firefox 版本。

## 🔄 升级方式

本发布为固定 tag，会始终覆盖为最新版本。

- 通过 Chrome / Edge 扩展商店安装：由商店自动更新。
- 使用 `.zip` 手动安装：重新下载并解压覆盖原扩展目录，然后在扩展管理页点击「重新加载」。
- 使用 `.crx` 手动安装：先删除旧的手动安装版本，再按上面的 CRX 安装步骤重新加载；如果浏览器拒绝 CRX，请改用 `.zip`。
- Firefox 临时载入：浏览器重启后需重新执行一次载入操作。

## 📖 完整使用教程

详见 Media Saber Wiki：[浏览器扩展 / 安装与使用教程](https://wiki.msaber.fun/client/brower_tool/)

## ⚠️ 免责声明

- 本扩展仅供学习交流使用，不提供任何内容，仅作为辅助工具简化用户手工操作。
- 使用本扩展产生的任何责任需由使用者本人承担。
- 如遇浏览器策略变更导致无法加载，请参考 Wiki 中的常见问题排查。
