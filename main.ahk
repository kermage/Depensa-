; ##################################################
; ################### PARAMETERS ###################
; ##################################################
#NoEnv
#SingleInstance force
#Persistent
#MaxThReads 20

SendMode Input
SetWorkingDir %A_ScriptDir%
Process, priority, , High 
SetBatchLines, -1
SetTitleMatchMode, 2
SetTitleMatchMode, Slow
FileGetVersion, LVER, %A_ScriptFullPath%
StringLeft,VER,LVER,3
TITLE = Depensa! v%VER%0


; ##################################################
; ################### INITIALIZE ###################
; ##################################################
Loop, %0%
{
	param := %A_Index%
	params .= A_Space . param
}
If param contains s,S
	Menu, Tray, NoIcon
If param contains u,U
{
	MsgBox, 262180, %TITLE%, Continue to uninstall %TITLE%?
	IfMsgBox Yes
	{
		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%
		Loop, 100
			Progress, %A_Index%, , Uninstalling..., %TITLE%
		Sleep, 500
		Run, %A_ScriptDir%
		MsgBox, 262208, %TITLE%, Thank you for using %TITLE%`n`nPlease remove remaining files manually.
	}
	ExitApp
}


; ##################################################
; ###################### MAIN ######################
; ##################################################
Visible = n
MenuItemHide = Hide
MenuItemShow = Show
Menu, Tray, Icon, %A_ScriptFullPath%
Menu, Tray, Tip, %TITLE%
Menu, Tray, Add, %MenuItemShow%, ShowHide
Menu, Tray, Add
Menu, Tray, Add, About
Menu, Tray, Add, &Exit, Exit
Menu, Tray, Default, %MenuItemShow%
Menu, Tray, NoStandard
GoSub, GUI
TrayTip, %TITLE%, Manually scan removable drives here!
DriveGet, oldList, List, REMOVABLE
SetTimer, CHECK_DRIVES

#include func.ahk
#include gui.ahk
