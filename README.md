<p align="center"><img src="icon.png" width="96" alt="HebrewFix icon"></p>

<h1 align="center">HebrewFix</h1>

<p align="center">Typed <code>akuo</code> when you meant <code>שלום</code>? Fix it with one click.<br>
A tiny Windows tray app that converts text typed in the wrong keyboard layout, English ⇄ Hebrew.</p>

<p align="center"><a href="https://github.com/mickeyperry/hebrew-fix/releases/latest/download/HebrewFix-Setup.exe"><b>⬇ Download installer</b></a> &nbsp;·&nbsp; <a href="https://github.com/mickeyperry/hebrew-fix/releases/latest/download/HebrewFix.exe">portable .exe</a></p>

---

## How to use

| | |
|---|---|
| **Right-click** | Select the wrong text, right-click it, then click **⇄ Fix layout** (the button docks onto the app's right-click menu). |
| **Hotkey** | Select text and press **Pause** (or **Ctrl+Shift+Alt+H**). |
| **Nothing selected?** | The hotkey fixes the last word before the cursor. |

- **Automatic direction:** mostly Hebrew text becomes English, everything else becomes Hebrew.
- **Switches your keyboard language** to match the fixed text, so you can keep typing (can be turned off).
- **Keeps your clipboard:** whatever you had copied is restored afterwards.
- Works in browsers, Office, Teams, Slack, WhatsApp, VS Code, Notepad and most other apps.
- Terminals are skipped on purpose (Ctrl+C there would stop the running program).

| Typed | Fixed |
|---|---|
| `akuo` | `שלום` |
| `tbh tuvc` | `אני אוהב` |
| `/'קראטו` | `qwertyu` |

## Install

1. Download **[HebrewFix-Setup.exe](https://github.com/mickeyperry/hebrew-fix/releases/latest/download/HebrewFix-Setup.exe)** and run it. No admin rights are needed; it installs for your user only.
2. Leave **Start with Windows** checked if you want it running at every startup.

Windows SmartScreen may warn about an unknown publisher because the app isn't code-signed. Click **More info → Run anyway**.

Don't want to install? Grab the **[portable HebrewFix.exe](https://github.com/mickeyperry/hebrew-fix/releases/latest/download/HebrewFix.exe)** and run it from anywhere.

Uninstall from **Settings → Apps** like any other app.

## Tray menu

Right-click the tray icon to:
- turn the right-click button on/off
- turn the automatic keyboard-language switch on/off
- start with Windows on/off
- **Run as admin**, needed only to fix text inside apps that run as administrator
- edit settings

## Settings

`%AppData%\HebrewFix\settings.ini`

```ini
[Settings]
Hotkey=Pause          ; AutoHotkey syntax: ^ Ctrl, + Shift, ! Alt, # Win
Hotkey2=^+!h
RightClickButton=1
SwitchLayout=1
HideAfterMs=4000
```

Choose **Reload** in the tray menu after editing.

## Build from source

Requires [AutoHotkey v1.1](https://www.autohotkey.com/) (with Ahk2Exe) and [Inno Setup 6](https://jrsoftware.org/isinfo.php).

```powershell
.\build.ps1        # -> dist\HebrewFix.exe and dist\HebrewFix-Setup.exe
```

You can also run `HebrewFix.ahk` directly with AutoHotkey v1. If AutoHotkey's UI Access build is installed, the script switches to it automatically so it also works in admin windows.

---

<div dir="rtl">

## בעברית

כתבתם `akuo` במקום `שלום`? HebrewFix מתקן טקסט שהוקלד בשפת מקלדת שגויה, אנגלית ⇄ עברית.

- **קליק ימני:** מסמנים את הטקסט, לוחצים קליק ימני ובוחרים **⇄ Fix layout**.
- **קיצור מקלדת:** מסמנים ולוחצים **Pause** (או Ctrl+Shift+Alt+H). בלי סימון, המילה האחרונה מתוקנת.
- הכיוון נקבע אוטומטית, ושפת המקלדת מתחלפת בהתאם.
- [להורדת קובץ ההתקנה](https://github.com/mickeyperry/hebrew-fix/releases/latest/download/HebrewFix-Setup.exe)

</div>

## License

MIT
