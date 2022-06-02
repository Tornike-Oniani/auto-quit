#RequireAdmin
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ImageSearch.au3>

; Enable GUI events
Opt("GUIOnEventMode", 1)

; Declare all variables to be used (Handy if we want to set option that allows only declared variables to be used)
Global $seconds = 0, $g_sec, $g_min, $g_hr, $started = False, $sec = 99, $aTimeHold[3], $sCfgFilename = "config.ini", $X = 0, $Y = 0

#Region ### START Koda GUI section ###
Global $Form1 = GUICreate("AutoQuit", 250, 90, -1, -1)
Global $idHour = GUICtrlCreateInput("00", 5, 4, 49, 32, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
Global $idMin = GUICtrlCreateInput("00", 58, 4, 49, 32, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
Global $idSec = GUICtrlCreateInput("00", 110, 4, 49, 32, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
Global $idStart = GUICtrlCreateButton("Start Timer", 163, 6, 75, 61, $BS_MULTILINE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Set font styling to GUI
GUICtrlSetFont($idHour, 14, 800)
GUICtrlSetFont($idMin, 14, 800)
GUICtrlSetFont($idSec, 14, 800)
GUICtrlSetFont($idStart, 12, 800)
; Limit time inputs to 2 digits
GUICtrlSetLimit($idHour, 2)
GUICtrlSetLimit($idMin, 2)
GUICtrlSetLimit($idSec, 2)
; Set time from previous session
setTimeFromConfig()

; Set up GUI events
GUISetOnEvent($GUI_EVENT_CLOSE, "Form1Close")
GUICtrlSetOnEvent($idStart, "idStartClick")

While 1
    Sleep(50)
    If Not $started Then ContinueLoop
	; Wait until next second
    If $sec = @SEC Then ContinueLoop
    $sec = @SEC
    Countdown()
WEnd

Func Form1Close()
	saveTimeToConfig()
	GUIDelete()
	Exit
EndFunc   ;==>Form1Close

Func Countdown()
    $g_sec = Mod($seconds, 60)
    $g_min = Mod($seconds / 60, 60)
    $g_hr = Floor($seconds / 60 ^ 2)
    $seconds -= 1
	; If timer is up do action
    If $seconds < -1 Then
		action()
		idStartClick()
		Return
	EndIf
    GUICtrlSetData($idHour, StringFormat("%02i", $g_hr))
    GUICtrlSetData($idMin, StringFormat("%02i", $g_min))
    GUICtrlSetData($idSec, StringFormat("%02i", $g_sec))
EndFunc   ;==>Countdown


Func idStartClick()
    $sec = 99
    $started = Not $started
    Switch $started
        Case True
            GUICtrlSetData($idStart, StringReplace(GUICtrlRead($idStart), "Start", "STOP"))
            $seconds = (Int(GUICtrlRead($idHour)) * 60 * 60) + (Int(GUICtrlRead($idMin)) * 60) + Int(GUICtrlRead($idSec))
            $aTimeHold[0] = StringFormat("%02i", GUICtrlRead($idHour))
            $aTimeHold[1] = StringFormat("%02i", GUICtrlRead($idMin))
            $aTimeHold[2] = StringFormat("%02i", GUICtrlRead($idSec))
            GUICtrlSetState($idStart, $GUI_FOCUS)
            GUICtrlSetState($idHour, $GUI_DISABLE)
            GUICtrlSetState($idMin, $GUI_DISABLE)
            GUICtrlSetState($idSec, $GUI_DISABLE)
        Case Else
            GUICtrlSetData($idStart, StringReplace(GUICtrlRead($idStart), "STOP", "Start"))
            GUICtrlSetData($idHour, $aTimeHold[0])
            GUICtrlSetData($idMin, $aTimeHold[1])
            GUICtrlSetData($idSec, $aTimeHold[2])
            GUICtrlSetState($idHour, $GUI_ENABLE)
            GUICtrlSetState($idMin, $GUI_ENABLE)
            GUICtrlSetState($idSec, $GUI_ENABLE)
            GUICtrlSetState($idStart, $GUI_FOCUS)
    EndSwitch
EndFunc   ;==>idStartClick

Func action()
	WinActivate('Logitech® Webcam Software')
	Sleep(5000)
	$Search = _ImageSearch('search.bmp', 1, $X, $Y, 0)
	If $Search = 1 Then
		MouseClick('Left', $X, $Y, 1, 10)
	Else
		MsgBox(0, "Error", "Button was not found")
	EndIf
	Sleep(5000)
	; Wait until program saves the file
	waitForImage()
	Sleep(5000)
	; Close logitech software
	WinClose('Logitech® Webcam Software')
	Sleep(5000)
	; Shutdown computer
	Shutdown(1)
EndFunc

Func setTimeFromConfig()
	$aTimeHold[0] = StringFormat("%02i", IniRead($sCfgFilename, "Duration", "hour", 0))
	$aTimeHold[1] = StringFormat("%02i", IniRead($sCfgFilename, "Duration", "minute", 0))
	$aTimeHold[2] = StringFormat("%02i", IniRead($sCfgFilename, "Duration", "second", 0))
	GUICtrlSetData($idHour, $aTimeHold[0])
	GUICtrlSetData($idMin, $aTimeHold[1])
	GUICtrlSetData($idSec, $aTimeHold[2])
EndFunc

Func saveTimeToConfig()
	IniWrite($sCfgFilename, "Duration", "hour", $aTimeHold[0])
	IniWrite($sCfgFilename, "Duration", "minute", $aTimeHold[1])
	IniWrite($sCfgFilename, "Duration", "second", $aTimeHold[2])
EndFunc

Func waitForImage()
	$Search = _ImageSearch('wait.bmp', 1, $X, $Y, 0)
	While $Search <> 1
		Sleep(400)
		$Search = _ImageSearch('wait.bmp', 1, $X, $Y, 0)
	WEnd
EndFunc