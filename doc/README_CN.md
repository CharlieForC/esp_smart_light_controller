# ESP32-C3 开关熊猫

ESP32-C3 开关熊猫设计聚焦为懒人服务，让懒人不再需要翻身下床找开关，只需下拉通知栏轻轻一按，就能享受到优雅而便捷的灯光控制体验，开关这小事，交给熊猫用脚做吧，懒人应该躺的更平更舒服。该项目基本攻克了冬日睡前需要关灯的重大难题。
![image-11](pic/main_raw2.gif)


![image-20230923130225741](pic/image-20230923130225741.png)

## 项目优点

1. **直连Homekit**，实现局域网控制，支持Siri控制和通知栏直接控制,响应迅速，可以接入ESP Rainmaker云平台，实现远程控制。
2. **易于配置**：仅需两次扫码即可完成配置，就可以愉快的使用啦。
3. **低功耗配置**，兼顾响应快速和续航，搭配2000mAh电池，单纯使用ESP Rainmaker控制待机续航约90天，HomeKit+ESP Rainmaker待机续航约为45天。
4. **超易复刻**：代码和硬件和结构完全开源
   - 固件支持一键烧录，无需烧录工具，无需下载任何开发环境。
   - 所有的物料都选择了易于焊接的封装，且尽量选用了立创基础库可贴的元器件。
   - 提供主要元器件购买链接
5. 支持电池低电量报警和自动关机，功能稳定。
6. 外形设计优雅，整机物料成本约30元。

## 零代码复刻

先决条件：有一个 ESP32-C3开关熊猫。使用其他ESP32-C3开发板也可，但需要自己接舵机，不然只能用LOG来观察控制效果了*。

1. 烧录

   1. 点击下方图片跳转烧录页面：

   <a href="https://espressif.github.io/esp-launchpad/?flashConfigURL=https://charlieforc.github.io/esp_smart_light_controller/config.toml">
       <img alt="Try it with ESP Launchpad" src="https://espressif.github.io/esp-launchpad/assets/try_with_launchpad.png" width="250" height="70">
   </a>

   注：上面的一键烧录需要在你的 Fork 中提供 `config.toml`（填入你自己的固件地址），并开启 GitHub Pages。

   ​	2.将开关熊猫连接到电脑。

   ​	3.同时按住开关熊猫上的复位键和BOOT键（IO9），然后先松开BOOT键，再松开复位键，强制芯片进入烧录模式。

   ​	4.点击connect并选择开关熊猫对应的串口进行连接，串口名通常类似于`USB JTAG/serial debug unit (COMXX) - 已配对`

   ​	5.点击Flash开始烧录。

2. 配网：

   1. 烧录完成后，点击开关熊猫上的复位键。
   2. 网页上点击connect并选择连接该设备对应的串口。
   3. 网页上点击Console，进入控制台页面，点击Reset Device。
   4. 稍等片刻控制台上会显示两个二维码，一个大一个小，忽略小的二维码，首先使用Rainmaker APP扫描大的二维码对设备进行配网。完成后在APP上即可控制设备。同时控制台会新生成一个小的二维码。
   5. 使用苹果自带的家庭APP扫描小的二维码对设备进行绑定。

3. 完成！

   [^注]: ESP3232-C3模组的flash必须大于等于4M

## 编译和修改代码

如果想在本代码基础上进行二次修改，请按如下流程进行编译：

先决条件：需要安装ESP-IDF,并拉取ESP-Rainmaker和ESP-HomeKit-SDK的代码，提供了链接，如果遇到问题欢迎在项目中提Issue。

1. 确保上述环境已经安装并正确导入路径：

2. 在esp-rainmaker/example目录下克隆本仓库代码：

   ```
   cd esp-rainmaker/examples/
   git clone https://github.com/CharlieForC/esp_smart_light_controller.git
   ```

3. 编译

   ```
   cd esp_smart_light_controller
   idf.py build
   ```

​	

   编译产物为 `build/esp_smart_light_controller.bin`（目标 `esp32c3`，4 MB Flash，双 OTA 分区）。

## 本地编译（Espressif IDE v5.5.5 环境）

本仓库也可以作为独立工程编译，需要三个路径，已在 `.vscode/settings.json` 中配置好：

- `IDF_PATH` — ESP-IDF v5.5.5（例如 `D:\ESP32\v5.5.5\esp-idf`）
- `HOMEKIT_PATH` — esp-homekit-sdk 仓库（例如 `D:\ESP32\esp-homekit-sdk`）
- `RMAKER_PATH` — esp-rainmaker 仓库（例如 `D:\ESP32\rainmaker`，v1.16.0）

Windows 下直接运行辅助脚本即可（会自动激活 Espressif IDE 环境并设置组件路径）：

```powershell
.\build.ps1            # 仅编译
.\build.ps1 -flash      # 编译并烧录到 COM3
.\build.ps1 -monitor    # 打开 COM3 串口监视器
.\build.ps1 -clean      # 全量清理后重新编译
```

或者手动执行：

```powershell
. 'C:\Espressif\tools\Microsoft.v5.5.5.PowerShell_profile.ps1'
$env:HOMEKIT_PATH = 'D:\ESP32\esp-homekit-sdk'
$env:RMAKER_PATH  = 'D:\ESP32\rainmaker'
idf.py build
```

## 本分支改动

本 Fork 保留上游原有功能，并在此基础上做了以下修改。

### 引脚定义

| 引脚 | 功能 |
| --- | --- |
| IO2 | 开关灯输出（`OUTPUT_GPIO`） |
| IO3 | 电池电压 ADC（`ADC1_CHANNEL_3`） |
| IO4 | 舵机控制 PWM（LEDC channel 0） |
| IO5 | 板级电源保持（`BOARD_POWER_IO`） |
| IO6 | 舵机电机电源开关（`SERVO_POWER_GPIO`），高电平有效 |
| IO7 | 板载状态指示灯（`BOARD_LED_IO`） |
| IO9 | 按键（`CONFIG_EXAMPLE_BOARD_BUTTON_GPIO`） |

### 舵机驱动

- PWM 频率为 **50 Hz**，脉宽 0.5 ms ~ 2.5 ms（LEDC 13 bit，占空比 205 ~ 1024），符合标准舵机时序（`main/pwm_servo.c`）。
- 每次开/关动作都会先给电机上电（IO6 拉高），转到对应的上限位/下限位后等待 **500 ms**，再把转子转回 90° 中位，再等 500 ms，最后切断电机电源（`main/app_driver.c`）。
- 舵机限位保存在 NVS 中，可以在 RainMaker APP 里通过 `Limit Up` / `Limit Down` 两个滑块调节。

### 电池电压

- IO3 上的电池电压会以 `Battery Voltage` 参数上报到 RainMaker（数值 = 电压 × 100，滑块范围 300 ~ 420）。
- 开机约 30 s 后首次上报，之后每 5 分钟上报一次。低电量（< 3.6 V）时点亮状态指示灯报警，低于 3.4 V 时切断板级电源。

### HomeKit

- 设备每次拿到 IP 地址时，都会在串口控制台打印配对二维码和 setup payload URL，因此即使配件已经和某个控制器配对过，也依然能拿到配对信息。

### RainMaker claim

- 固件按中国区 MQTT 端点（`sdkconfig` 中的 `CONFIG_ESP_RMAKER_MQTT_HOST`）配置了 assisted claiming。使用你自己的 RainMaker 账号部署时，请改成你自己账号的端点。

## 附加链接：

硬件开源链接：

ESP_IDF：[espressif/esp-idf: Espressif IoT Development Framework. Official development framework for Espressif SoCs. (github.com)](https://github.com/espressif/esp-idf)

ESP_Rainmaker：[espressif/esp-rainmaker: ESP RainMaker Agent for firmware development (github.com)](https://github.com/espressif/esp-rainmaker)

ESP_HomeKit-SDK:[espressif/esp-homekit-sdk (github.com)](https://github.com/espressif/esp-homekit-sdk)

## F&Q

- 烧录失败：

  - 烧录时需要连接电池。
  - 检查电脑上是否识别到了设备插入，如果没有，请检查硬件是否焊接正常，同时确保所选用的数据线是可用于数据传输的数据线。

