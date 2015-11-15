; ##################################################
; ################### DIRECTIVES ###################
; ##################################################
;@Ahk2Exe-SetName Depensa!
;@Ahk2Exe-SetDescription Fix shorcut virus
;@Ahk2Exe-SetVersion 1.0.0-alpha
;@Ahk2Exe-SetCopyright genealyson.torcende@gmail.com
;@Ahk2Exe-SetTrademarks PrivaTech -- GAFT
;@Ahk2Exe-SetOrigFilename Depensa!.ahk
;@Ahk2Exe-SetCompanyName PrivaTech -- GAFT
;@Ahk2Exe-SetMainIcon PrivaTech.ico


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
FileGetVersion, VER, %A_ScriptFullPath%
TITLE = Depensa!


; ##################################################
; ################### INITIALIZE ###################
; ##################################################
Loop, %0%
{
	param := %A_Index%
	params .= A_Space . param
}
if param contains s,S
	Menu, Tray, NoIcon
if param contains u,U
{
	MsgBox, 262180, %TITLE% v%VER%, Continue to uninstall %TITLE%?
	IfMsgBox Yes
	{
		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%
		Loop, 100
			Progress, %A_Index%, , Uninstalling..., %TITLE%
		Sleep, 500
		Run, %A_ScriptDir%
		MsgBox, 262208, %TITLE% v%VER%, Thank you for using %TITLE%`n`nPlease remove remaining files manually.
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
Menu, Tray, Tip, %TITLE% v%VER%
Menu, Tray, Add, %MenuItemShow%, ShowHide
Menu, Tray, Add
Menu, Tray, Add, About
Menu, Tray, Add, &Exit, Exit
Menu, Tray, Default, %MenuItemShow%
Menu, Tray, NoStandard
GoSub, GUI
TrayTip, %TITLE% v%VER%, Manually scan removable drives here!
DriveGet, oldList, List, REMOVABLE
Gosub, REFRESH_LIST
SetTimer, CHECK_DRIVES

#include func.ahk
#include gui.ahk
