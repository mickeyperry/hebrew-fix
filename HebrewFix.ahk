; HebrewFix — fix text typed in the wrong keyboard layout (English <-> Hebrew)
;   * Right-click a text field: a "Fix layout" button docks onto the app's right-click menu.
;   * Or select text and press the hotkey (default: Pause, or Ctrl+Shift+Alt+H).
;     With nothing selected, the hotkey fixes the last word before the cursor.
;   * Direction is automatic: mostly Hebrew -> English, otherwise English -> Hebrew.
;   * Settings: %AppData%\HebrewFix\settings.ini (or tray menu > Edit settings)

;@Ahk2Exe-SetName HebrewFix
;@Ahk2Exe-SetDescription HebrewFix - fix English/Hebrew wrong-layout text
;@Ahk2Exe-SetVersion 1.0.1
;@Ahk2Exe-SetCompanyName Mickey Perry
;@Ahk2Exe-SetCopyright MIT License
;@Ahk2Exe-SetMainIcon icon.ico

#SingleInstance Force
#NoEnv
#Persistent
#InstallMouseHook
#InstallKeybdHook
#MaxThreadsPerHotkey 1
#ClipboardTimeout 2000
SendMode Input
SetBatchLines, -1
SetWinDelay, -1
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetWorkingDir %A_ScriptDir%

; Relaunch with AutoHotkey's UIAccess build when installed, so it also works in admin windows
if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA") && !A_IsAdmin) {
    SplitPath, A_AhkPath,, ahkDir
    uia := ahkDir "\AutoHotkeyU" (A_PtrSize = 8 ? "64" : "32") "_UIA.exe"
    if FileExist(uia) {
        Run, "%uia%" "%A_ScriptFullPath%",, UseErrorLevel
        if !ErrorLevel
            ExitApp
    }
}

; ---------- Settings ----------
CfgDir := A_AppData "\HebrewFix"
FileCreateDir, %CfgDir%
Ini := CfgDir "\settings.ini"
if !FileExist(Ini) {
    IniWrite, Pause,  %Ini%, Settings, Hotkey
    IniWrite, ^+!h,   %Ini%, Settings, Hotkey2
    IniWrite, 1,      %Ini%, Settings, RightClickButton
    IniWrite, 1,      %Ini%, Settings, SwitchLayout
    IniWrite, 4000,   %Ini%, Settings, HideAfterMs
}
IniRead, HotkeyMain, %Ini%, Settings, Hotkey, Pause
IniRead, HotkeyAlt,  %Ini%, Settings, Hotkey2, ^+!h
IniRead, UseRClick,  %Ini%, Settings, RightClickButton, 1
IniRead, DoSwitch,   %Ini%, Settings, SwitchLayout, 1
IniRead, HideAfter,  %Ini%, Settings, HideAfterMs, 4000

; ---------- Layout maps (by physical key, standard Hebrew SI-1452) ----------
engKeys := "qwertyuiopasdfghjkl;'zxcvbnm,./"
hebKeys := "/'קראטוןםפשדגכעיחלךף,זסבהנמצתץ."
ToHeb := {}, ToEng := {}
Loop, Parse, engKeys
{
    h := SubStr(hebKeys, A_Index, 1)
    ToHeb[A_LoopField] := h      ; keys are case-insensitive, so A..Z work too
    ToEng[h] := A_LoopField
}
ToHeb["``"] := ";", ToEng[";"] := "``"

; ---------- Floating button ----------
Gui, Btn:New, +AlwaysOnTop -Caption +ToolWindow +Border +HwndBtnHwnd
Gui, Btn:Color, FFFFFF
Gui, Btn:Font, s10, Segoe UI
Gui, Btn:Add, Text, x10 y7 w210 h20 Center BackgroundTrans, ⇄  Fix layout  (EN ↔ עב)
Gui, Btn:Show, Hide w230 h34
DetectHiddenWindows, On          ; the button is hidden while we measure it
WinGetPos,,, BtnW, BtnH, ahk_id %BtnHwnd%
DetectHiddenWindows, Off
if (BtnW = "" || BtnH = "")
    BtnW := Round(230 * A_ScreenDPI / 96), BtnH := Round(34 * A_ScreenDPI / 96)
BtnHover := false, BtnBusy := false, Offer := false
TargetWin := 0, ClickX := 0, ClickY := 0, ClickWin := 0

; ---------- Hotkeys ----------
for _, hk in [HotkeyMain, HotkeyAlt]
    if (hk != "" && hk != "ERROR") {
        Hotkey, %hk%, HotkeyConvert, UseErrorLevel
        if ErrorLevel
            TrayTip, HebrewFix, Invalid hotkey in settings: %hk%, 5, 2
    }

; ---------- Tray ----------
StartupLnk := A_Startup "\HebrewFix.lnk"
if (!A_IsCompiled && FileExist(A_ScriptDir "\icon.ico"))
    Menu, Tray, Icon, %A_ScriptDir%\icon.ico
Menu, Tray, NoStandard
Menu, Tray, Tip, HebrewFix — select text`, press %HotkeyMain% or right-click
Menu, Tray, Add, HebrewFix (how to use), TrayAbout
Menu, Tray, Add
Menu, Tray, Add, Button on right-click, TrayToggleRClick
Menu, Tray, Add, Switch keyboard language after fix, TrayToggleSwitch
Menu, Tray, Add, Start with Windows, TrayToggleStartup
Menu, Tray, Add, Run as admin, TrayRunAdmin
Menu, Tray, Add, Edit settings, TraySettings
Menu, Tray, Add
Menu, Tray, Add, Reload, TrayReload
Menu, Tray, Add, Exit, TrayExit
Menu, Tray, Default, HebrewFix (how to use)
if UseRClick
    Menu, Tray, Check, Button on right-click
if DoSwitch
    Menu, Tray, Check, Switch keyboard language after fix
if FileExist(StartupLnk)
    Menu, Tray, Check, Start with Windows
if (A_IsAdmin || InStr(A_AhkPath, "_UIA"))
    Menu, Tray, Disable, Run as admin
return

; =====================================================================
; Right-click: decide whether to offer the button, then dock it on the menu
~RButton::
    HideBtn()
    Offer := false
    if !UseRClick
        return
    MouseGetPos, ClickX, ClickY, ClickWin
    if (ClickWin != BtnHwnd)
        Offer := ShouldOffer(ClickWin)
return

~RButton Up::
    if !Offer
        return
    Offer := false
    TargetWin := ClickWin
    SetTimer, PlaceBtn, -150     ; let the app open its menu first
return

PlaceBtn:
    GetWorkArea(ClickX, ClickY, wL, wT, wR, wB)
    menu := FindMenu(ClickX, ClickY)
    if (menu) {
        WinGetPos, mx, my, mw, mh, ahk_id %menu%
        bx := mx, by := my - BtnH - 2
        if (by < wT)
            by := my + mh + 2
    } else {
        bx := ClickX - 20, by := ClickY - BtnH - 10
    }
    bx := Max(wL, Min(bx, wR - BtnW)), by := Max(wT, Min(by, wB - BtnH))
    if bx is not number
        bx := ClickX
    if by is not number
        by := ClickY
    Gui, Btn:Show, x%bx% y%by% NoActivate
    WinSet, AlwaysOnTop, On, ahk_id %BtnHwnd%
    SetTimer, WatchBtn, 50
    SetTimer, AutoHide, % -Abs(HideAfter)
return

; Click on the button: convert. The click is swallowed so the app never sees it.
#If BtnUnderMouse()
LButton::
    BtnBusy := true
    HideBtn()
    if FindMenu(ClickX, ClickY)
        Send {Esc}               ; close the app's right-click menu
    Sleep 30
    if (TargetWin && WinExist("ahk_id " TargetWin)) {
        WinActivate, ahk_id %TargetWin%
        WinWaitActive, ahk_id %TargetWin%,, 1
    }
    Sleep 40
    DoConvert(false)
    KeyWait, LButton
    BtnBusy := false
return
#If BtnBusy
LButton Up::return
#If

; Hide when clicking elsewhere / pressing Esc; hover highlight
WatchBtn:
    if !DllCall("IsWindowVisible", "Ptr", BtnHwnd) {
        SetTimer, WatchBtn, Off
        return
    }
    over := BtnUnderMouse()
    if (!over && (GetKeyState("LButton", "P") || GetKeyState("Escape", "P"))) {
        HideBtn()
        return
    }
    if (over != BtnHover) {
        BtnHover := over
        Gui, Btn:Color, % over ? "CCE4F7" : "FFFFFF"
    }
return

AutoHide:
    if !BtnUnderMouse()
        HideBtn()
    else
        SetTimer, AutoHide, -1000
return

HotkeyConvert:
    KeyWait, Control, T1
    KeyWait, Shift, T1
    KeyWait, Alt, T1
    KeyWait, LWin, T1
    KeyWait, RWin, T1
    DoConvert(true)
return

; =====================================================================
DoConvert(selectWordIfEmpty) {
    global DoSwitch
    static busy := false
    if busy
        return
    busy := true
    WinGet, pid, PID, A
    WinGetClass, cls, A
    if cls in ConsoleWindowClass,CASCADIA_HOSTING_WINDOW_CLASS,mintty,VirtualConsoleClass
    {
        Tip("Not supported in terminal windows (Ctrl+C would stop the program)")
        busy := false
        return
    }
    saved := ClipboardAll
    text := GetSelection()
    if (text = "" && selectWordIfEmpty) {
        Send ^+{Left}            ; nothing selected: grab the previous word
        Sleep 60
        text := GetSelection()
    }
    if (text = "") {
        Clipboard := saved
        if (IsElevated(pid) && !A_IsAdmin && !InStr(A_AhkPath, "_UIA"))
            Tip("That window runs as admin.`nTray icon > Run as admin")
        else
            Tip("No text selected")
        busy := false
        return
    }
    out := ConvertText(text, dir)
    if (out == text) {
        Clipboard := saved
        busy := false
        return
    }
    Clipboard := out
    ClipWait, 1
    Send ^v
    Sleep 300                    ; let the app finish pasting before restoring
    Clipboard := saved
    saved := ""
    if DoSwitch
        SwitchLayout(dir)
    busy := false
}

ConvertText(text, ByRef dir) {
    global ToHeb, ToEng
    RegExReplace(text, "[\x{05D0}-\x{05EA}]", "", hebN)
    RegExReplace(text, "[A-Za-z]", "", latN)
    dir := (hebN > latN) ? "en" : "he"
    map := (dir = "en") ? ToEng : ToHeb
    out := ""
    Loop, Parse, text
        out .= map.HasKey(A_LoopField) ? map[A_LoopField] : A_LoopField
    return out
}

GetSelection() {
    Clipboard := ""
    Send ^c
    ClipWait, 0.5
    if ErrorLevel {
        Send ^{Insert}           ; fallback copy shortcut some apps prefer
        ClipWait, 0.5
    }
    return ErrorLevel ? "" : Clipboard
}

; Switch the active window's input language to match the converted text
SwitchLayout(dir) {
    n := DllCall("GetKeyboardLayoutList", "Int", 0, "Ptr", 0)
    VarSetCapacity(buf, n * A_PtrSize, 0)
    DllCall("GetKeyboardLayoutList", "Int", n, "Ptr", &buf)
    Loop, %n% {
        hkl := NumGet(buf, (A_Index - 1) * A_PtrSize, "Ptr")
        lang := hkl & 0xFFFF
        if ((dir = "he" && lang = 0x040D) || (dir = "en" && (lang & 0x3FF) = 0x09)) {
            ControlGetFocus, ctl, A
            if (ctl != "")
                PostMessage, 0x50, 0, %hkl%, %ctl%, A
            else
                PostMessage, 0x50, 0, %hkl%,, A
            return
        }
    }
}

ShouldOffer(win) {
    if (A_Cursor = "IBeam")
        return true
    WinGetClass, cls, ahk_id %win%
    if cls in ConsoleWindowClass,CASCADIA_HOSTING_WINDOW_CLASS,mintty,VirtualConsoleClass,Progman,WorkerW,Shell_TrayWnd
        return false
    ; Browsers, Electron apps (Teams, Slack, VS Code, WhatsApp), Office
    if cls in Chrome_WidgetWin_1,MozillaWindowClass,OpusApp,rctrl_renwnd32,XLMAIN,PPTFrameClass
        return true
    ; Any window that currently has a text caret
    tid := DllCall("GetWindowThreadProcessId", "Ptr", win, "Ptr", 0, "UInt")
    cb := A_PtrSize = 8 ? 72 : 48
    VarSetCapacity(gti, cb, 0), NumPut(cb, gti, 0, "UInt")
    if DllCall("GetGUIThreadInfo", "UInt", tid, "Ptr", &gti)
        return NumGet(gti, 8 + A_PtrSize * 5, "Ptr") != 0
    return false
}

; Find the popup menu the app opened at the click point (top-most first)
FindMenu(px, py) {
    global BtnHwnd, ClickWin
    root := DllCall("GetAncestor", "Ptr", ClickWin, "UInt", 2, "Ptr")
    WinGet, ids, List
    Loop, %ids% {
        h := ids%A_Index%
        if (h = BtnHwnd || h = root)
            continue
        WinGet, st, Style, ahk_id %h%
        if !(st & 0x80000000)    ; WS_POPUP
            continue
        WinGetPos, x, y, w, ht, ahk_id %h%
        if (w < 40 || ht < 20 || w > 900 || ht > A_ScreenHeight)
            continue
        if (px >= x - 8 && px <= x + w + 8 && py >= y - 8 && py <= y + ht + 8)
            return h
    }
    return 0
}

GetWorkArea(x, y, ByRef l, ByRef t, ByRef r, ByRef b) {
    SysGet, cnt, MonitorCount
    Loop, %cnt% {
        SysGet, m, MonitorWorkArea, %A_Index%
        if (x >= mLeft && x < mRight && y >= mTop && y < mBottom) {
            l := mLeft, t := mTop, r := mRight, b := mBottom
            return
        }
    }
    SysGet, m, MonitorWorkArea
    l := mLeft, t := mTop, r := mRight, b := mBottom
}

BtnUnderMouse() {
    global BtnHwnd
    if !DllCall("IsWindowVisible", "Ptr", BtnHwnd)
        return false
    MouseGetPos,,, w
    return (w = BtnHwnd)
}

HideBtn() {
    global BtnHover
    Gui, Btn:Hide
    SetTimer, WatchBtn, Off
    SetTimer, AutoHide, Off
    if BtnHover {
        BtnHover := false
        Gui, Btn:Color, FFFFFF
    }
}

IsElevated(pid) {
    hProc := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "UInt", pid, "Ptr")
    if !hProc
        return true              ; can't even open it: almost certainly elevated
    elevated := false
    if DllCall("advapi32\OpenProcessToken", "Ptr", hProc, "UInt", 0x8, "Ptr*", hTok) {
        VarSetCapacity(e, 4, 0)
        if DllCall("advapi32\GetTokenInformation", "Ptr", hTok, "Int", 20, "Ptr", &e, "UInt", 4, "UInt*", ret)
            elevated := NumGet(e, 0, "UInt")
        DllCall("CloseHandle", "Ptr", hTok)
    }
    DllCall("CloseHandle", "Ptr", hProc)
    return elevated
}

Tip(msg) {
    MouseGetPos, x, y
    ToolTip, %msg%, % x + 16, % y + 16
    SetTimer, RemoveTip, -2500
}

RemoveTip:
    ToolTip
return

; ---------- Tray handlers ----------
TrayAbout:
    MsgBox, 64, HebrewFix, % "Fixes text typed in the wrong keyboard layout (English <-> Hebrew).`n`n"
        . "• Right-click a text field, then click 'Fix layout'.`n"
        . "• Or select text and press " HotkeyMain " (or " HotkeyAlt ").`n"
        . "  Nothing selected = fixes the last word.`n`n"
        . "Settings file:`n" Ini
return

TrayToggleRClick:
    UseRClick := !UseRClick
    IniWrite, %UseRClick%, %Ini%, Settings, RightClickButton
    Menu, Tray, ToggleCheck, Button on right-click
return

TrayToggleSwitch:
    DoSwitch := !DoSwitch
    IniWrite, %DoSwitch%, %Ini%, Settings, SwitchLayout
    Menu, Tray, ToggleCheck, Switch keyboard language after fix
return

TrayToggleStartup:
    if FileExist(StartupLnk) {
        FileDelete, %StartupLnk%
    } else if A_IsCompiled {
        FileCreateShortcut, %A_ScriptFullPath%, %StartupLnk%, %A_ScriptDir%
    } else {
        FileCreateShortcut, %A_AhkPath%, %StartupLnk%, %A_ScriptDir%, "%A_ScriptFullPath%"
    }
    Menu, Tray, ToggleCheck, Start with Windows
return

TrayRunAdmin:
    if A_IsCompiled
        Run, *RunAs "%A_ScriptFullPath%",, UseErrorLevel
    else
        Run, *RunAs "%A_AhkPath%" "%A_ScriptFullPath%",, UseErrorLevel
    if !ErrorLevel
        ExitApp
return

TraySettings:
    Run, notepad.exe "%Ini%"
return

TrayReload:
    Reload
return

TrayExit:
    ExitApp
