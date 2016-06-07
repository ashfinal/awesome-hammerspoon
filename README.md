# Hammerspoon-config
[Hammerspoon][hammerspoon] is a tool for powerful automation of OS X. And here is my config file for realizing some functionality I want.

[中文版](https://github.com/ashfinal/Hammerspoon-config/blob/master/README-CN.md)

## How to use?

- You need to install [Hammerspoon][hammerspoon] first. Remember to manually allow Hammerspoon access to the accessibility features.

- Run the following command in your Terminal.

    `git clone https://github.com/ashfinal/Hammerspoon-config.git ~/.hammerspoon`

- Launch the app Hammerspoon and you're ready to go!

## What can I do with it?

You can do lots of things with [Hammerspoon][hammerspoon]. As for this config, it currently allow you to:

- Manipulate windows

    `⌘ + ⌃ + Arrow`     -- halfscreen

    `⌘ + ⌃ + ⇧ + Arrow`    -- quarterscreen

    `⌥ + Arrow`     -- resizing windows from the bottom & right

    `⌥ + ⇧ + Arrow`    - -moving windows around

    `⌃ + ⌥ + c`    -- move the window to the center of screen without resizing

    `⌘ + ⌃ + ⌥ + c`    -- move the window to the center of screen with predefined size

    `⌘ + ⌃ + ⌥ + m`    -- fullscreen

    `⌘ + ⌃ + ⇧ +=/-`    -- expand & shrink windows

- Switch windows

    Use the shortcut `⌥ + ␣` to show the windows hint.

    ![windows hint](https://raw.githubusercontent.com/ashfinal/Hammerspoon-config/master/screenshot/20160328-115751.png "windows hint")

- Keep the screen alway on(caffeine)

    Click the menu icon to toggle or use the shortcut `⌘ + ⌃ + ⌥ + l`.

    **Update** Has been commented.

- Lock the screen

    Use the shortcut `⌘ + ⌃ + l`.

- Toggle hidden of files on Desktop

    Use the shortcut `⌘ + ⌃ + h`.

    **Important** Use `⌘ + ⌃ + ⌥ + h` to unhidden the files if you relaunch hammerspoon or reboot your computer.

## Any suggestions?

Use and spread. Send me some feedback.


[hammerspoon]:http://www.hammerspoon.org "http://www.hammerspoon.org"
