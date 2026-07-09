# Media Saber 浏览器扩展（Media Saber Tools）

构建版本：**__VERSION__**
构建时间：__BUILD_TIME__
源码仓库：[xylplm/media-saber-extension](https://github.com/xylplm/media-saber-extension)

Media Saber Tools 是一款支持站点同步、云存储管理、下载管理、数据统计等功能的综合浏览器扩展，可在主流浏览器中辅助使用 Media Saber。

> 本页面为最新版构建，旧版本会被自动清理，始终只保留一个最新版本。

---

## 📦 本版本包含 5 个浏览器安装包

| 文件 | 适用浏览器 | Manifest 版本 | 说明 |
|---|---|:---:|---|
| `media-saber-tools-chrome.zip` | Chrome（及所有 Chromium 内核浏览器） | MV3 | 解压后加载已解压的扩展即可 |
| `media-saber-tools-edge.zip` | Microsoft Edge | MV3 | 同 Chrome，Edge 商店上架前的手动安装包 |
| `media-saber-tools-firefox.zip` | Firefox（旧版 / 仍支持 MV2 的版本） | MV2 | 适用于尚未完全迁移到 MV3 的 Firefox |
| `media-saber-tools-firefox-mv3.zip` | Firefox（新版，支持 MV3） | MV3 | 适用于较新版本的 Firefox |
| `media-saber-tools-safari.zip` | Safari | MV2 | macOS 下需经 Xcode 打包后安装 |

任选与你浏览器对应的一个包下载即可。

## 🚀 安装方式

### Chrome / Edge（及 Chromium 内核浏览器）

1. 下载对应的 `.zip` 文件并解压到一个**固定目录**（升级时不要删除该目录，直接覆盖即可）。
2. 打开浏览器扩展管理页：
   - Chrome：`chrome://extensions/`
   - Edge：`edge://extensions/`
3. 打开右上角的「开发者模式」。
4. 点击「加载已解压的扩展程序」，选择解压出来的文件夹（含 `manifest.json` 的目录）。
5. 扩展图标会出现在工具栏，点击即可使用。

> 提示：部分 Chromium 内核浏览器（如 100% 浏览器等）安装方式与 Chrome 一致。

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

本发布为固定 tag，会始终覆盖为最新版本。升级步骤：

1. 重新下载对应浏览器的 `.zip` 文件。
2. 解压后覆盖原扩展目录（Chrome / Edge 可直接覆盖，然后在扩展管理页点击「重新加载」）。
3. Firefox 临时载入需重新执行一次载入操作。

## 📖 完整使用教程

详见 Media Saber Wiki：[浏览器扩展 / 安装与使用教程](https://wiki.msaber.fun/client/brower_tool.html)

## ⚠️ 免责声明

- 本扩展仅供学习交流使用，不提供任何内容，仅作为辅助工具简化用户手工操作。
- 使用本扩展产生的任何责任需由使用者本人承担。
- 如遇浏览器策略变更导致无法加载，请参考 Wiki 中的常见问题排查。
