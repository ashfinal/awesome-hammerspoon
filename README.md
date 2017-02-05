# Awesome-hammerspoon, as advertised.

![modes](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-modes.png)

Awesome-hammerspoon is my collection of lua scripts for [Hammerspoon](http://www.hammerspoon.org/). It has highly modal-based, vim-styled key bindings, provides some functionality like desktop widgets, window management, application launcher, dictionary translation, cheatsheets... etc.

## Get started

1. Install [Hammerspoon](http://www.hammerspoon.org/) first.
2. `git clone --depth 1 https://github.com/ashfinal/awesome-hammerspoon.git ~/.hammerspoon`
3. Reload the configutation.

and you're set.

## Keep update

`cd ~/.hammerspoon && git pull`

## What's modal-based key bindings?

<details>
<summary>More details</summary>

Well... simply to say, it allows you using <kbd>S</kbd> key to resize windows in `resize` mode, but in `app` mode, to launch Safari, in `timer` mode, to set a 10-mins timer... something like that. During all progress, you don't have to press extra keys.
</p>

And this means a lot.

* It's scene-wise, you can use same key bindings to do different jobs in different scenes. You don't worry to run out of your hotkey bindings, and twist your fingers to press <kbd>⌘</kbd> + <kbd>⌃</kbd> + <kbd>⌥</kbd> + <kbd>⇧</kbd> + <kbd>C</kbd> in the end.

* Less keystrokes, less memory pressure. You can press <kbd>⌥</kbd> + <kbd>A</kbd> to enter `app` mode, release, then press single key <kbd>S</kbd> to launch Safari, or <kbd>C</kbd> to lauch Chrome. Sounds good? You keep your pace, no rush.

* Easy to extend, you can create your own modals if you like. For example, `Finder` mode, in which you press <kbd>T</kbd> to open Terminal here, press <kbd>S</kbd> to send files to predefined path, press <kbd>C</kbd> to upload images to cloud storage.

**NOTICE:** After your work you'd better quit current mode back to normal. Or, you carefully pick your key bindings to avoid conflict with other hotkeys.

</details>

## How to use?

So, following above procedures, you have reloaded Hammerspoon's configutation. Let's see what we've got here.

### 1. Desktop Widgets

<details>
<summary>More details</summary>

As you may have noticed, there are two clean, nice-looking desktop widgets, analogclock and calendar. Usually we don't interact with them, but I do hope you like them.

![widgets](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-deskwidgets.png)

**UPDATE:** Add new widget `hcalendar` and make it default module. The design comes from [here](https://github.com/ashikahmad/horizontal-calendar-widget).

![hcal](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-hcal.png)

</details>

### 2. Mode Block

<details>
<summary>More details</summary>

There is also a small gray block in the bottom right corner, maybe displaying current netspeed. Well, it's actually **mode block**. Want to know in which mode you are? Give it a glance. When Hammerspoon starts, or there's no work to do, it shows `DOCK MODE` in black background. But alway displaying the black block is a little boring, so we use it for netspeed monitor if there's no activity for 5 secs.

**Mode block** holds the entrance to other modes, you can use <kbd>⌥</kbd> + <kbd>space</kbd> to toggle its display. Then use <kbd>⌥</kbd> + <kbd>R</kbd> to enter `resize` mode, or use <kbd>⌥</kbd> + <kbd>A</kbd> to enter `app` mode... etc.

Key bindings available:

| Key bindings                | Movement                   |
|-----------------------------|----------------------------|
| <kbd>⌥</kbd> + <kbd>A</kbd> | Enter `app` mode           |
| <kbd>⌥</kbd> + <kbd>C</kbd> | Enter `clipboard` mode     |
| <kbd>⌥</kbd> + <kbd>D</kbd> | Enter `download` mode      |
| <kbd>⌥</kbd> + <kbd>G</kbd> | Launch hammer search       |
| <kbd>⌥</kbd> + <kbd>I</kbd> | Enter `timer` mode         |
| <kbd>⌥</kbd> + <kbd>R</kbd> | Enter `resize` mode        |
| <kbd>⌥</kbd> + <kbd>S</kbd> | Enter `cheatsheet` mode    |
| <kbd>⌥</kbd> + <kbd>T</kbd> | Show current time          |
| <kbd>⌥</kbd> + <kbd>v</kbd> | Enter `view` mode          |
| <kbd>⌥</kbd> + <kbd>Z</kbd> | Toggle Hammerspoon console |
| <kbd>⌥</kbd> + <kbd>⇥</kbd> | Show window hints          |

*In most modes, you can use <kbd>Q</kbd>, or <kbd>⎋</kbd> to quit back to DOCK mode. And switch from one mode to another directly.*

</details>

### 3. Window Management(resize mode) <kbd>⌥</kbd> + <kbd>R</kbd>

<details>
<summary>More details</summary>

![winresize](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-winresize.gif)

Use <kbd>[/]</kbd> to cycle through active windows.

Use <kbd>H/J/K/L</kbd> to resize windows to 1/2 of screen.

Use <kbd>Y/U/I/O</kbd> to resize windows to 1/4 of screen.

Use <kbd>⇧</kbd> + <kbd>H/J/K/L</kbd> to **move** windows around.

Use <kbd>⇧</kbd> + <kbd>Y/U/I/O</kbd> to **resize** windows.

Use <kbd>=</kbd>, <kbd>-</kbd> to expand/shrink the window size.

Use <kbd>F</kbd> to put windows to fullscreen, use <kbd>C</kbd> to put windows to center of screen, use <kbd>⇧</kbd> + <kbd>C</kbd> to resize windows to predefined size and center them.

</details>

### 4. App Launcher(app mode) <kbd>⌥</kbd> + <kbd>A</kbd>

<details>
<summary>More details</summary>

Use <kbd>F</kbd> to launch Finder or focus the existing window; <kbd>S</kbd> for Safari; <kbd>T</kbd> for Terminal; <kbd>V</kbd> for Activity Monitor; <kbd>Y</kbd> for System Preferences... etc.

If you want to define your own hotkeys, please create `~/.hammerspoon/private/awesomeconfig.lua` file, then add something like below:

    applist = {
        {shortcut = 'i',appname = 'iTerm'},
        {shortcut = 'l',appname = 'Sublime Text'},
        {shortcut = 'm',appname = 'MacVim'},
        {shortcut = 'o',appname = 'LibreOffice'},
        {shortcut = 'r',appname = 'Firefox'},
    }

**UPDATE:** Now you can press <kbd>⇥</kbd> to show key bindings, also available in `resize`, `view`, `timer` mode.

![tips](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-tips.png)

</details>

### 5. Hammer Search(search mode) <kbd>⌥</kbd> + <kbd>G</kbd>

<details>
<summary>More details</summary>

Now you can search Safari tabs and online dictionary(use <kbd>⌃</kbd> + <kbd>⇥</kbd> to switch between them).

![hsearch](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-hsearch.gif)

Dictionary search supports `word suggestion`(see the above gif) and English thesaurus(use <kbd>⌃</kbd> + <kbd>D</kbd> to request). And did you notice that the translation is instant?

*Due to the uncertainty of asynchronous request, usually you need to append a space to end of the word to fully translate it.*

**NOTICE:** If you heavily rely on instant translation(youdao dict), please consider applying for your own API key at here:

[http://fanyi.youdao.com/openapi?path=data-mode](http://fanyi.youdao.com/openapi?path=data-mode)

Then add them to `~/.hammerspoon/private/awesomeconfig.lua`:

    youdaokeyfrom = 'hsearch'  -- keyfrom
    youdaoapikey = '1199732752'  -- API key

</details>

### 6. Timer Indicator(timer mode) <kbd>⌥</kbd> + <kbd>I</kbd>

<details>
<summary>More details</summary>

Have you noticed this issue on macos? There is 5 pixel tall blank at the bottom of the screen for non-native fullscreen window, which is sometimes disturbing. Let's make the blank more useful. When you set a timer, this will draw a colored line to fill that blank, meanwhile, show progress of the timer.

![timeralert](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-timeralert.png)

Press <kbd>0</kbd> to set a 5-mins timer, <kbd>↩︎</kbd> to set a 25-mins timer.

Press <kbd>1</kbd> to set a 10-mins timer;

Press <kbd>2</kbd> to set a 20-mins timer;

...

Press <kbd>9</kbd> to set a 90-mins timer.

</details>

### 7. Cheatsheet(cheatsheet mode) <kbd>⌥</kbd> + <kbd>S</kbd>

<details>
<summary>More details</summary>

It shows the cheatsheet of current application's hotkeys. Code comes from [here](https://github.com/dharmapoudel/hammerspoon-config).

Let the picture talk:

![cheatsheet](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-cheatsheet.png)

*Default off. To add this module to your config, please refer to the `Customization` section.*

</details>

### 8. Clipboard Show(clipboard mode) <kbd>⌥</kbd> + <kbd>C</kbd>

<details>
<summary>More details</summary>

It shows the content of your clipboard. If text or image type then display it with proper size, if hyperlink type then use default browser to open it. Click the display block it will destory itself.

I usually use this to display QR image for cellphone's faster scanning, or display some text for better reading.

</details>

### 9. Other Stuff

<details>
<summary>Tmux-styled Clock <kbd>⌥</kbd> + <kbd>T</kbd></summary>

Works even when you're watching video in fullscreen.

![tmuxtime](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-tmuxtime.png)

</details>

<details>
<summary>Windows Hint <kbd>⌥</kbd> + <kbd>⇥</kbd> </summary>

Focus to your windows easier.

![windowshint](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-windowshint.png)

</details>

<details>
<summary>View Mode <kbd>⌥</kbd> + <kbd>V</kbd></summary>

Use <kbd>H/J/K/L</kbd> to scroll around.

Use <kbd>⌃</kbd>/<kbd>⇧</kbd> + <kbd>H/J/K/L</kbd> to move mouse around.

Use <kbd>,</kbd>/<kbd>.</kbd> for mouse left/right click.

</details>

<details>
<summary>Download Mode(aria2 frontend) <kbd>⌥</kbd> + <kbd>D</kbd></summary>

I use [glutton](https://github.com/NemoAlex/glutton)(a tiny webclient for aria2) to manage aria2's download queue. This mode creates an interface for glutton, so I can handle aria2 more convenient.

*Default off. To add this module to your config, please refer to the `Customization` section.*

*To speed up the display of webclient, by default when you press `⎋` the interface is hiden(instead destroyed). This may increase resource occupation. If you don't use `download` mode for a long time, when quitting use <kbd>⌃</kbd> + <kbd>⎋</kbd> to completely destory the webclient.*

</details>

<details>
<summary>Lock Screen <kbd>⌘</kbd> + <kbd>⌃</kbd> + <kbd>⇧</kbd> + <kbd>L</kbd></summary>

No description.

</details>

<details>
<summary>And More...</summary>

For whatever mode, you can always use:

<kbd>⌘</kbd> + <kbd>⌥</kbd> + <kbd>⇠</kbd> to resize windows to left-half of screen

<kbd>⌘</kbd>  + <kbd>⌥</kbd> + <kbd>⇢</kbd> to resize windows to right-half of screen

<kbd>⌘</kbd>  + <kbd>⌥</kbd> +  <kbd>⇡</kbd> to resize windows to fullscreen

<kbd>⌘</kbd>  + <kbd>⌥</kbd> +  <kbd>⇣</kbd> to put windows to predefined size

<kbd>⌘</kbd>  + <kbd>⌥</kbd> +  <kbd>↩︎</kbd> to put windows to center of screen

-------

For those who care about system resource:

![memusage](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-memusage.png)

-------

</details>

## Customization

<details>
<summary>More details</summary>

Modify the file `~/.hammerspoon/private/awesomeconfig.lua`, you should create it before doing below things.

1. Add application launching hotkey

    See the section `App launcher(app mode)` above.

2. Add/Remove the plugin modules

    default modules:

        module_list = {
            "basicmode",
            "widgets/netspeed",
            "widgets/hcalendar",
            "widgets/analogclock",
            "modes/indicator",
            "modes/clipshow",
            "modes/hsearch",
        }

    For example, remove `hsearch` module, add your own module `mymodule`:

        module_list = {
            "basicmode",
            "widgets/netspeed",
            "widgets/hcalendar",
            "widgets/analogclock",
            "modes/indicator",
            "modes/clipshow",
            "private/mymodule",
        }

3. Modify/Remove the default key bindings

    Available key binding variables:

    | Action                     | Variable                    | Default value                   |
    |----------------------------|-----------------------------|---------------------------------|
    | Reload Configuration       | hsreload_keys               | {{"cmd", "shift", "ctrl"}, "R"} |
    | Toggle Modal Supervisor    | modalmgr_keys               | {{"alt"}, "space"}              |
    | Toggle Hammerspoon Console | toggleconsole_keys          | {{"alt"}, "Z"}                  |
    | Lock Screen                | lockscreen_keys             | {{"cmd", "shift", "ctrl"}, "L"} |
    | Enter Application Mode     | appM_keys                   | {{"alt"}, "A"}                  |
    | Enter Clipboard Mode       | clipboardM_keys             | {"alt"}, "C"}                   |
    | Launch Hammer Search       | hsearch_keys                | {{"alt"}, "G"}                  |
    | Enter Timer Mode           | timerM_keys                 | {{"alt"}, "T"}                  |
    | Enter Resize Mode          | resizeM_keys                | {{"alt"}, "R"}                  |
    | Enter Cheatsheet Mode      | cheatsheetM_keys            | {{"alt"}, "S"}                  |
    | Show Digital Clock         | showtime_keys               | {{"alt"}, "T"}                  |
    | Enter View Mode            | viewM_keys                  | {{"alt"}, "V"}                  |
    | Show Window hints          | winhints_keys               | {{"alt"}, "tab"}                |
    | Lefthalf of Screen         | resizeextra_lefthalf_keys   | {{"cmd", "alt"}, "left"}        |
    | Righthalf of Screen        | resizeextra_righthalf_keys  | {{"cmd", "alt"}, "right"}       |
    | Fullscreen                 | resizeextra_fullscreen_keys | {{"cmd", "alt"}, "up"}          |
    | Resize & Center            | resizeextra_fcenter_keys    | {{"cmd", "alt"}, "down"}        |
    | Center Window              | resizeextra_center_keys     | {{"cmd", "alt"}, "return"}      |

    For example, to modify `Toggle Modal Supervisor` key binding:

        modalmgr_keys = {{"alt"}, "F"}

    To completely remove `Lock Screen` key binding:

        lockscreen_keys = {{}, ""}

4. Create your own modal key bindings

    See [http://www.hammerspoon.org/docs/hs.hotkey.modal.html](http://www.hammerspoon.org/docs/hs.hotkey.modal.html), also you can refer to my scripts.

5. Global options

    These options should be put into `~/.hammerspoon/private/awesomeconfig.lua` file.

    ``` lua
    -- You may want to use your own aria2 webclient.
    aria2URL = "http://www.myaria2.com/"

    -- Local files also are supported, like this:
    aria2URL = "file:///Users/ashfinal/Downloads/glutton/index.html"

    -- Make mode block idle to netspeed or just hide.
    idle_to_which = "netspeed/hide/never"

    -- When enter `app` mode show or hide applauncher tips automatically.
    show_applauncher_tips = true/false

    -- Put analogclock to somewhere by defining center point.
    aclockcenter = {x=200,y=200}

    -- Put calendar to somewhere by defining topleft point.
    caltopleft = {200,200}
    ```

</details>

## Thanks to

<details>
<summary>More details</summary>

[http://www.hammerspoon.org/](http://www.hammerspoon.org/)

[https://github.com/zzamboni/oh-my-hammerspoon](https://github.com/zzamboni/oh-my-hammerspoon)

[https://github.com/scottcs/dot_hammerspoon](https://github.com/scottcs/dot_hammerspoon)

[https://github.com/dharmapoudel/hammerspoon-config](https://github.com/dharmapoudel/hammerspoon-config)

[http://tracesof.net/uebersicht/](http://tracesof.net/uebersicht/)

</details>

## Welcome to

Share your scripts and thoughts.

: )
