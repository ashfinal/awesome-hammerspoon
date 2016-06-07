# Hammerspoon-config

[Hammerspoon][hammerspoon] 是 OS X 平台上一款功能强大的自动化操作工具，这是我的配置文件。

## 如何使用？

- 首先你需要安装 [Hammerspoon][hammerspoon]，安装完成后给予 Hammerspoon 辅助控制权限。

- 在终端里运行以下命令：

    `git clone https://github.com/ashfinal/Hammerspoon-config.git ~/.hammerspoon`

- 启动 Hammerspoon, 它会自动加载配置文件。

## 能做些什么？

你可以使用 Hammerspoon 做很多事情，这里我仅用它来实现几个小功能。

- 操作窗口

    `⌘ + ⌃ + Arrow`     -- 半屏

    `⌘ + ⌃ + ⇧ + Arrow`    -- 四分之一屏幕

    `⌥ + Arrow`     -- 调整窗口大小

    `⌥ + ⇧ + Arrow`    - -移动窗口

    `⌃ + ⌥ + c`    -- 保持窗口大小不变的情况下将其移到屏幕中央

    `⌘ + ⌃ + ⌥ + c`    -- 将窗口调整为预定义的大小并移到屏幕中央

    `⌘ + ⌃ + ⌥ + m`    -- 全屏

    `⌘ + ⌃ + ⇧ +=/-`    -- 放大或缩小窗口

- 切换窗口

    使用快捷键 `⌥ + ␣` 显示窗口标识。

    ![windows hint](https://raw.githubusercontent.com/ashfinal/Hammerspoon-config/master/screenshot/20160328-115751.png "windows hint")

- 阻止屏幕进入睡眠

    点击菜单栏图标进行切换或者使用快捷键 `⌘ + ⌃ + ⌥ + l`。

    **Update** 该功能已被默认关闭，你可以在 `init.lua` 中将代码反注释即可启用。

- 锁定屏幕

    使用快捷键 `⌘ + ⌃ + l`。

- 切换显示桌面文件

    使用快捷键 `⌘ + ⌃ + h`。

    **Important** 如果遭遇掉电或系统崩溃，可使用 `⌘ + ⌃ + ⌥  + h` 总是显示桌面文件。

## 欢迎反馈

随意使用并传播。欢迎提出任何帮助或建议。


[hammerspoon]:http://www.hammerspoon.org "http://www.hammerspoon.org"
