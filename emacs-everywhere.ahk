;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         David <tchepak@gmail.com>, Kimi <kimi.im@outlook.com>
;
; Script Function:
;   Provides an Emacs-like keybinding emulation mode
;

;Disable Emacs Keys for the following programs:
GroupAdd, NotActiveGroup, ahk_class mintty ;, ahk_exe foo.exe, etc..
GroupAdd, NotActiveGroup, ahk_class Emacs
;GroupAdd, NotActiveGroup, ahk_class TTOTAL_CMD
GroupAdd, NotActiveGroup, ahk_exe VirtualBoxVM.exe
GroupAdd, NotActiveGroup, ahk_exe vcxsrv.exe
GroupAdd, NotActiveGroup, ahk_exe devenv.exe ;; visualstudio

;==========================
;Initialise
;==========================
; no env creates problems with rider64.exe
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

EnvGet, msys64, MSYS64_PATH

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

enabledIcon := "emacs-everywhere-enable.ico"
disabledIcon := "emacs-everywhere-disable.ico"
IsInEmacsMode := false
IsInSelectMode := false

; dont show S when suspend
Menu, Tray, Icon, emacs-everywhere-enable.ico, , 1

SetEmacsMode(true)
SetSelectMode(false)

FilterApps(ByRef emacskey, ByRef stroke1, ByRef stroke2){
    SetTitleMatchMode 2 ; match start with

    if WinActive("ahk_exe notepad++.exe")
    {
        if( emacskey = "^s"){
            Send, ^!i
            return "stop"
        }

    }

    if WinActive("ahk_exe idea.exe")
    {
        if( emacskey = "^k"){
            Send, ^k
            return "stop"
        }

    }

    if WinActive("ahk_class AcrobatSDIWindow"){
        if( emacskey = "^s" ){
            stroke1 = ^f
        }
        if( emacskey = "^r" ){
            stroke1 = {Shift}+{F3}
        }
    }

    if WinActive("ahk_class MozillaUIWindowClass"){
        if( emacskey = "^s")
            stroke1 = ^f
        if( emacskey = "^r")
            stroke1 = ^f
    }

    if WinActive("ahk_class SUMATRA_PDF_FRAME"){
        if( emacskey = "^s")
            stroke1 = ^f
        if( emacskey = "^r")
            stroke1 = ^f
    }

    if WinActive("ahk_exe Notepad2.exe") AND WinActive("Find Text") {
        if( emacskey = "^s"){
            ControlClick, &Find Next, Find Text
            return "stop"
        }
        if( emacskey = "^r"){
            ControlClick, Find &Previous, Find Text
            return "stop"
        }
    } else if WinActive("ahk_exe Notepad2.exe"){
        if( emacskey = "^s")
            stroke1 = ^f
        if( emacskey = "^r")
            stroke1 = ^f
    }

    if WinActive("ahk_exe cmd.exe") {
        if( emacskey = "^x^c"){
            WinClose, A
            return "stop"
        }
    }

    if WinActive("ahk_class Chrome_WidgetWin_1"){
        if( emacskey = "^s")
            stroke1 = ^f
        if( emacskey = "^r")
            stroke1 = {SHIFTDOWN}{F3}{SHIFTUP}
    }

    if WinActive("ahk_exe rider64.exe") {
        if( emacskey = "^k"){
            Send, ^k
            return "stop"
        }
        if( emacskey = "^s"){
            Send, ^f
            return "stop"
        }
    }
    if WinActive("ahk_exe idea64.exe") {
        if( emacskey = "^k"){
            Send, ^k
            return "stop"
        }
        if( emacskey = "^s"){
            Send, ^f
            return "stop"
        }
    }
    if WinActive("ahk_exe LINQPad.exe") {
        if( emacsKey = "^x^x"){
            Send, ^x
            return "stop"
        }
    }


    SetTitleMatchMode 2
    if WinActive("ahk_exe devenv.exe") {
        if( emacsKey = "^k" ){
            Send, ^k
            return "stop"
        }
        if( emacskey = "^s" OR emacskey = "^r" OR emacsKey = "^x^s" OR emacsKey = "^xu" OR emacsKey = "^x^x"){
            Send, %emacskey%
            return "stop"
        }
    }

    return "ok"
}

;==========================
;Functions
;==========================
SetEmacsMode(toActive) {
    local iconFile := toActive ? enabledIcon : disabledIcon
    local state := toActive ? "ON" : "OFF"

    IsInEmacsMode := toActive
    ;TrayTip, Emacs Everywhere, Emacs mode is %state%, 10, 1
    Menu, Tray, Icon, %iconFile%,
    Menu, Tray, Tip, Emacs Everywhere`nEmacs mode is %state%

    ;;Send {Shift Up}
    Send, {Esc}
}

SetSelectMode(toActive){
    global IsInSelectMode
    IsInSelectMode := toActive
    OutputDebug, "SELECT MODE: " %toActive%
}

SendCommand(emacsKey, translationToWindowsKeystrokes, secondWindowsKeystroke="") {
    global IsInEmacsMode
    global IsInSelectMode

    OutputDebug, "SendCommand()"

    if(IsInSelectMode){
        translationToWindowsKeystrokes := "+" . translationToWindowsKeystrokes
    }

    processkey := FilterApps( emacsKey, translationToWindowsKeystrokes, secondWindowsKeystroke )
    if( emacsKey = "" OR processkey = "stop" ){
        OutputDebug, "emacs key = '' or process key STOP"
        return
    }

    if (IsInEmacsMode AND processkey = "ok") {
        OutputDebug, "InEmacsMode and process key = OK"
        Send, %translationToWindowsKeystrokes%
        if (secondWindowsKeystroke<>"") {
            OutputDebug, "Send second windows KeyStroke"
            Send, %secondWindowsKeystroke%
        }
    } else if( processkey = "ok") {
        OutputDebug, "Just process key OK."
        Send, %emacsKey% ;passthrough original keystroke
    }
    OutputDebug, "SendCommand() DONE"
    return
}

;+++++++++++++++++++++++++++++++++++++++++
; Gets selected text
;+++++++++++++++++++++++++++++++++++++++++

GetSelectedText()
{
    Clipboard =
    Send, ^c ; simulate Ctrl+C
    ClipWait 0.1

    sel := Clipboard

    return sel
}

#If !WinActive("ahk_group NotActiveGroup")
;==========================
;Emacs mode toggle
;==========================

#/::
SetEmacsMode(!IsInEmacsMode)
return

$^Space::
SetSelectMode(!IsInSelectMode)
return

$^z::
SetSelectMode(!IsInSelectMode)
return

$^9::
SetSelectMode(false)
SendCommand("^9","^9")
return

$^g::
if( !IsInSelectMode ){
    IfWinActive ahk_class MUSHYBAR
    {
        Send, !{F4}
    }
    IfWinActive ahk_class MozillaWindowClass
    {
        Send, {F6}
    }

    OutputDebug, "ESC"
    Send, {Esc}
}
else{
    SetSelectMode(false)
    Send, {Left}
}
return

~$^c::
SetSelectMode(false)
return

;==========================
;Character Navigation
;==========================

$<^p::SendCommand("^p","{Up}")

$<^n::SendCommand("^n","{Down}")

$<^f::SendCommand("^f","{Right}")

$<^b::SendCommand("^b","{Left}")

$>^p::SendCommand("^p","^p")

$>^n::SendCommand("^n","^n")

$>^f::SendCommand("^f","^f")

$>^b::SendCommand("^b","^b")



;==========================
;Word Navigation
;==========================

;$!p::SendCommand("!p","^{Up}")

;$!n::SendCommand("!n","^{Down}")

$!f::SendCommand("!f","^{Right}")

$!b::SendCommand("!b","^{Left}")

;==========================
;Line Navigation
;==========================

$^a::SendCommand("^a","{Home}")

$^e::SendCommand("^e","{End}")

;==========================
;Page Navigation
;==========================

;Ctrl-V disabled. Too reliant on that for pasting :$
Hotkey, IfWinActive, ahk_exe rider64.exe
$!n::SendCommand("^v","{PgDn}")
$!p::SendCommand("!v","{PgUp}")
Hotkey, IfWinActive

$^v::SendCommand("^v","{PgDn}")
$!v::SendCommand("^v","{PgUp}")

$!<::SendCommand("!<","^{Home}")
$!>::SendCommand("!>","^{End}")

;==========================
;Undo
;==========================

;$^_::SendCommand("^_","^z")
$^/::SendCommand("^/","^z")
$+^7::SendCommand("^+7","^y")


;==========================
;Killing and Deleting
;==========================
$^h::
SetSelectMode(false)
SendCommand("^h","{Backspace}")
return

$!h::
SetSelectMode(false)
SendCommand("!h","^{Backspace}")
return

$^d::
SetSelectMode(false)
SendCommand("^d","{Delete}")
return

$!d::
SetSelectMode(false)
SendCommand("!d", "^{Delete}")
return

$^k::
SetSelectMode(false)
emacskey := "^k"
processkey := FilterApps( emacskey, emacskey, "" )
if( processkey == "stop"){
    ;MsgBox "bypassed"
    return
}

selection := GetSelectedText()

if( selection <> "" ){
    ;selection exists....
    ;MsgBox "isnotempty '" . %selection%
    Send, ^x
}
else{
    ;selection is empty, delete till the end of the line
    ;MsgBox "Is empty!" .%selection%
    Send, +{End}
    Send, ^x
}

return

$^w:: ;; Cut selected text
SetSelectMode(false)

emacskey := "^k"
processkey := FilterApps( emacskey, emacskey, "" )
if( processkey == "stop"){
    ;MsgBox "bypassed"
    return
}

selection := GetSelectedText()

;selection exists....
;MsgBox "isnotempty '" . %selection%
Send, ^x
return

$!w:: ;; Copy selected text, and deselect the text
SetSelectMode(false)
selection := GetSelectedText()
;MsgBox "isnotempty '" . %selection%
Send, ^c
return

$^y::SendCommand("^y","^v") ;; Paste

;==========================
;Search
;==========================

$^s::SendCommand("^s","^f") ;find
; TODO: but, in Outlook, F3 is used for find, ^f is forward mail
$^r::SendCommand("^r","{Shift}+{F3}") ;reverse

;==========================
;Edit
;==========================

$^o::
Send, {Home}
Send, {Enter}
Send, {Up}
return

$^j::SendCommand("^j", "{Enter}")

;==========================
; File Handling Commands CTRL+X
;==========================

$^x::
Suspend, On ; other hotkeys such as ^s from being queued http://l.autohotkey.net/docs/misc/Threads.htm
Critical ; and don't interrupt (suspend) the current thread's execution

Input, RawInput, L1 M
Transform, AsciiCode, Asc, %RawInput%

;MsgBox RawInput: %RawInput%
;MsgBox AsciiCode: %AsciiCode%
;KeyHistory

if( AsciiCode <= 26 ){
    ; Check if Control+Letter, if so, boost to ascii letter.
    AsciiCode += 96
    Transform, CtrlLetter, Chr, %AsciiCode%
    Stroke = ^%CtrlLetter%
}
else{
    Stroke = %RawInput%
}

SetSelectMode(false)

; C-g		keyboard-quit		Stop current command Now!
if( Stroke = "^g" ){
    Suspend, Off
    return
}

if( Stroke = "^s" ){
    ; C-x C-s: save-buffer,	Save the current buffer.
    SendCommand("^x^s", "^s")
} else if( Stroke = "^c" ){
    ; C-x C-c: save-buffers-kill-emacs, Save all open buffers and get out of emacs.
    SendCommand("^x^c", "!{F4}" )
} else if( Stroke = "k" ) {
    ; close file
    SendCommand("^xk", "^w")
} else if( Stroke = "^f" ) {
    ; open file
    SendCommand("^x^f", "^o")
} else if( Stroke = "p" ) {
    ;; print
    SendCommand("^xp", "^p")
; } else if( Stroke = "o") {
;     ;; switch window
;     SendCommand("^xo", "!{Tab}")
} else{
    ;else pass along the emacs key
    emacsKey = ^x%Stroke%
    SendCommand(emacsKey, emacsKey)
}

Suspend, Off
return


$^q::
Suspend, On ; other hotkeys such as ^s from being queued http://l.autohotkey.net/docs/misc/Threads.htm
Critical ; and don't interrupt (suspend) the current thread's execution

Input, RawInput, L1 M
Transform, AsciiCode, Asc, %RawInput%

;MsgBox RawInput: %RawInput%
;MsgBox AsciiCode: %AsciiCode%
;KeyHistory

if( AsciiCode <= 26 ){
    ; Check if Control+Letter, if so, boost to ascii letter.
    AsciiCode += 96
    Transform, CtrlLetter, Chr, %AsciiCode%
    Stroke = ^%CtrlLetter%
}
else{
    Stroke = %RawInput%
}

SetSelectMode(false)

; C-g		keyboard-quit		Stop current command Now!
if( Stroke = "^g" ){
    Suspend, Off
    return
}

; | Char | Input     |
; |------+-----------|
; | ö    | C-q M-v   |
; | ä    | C-q M-d   |
; | å    | C-q M-e   |
; | ç    | C-q M-g   |
; | ß    | C-q M-_   |

if( Stroke = "v" ){
    Send, ö
} else if( Stroke = "e" ){
    Send, å
} else if( Stroke = "d" ){
    Send, ä
} else if( Stroke = "g" ){
    Send, ç
} else if( Stroke = "_") {
    Send, ß
} else if( Stroke = "5") {
    Send, µ
} else if( Stroke = "7") {
    Send, ·
} else if( Stroke = "g") {
    Send, ç
} else if( Stroke = "d") {
    Send, æ
} else if( Stroke = "h") {
    Send, è
} else if( Stroke = "i") {
    Send, é
} else if( Stroke = "a") {
    Send, à
} else if( Stroke = "u") {
    Send, ü
} else{
    ;else pass along the emacs key
    emacsKey = ^x%Stroke%
    SendCommand(emacsKey, emacsKey)
}

Suspend, Off
return


; switch window with Alt-o
$!o::SendCommand("!o", "!{Tab}")

#f::
Run firefox.exe
return

#g::
Run msedge.exe
return

#\::
Run "%msys64%\kimikit\shortcuts\wsl-mu4e.vbs"
return

#|::
Run "%msys64%\kimikit\shortcuts\vcxsrv.vbs"
return

#c::
Run "%msys64%\kimikit\doublecmd\doublecmd.exe"
return

#m::
; minimize the top most window
WinMinimize, A
return

#.::
Send, %A_DD%/%A_MMM%/%A_YYYY%
return

#x::
Run "%msys64%\local-emacsclient.vbs"
return

#t::
if WinExist("ahk_exe Teams.exe") and not WinActive("ahk_exe Teams.exe")
    WinActivate ; Use the window found by WinExist.
else
    WinMinimize ; Use the window found by WinExist.
return

#o::
if WinExist("ahk_exe OUTLOOK.EXE") and not WinActive("ahk_exe OUTLOOK.EXE")
    WinActivate ; Use the window found by WinExist.
else
    WinMinimize ; Use the window found by WinExist.
return


#y::
; open Yodao dict and paste
Send, ^!x
return

^m::
if WinActive("ahk_exe Teams.exe")
{
; toggle mute inside Teams
    Send, ^M
    return
}
return

Pause::
if WinActive("ahk_exe Teams.exe")
{
; toggle mute inside Teams
    Send, ^M
    return
}
return
