# Media Saber ESP32 桌面小助手固件

构建版本：**__VERSION__**
构建时间：__BUILD_TIME__
源码仓库：[xylplm/ms-esp32-s3-box](https://github.com/xylplm/ms-esp32-s3-box)

---

## 📦 本版本包含两个固件包

| 文件 | 适用场景 | 说明 |
|---|---|---|
| `media-saber-esp32s3-ms-helper-merged.zip` | 新手推荐 | 解压后只有一个合并固件，烧录到地址 `0x0` 即可 |
| `media-saber-esp32s3-ms-helper-split.zip` | 进阶用户 | 解压后是 5 个分区固件 + `flash_args`，可按地址分别烧录 |

两个包内容等价，任选其一。

## 🚀 快速烧录

### 方式一：合并固件（最简单）

下载 `media-saber-esp32s3-ms-helper-merged.zip` 并解压，使用 [esptool](https://github.com/espressif/esptool)：

```bash
pip install esptool
esptool.py --chip esp32s3 --port COMx --baud 921600 write_flash -z 0x0 media-saber-esp32s3-ms-helper.bin
```

### 方式二：分散固件（一键烧录全部分区）

下载 `media-saber-esp32s3-ms-helper-split.zip` 并解压，在解压目录里执行：

```bash
pip install esptool
esptool.py --chip esp32s3 --port COMx --baud 921600 write_flash -z @flash_args
```

## 📋 分区固件地址表（分散固件用）

| 地址 | 文件 | 说明 |
|---:|---|---|
| `0x0` | `bootloader.bin` | 引导程序 |
| `0x8000` | `partition-table.bin` | 分区表 |
| `0xd000` | `ota_data_initial.bin` | OTA 初始数据 |
| `0x20000` | `xiaozhi.bin` | 应用固件 |
| `0x800000` | `generated_assets.bin` | 资源分区（字体 / 形象 / 音效），缺失会丢 UI 资源 |

## ⚙️ 烧录参数

SPI Flash: **16MB** / Mode: **DIO** / Speed: **80MHz**

## 📖 完整使用教程

详见 Media Saber Wiki：[ESP32 桌面小助手 / 固件烧录教程](https://wiki.msaber.fun/client/esp32/)

> 上面的 `COMx` 为示例，Windows 通常是 `COMx`，macOS / Linux 通常是 `/dev/ttyUSBx` 或 `/dev/ttyACMx`。
