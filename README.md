# Awesome-hammerspoon, as advertised.

Awesome-hammerspoon is my collection of lua scripts for [Hammerspoon](http://www.hammerspoon.org/). It has highly modal-based, vim-styled key bindings, provides some functionality like desktop widgets, window management, application launcher, Alfred-like search, aria2 GUI, dictionary translation, cheatsheets, take notes ... etc.

## Get started

1. Install [Hammerspoon](http://www.hammerspoon.org/) first.
2. `git clone --depth 1 https://github.com/ashfinal/awesome-hammerspoon.git ~/.hammerspoon`
3. Reload the configutation.

and you're set.

## Keep update

See [awesome-hammerspoon whiteboard](https://github.com/ashfinal/awesome-hammerspoon/projects/2) for changlog and roadmap.

To update, run `cd ~/.hammerspoon && git pull`.

## What's modal-based key bindings?

<details>
<summary>More details</summary>

Well... simply to say, it allows you using <kbd>S</kbd> key to resize windows in `resize` mode, but in `app` mode, to launch Safari, in `timer` mode, to set a 10-mins timer... something like that. During all progress, you don't have to press extra keys.
</p>

And this means a lot.

* It's scene-wise, you can use same key bindings to do different jobs in different scenes. You don't worry to run out of your hotkey bindings, and twist your fingers to press <kbd>⌘</kbd> + <kbd>⌃</kbd> + <kbd>⌥</kbd> + <kbd>⇧</kbd> + <kbd>C</kbd> in the end.

* Less keystrokes, less memory pressure. You can press <kbd>⌥</kbd> + <kbd>A</kbd> to enter `app` mode, release, then press single key <kbd>S</kbd> to launch Safari, or <kbd>C</kbd> to lauch Chrome. Sounds good? You keep your pace, no rush.

* Easy to extend, you can create your own modals if you like. For example, `Finder` mode, in which you press <kbd>T</kbd> to open Terminal here, press <kbd>S</kbd> to send files to predefined path, press <kbd>C</kbd> to upload images to cloud storage.

</details>

## How to use?

So, following above procedures, you have reloaded Hammerspoon's configutation. Let's see what we've got here.

### 1. Desktop Widgets

<details>
<summary>More details</summary>

As you may have noticed, there are two clean, nice-looking desktop widgets, analogclock and hcalendar. Usually we don't interact with them, but I do hope you like them.

![widgets](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-deskwidgets.png)

*There are also other widgets [calendar](https://github.com/ashfinal/awesome-hammerspoon/blob/master/widgets/calendar.lua), [time elapsed](https://github.com/ashfinal/awesome-hammerspoon/blob/master/widgets/timelapsed.lua), maybe more …*

</details>

### 2. More Widgets and Modes

<details>
<summary>More details</summary>

There is actually more besides these. Now you can press <kbd>⌥</kbd> + <kbd>R</kbd> to enter `resize` mode, or press <kbd>⌥</kbd> + <kbd>A</kbd> to enter `app` mode …and start to explore.

In order to make one single keystroke work in two scenes, you may want to know in which scene you are now. If you enter certain scene (and forget to exit, and wonder why your regular typing doesn't work as expected), see if there is a small circle in the bottom right corner, which indicates different scenes with different color. If that's the fact, then you realize you need to press <kbd>⎋</kbd>, exit current scene, dismiss the circle, and get back to your work.

Key bindings available:

| Key bindings                | Movement                   |
| --------------------------- | -------------------------- |
| <kbd>⌥</kbd> + <kbd>A</kbd> | Enter `app` mode           |
| <kbd>⌥</kbd> + <kbd>C</kbd> | Enter `clipboard` mode     |
| <kbd>⌥</kbd> + <kbd>D</kbd> | Launch aria2 GUI .         |
| <kbd>⌥</kbd> + <kbd>G</kbd> | Launch hammer search       |
| <kbd>⌥</kbd> + <kbd>I</kbd> | Enter `timer` mode         |
| <kbd>⌥</kbd> + <kbd>R</kbd> | Enter `resize` mode        |
| <kbd>⌥</kbd> + <kbd>S</kbd> | Enter `cheatsheet` mode    |
| <kbd>⌥</kbd> + <kbd>T</kbd> | Show current time          |
| <kbd>⌥</kbd> + <kbd>v</kbd> | Enter `view` mode          |
| <kbd>⌥</kbd> + <kbd>Z</kbd> | Toggle Hammerspoon console |
| <kbd>⌥</kbd> + <kbd>⇥</kbd> | Show window hints          |

*In most modes, you can use <kbd>Q</kbd>, or <kbd>⎋</kbd> to quit back. And switch from one mode to another directly.*

</details>

### 3. Window Management(resize mode) <kbd>⌥</kbd> + <kbd>R</kbd>

<details>
<summary>More details</summary>

![winresize](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-winresize.gif)

Use <kbd>[/]</kbd> to cycle through active windows.

Use <kbd>H/J/K/L</kbd> to resize windows to 1/2 of screen.

Use <kbd>Y/U/I/O</kbd> to resize windows to 1/4 of screen.

Use <kbd>⇧</kbd> + <kbd>H/J/K/L</kbd> to **move** windows around.

Use <kbd>␣</kbd> or <kbd>⇡⇣⇠⇢⇠</kbd> to **move** windows to **other screens**.

Use <kbd>⇧</kbd> + <kbd>Y/U/I/O</kbd> to **resize** windows.

Use <kbd>=</kbd>, <kbd>-</kbd> to **expand**/**shrink** the window size.

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

**UPDATE:** Now you can press <kbd>⇥</kbd> to toggle key bindings, also available in `resize`, `view`, `timer` mode.

![tips](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-tips.png)

</details>

### 5. Hammer Search <kbd>⌥</kbd> + <kbd>G</kbd>

<details>
<summary>More details</summary>

Now you can do lots of things with Hammerspoon search: search Safari tabs, dictionary translation, kill active application, English thesaurus, get latest posts from v2ex, emoji search, take notes … etc. And feel free to add your own source!

![hsearch](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-hsearch.gif)

**NOTICE:** If you heavily rely on instant translation(youdao dict), please consider applying for your own API key at here:

[http://fanyi.youdao.com/openapi?path=data-mode](http://fanyi.youdao.com/openapi?path=data-mode)

Then add them to `~/.hammerspoon/private/awesomeconfig.lua`:

    youdaokeyfrom = 'hsearch'  -- keyfrom
    youdaoapikey = '1199732752'  -- API key

</details>

### 6. Aria2 GUI <kbd>⌥</kbd> + <kbd>D</kbd>

<details>
<summary>More details</summary>

This is a "native" frontend for [aria2](https://github.com/aria2/aria2).

![hsearch](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-aria2.png)

You need to [run aria2 with RPC enabled](https://github.com/ashfinal/awesome-hammerspoon/wiki#run-aria2-with-rpc) before using this. Config aria2 host and token in `~/.hammerspoon/private/awesomeconfig.lua`, then you're ready to go.

    aria2_host = "http://localhost:6800/jsonrpc" -- default host
    aria2_token = "token" -- YOUR OWN TOKEN

Add new task (regular URL or BTfile or Metafile) from aria2 "toolbar", click certain task item to pause/resume the download, or open completed files. While holding down `⌘` key, you click certain item, that will stop the download, or remove the completed/error task. It will notify you if there is any completed download or any error, even aria2 window is closed. And you can batch add tasks from your pasteboard, one URL per line.

</details>

### 7. Timer Indicator(timer mode) <kbd>⌥</kbd> + <kbd>I</kbd>

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

### 8. Cheatsheet(cheatsheet mode) <kbd>⌥</kbd> + <kbd>S</kbd>

<details>
<summary>More details</summary>

It shows the cheatsheet of current application's hotkeys. Code comes from [here](https://github.com/dharmapoudel/hammerspoon-config).

Let the picture talk:

![cheatsheet](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-cheatsheet.png)

</details>

### 9. Clipboard Show <kbd>⌥</kbd> + <kbd>C</kbd>

<details>
<summary>More details</summary>

It shows the content of your clipboard. If text or image type then display it with proper size, if hyperlink type then use default browser to open it. Click the display block it will destory itself.

I usually use this to display QR image for cellphone's faster scanning, or display some text for better reading. And I never need to do this below: focus the default browser, click the address bar, paste the URL and press Enter to go.

</details>

### 10. Other Stuff

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
<summary>Netspeed Monitor</summary>

Watch your netspeed sitting on the menubar. Support macos's darkmode.

</details>

<details>
<summary>Bing Wallpaper</summary>

Automatically use Bing daily picture for your wallpaper.

</details>

<details>
<summary>Lock Screen <kbd>⌘</kbd> + <kbd>⌃</kbd> + <kbd>⇧</kbd> + <kbd>L</kbd></summary>

No description.

</details>

<details>
<summary>And More...</summary>

For whatever mode, you can always use:

<kbd>fn</kbd> + <kbd>H/J/K/L</kbd> to navigate, <kbd>fn</kbd> + <kbd>Y/U/I/O</kbd> to scroll, + <kbd>,</kbd> to leftClick, + <kbd>.</kbd> to rightClick.

<kbd>⌘</kbd> + <kbd>⌥</kbd> + <kbd>⇠</kbd> to resize windows to left-half of screen

<kbd>⌘</kbd>  + <kbd>⌥</kbd> + <kbd>⇢</kbd> to resize windows to right-half of screen

<kbd>⌘</kbd>  + <kbd>⌥</kbd> +  <kbd>⇡</kbd> to resize windows to fullscreen

<kbd>⌘</kbd>  + <kbd>⌥</kbd> +  <kbd>⇣</kbd> to put windows to predefined size

<kbd>⌘</kbd>  + <kbd>⌥</kbd> +  <kbd>↩︎</kbd> to put windows to center of screen

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
            "widgets/netspeed",
            "widgets/calendar",
            "widgets/hcalendar",
            "widgets/analogclock",
            "widgets/timelapsed",
            "widgets/aria2",
            "modes/basicmode",
            "modes/indicator",
            "modes/clipshow",
            "modes/cheatsheet",
            "modes/hsearch",
            "misc/bingdaily",
        }

    For example, remove `bingdaily` module, add your own module `mymodule`:

        module_list = {
            "widgets/netspeed",
            "widgets/calendar",
            "widgets/hcalendar",
            "widgets/analogclock",
            "widgets/timelapsed",
            "widgets/aria2",
            "modes/basicmode",
            "modes/indicator",
            "modes/clipshow",
            "modes/cheatsheet",
            "modes/hsearch",
            "private/mymodule",
        }

3. Modify/Remove the default key bindings

    Available key binding variables:

    | Action                     | Variable                    | Default value                   |
    | -------------------------- | --------------------------- | ------------------------------- |
    | Reload Configuration       | hsreload_keys               | {{"cmd", "shift", "ctrl"}, "R"} |
    | Toggle Modal Supervisor    | modalmgr_keys               | {{"cmd", "shift", "ctrl"}, "Q"} |
    | Toggle Hammerspoon Console | toggleconsole_keys          | {{"alt"}, "Z"}                  |
    | Lock Screen                | lockscreen_keys             | {{"cmd", "shift", "ctrl"}, "L"} |
    | Enter Application Mode     | appM_keys                   | {{"alt"}, "A"}                  |
    | Enter Clipboard Mode       | clipboardM_keys             | {"alt"}, "C"}                   |
    | Launch Aria2 GUI .         | aria2_keys .                | {"alt"}, "D"}                   |
    | Launch Hammer Search       | hsearch_keys                | {{"alt"}, "G"}                  |
    | Enter Timer Mode           | timerM_keys                 | {{"alt"}, "T"}                  |
    | Enter Resize Mode          | resizeM_keys                | {{"alt"}, "R"}                  |
    | Enter Cheatsheet Mode      | cheatsheetM_keys            | {{"alt"}, "S"}                  |
    | Show Digital Clock         | showtime_keys               | {{"alt"}, "T"}                  |
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

4. Global options

    These options should be put into `~/.hammerspoon/private/awesomeconfig.lua` file.

    ``` lua
    aria2_host = "http://localhost:6800/jsonrpc" -- default host
    aria2_token = "token" -- YOUR OWN TOKEN
    aria2_refresh_interval = 1 -- How often the frontend should request data from the host
    aria2_show_items_max = 5 -- How many items the frontend should show

    -- When enter `resize/app/timer` mode show or hide applauncher tips automatically.
    show_resize_tips = true/false
    show_applauncher_tips = true/false
    show_timer_tips = true/false

    hotkey_tips_bg = "light"/"dark" -- Make the hotkey tips' background light or dark

    -- Put analogclock to somewhere by defining center point.
    aclockcenter = {x=200,y=200}

    -- Put calendar to somewhere by defining topleft point.
    caltopleft = {2000,200}

    -- Put timelapsed to somewhere by defining topleft point.
    timelapsetopleft = {200,1800}
    ```

</details>

## FAQ

<details>
<summary>How can I integrate my little script into this configutation?</summary>

Use `private` folder and `~/.hammerspoon/private/awesomeconfig.lua` file.

If your script is just a few lines, then put it into `~/.hammerspoon/private/awesomeconfig.lua` file. If it is long enough, create a file in `private` folder, e.g. `mymodule.lua` (Wow, you just create a "module" without extra code), then include this module in `~/.hammerspoon/private/awesomeconfig.lua` file.

        module_list = {
            ...
            "private/mymodule",
        }

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
