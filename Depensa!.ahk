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
; ##################### CONFIG #####################
; ##################################################
#MaxThreads 20
#NoEnv
#Persistent
#SingleInstance force

Process, Priority,, High 
SendMode Input
SetBatchLines, -1
SetKeyDelay, -1
SetTitleMatchMode, 2
SetTitleMatchMode, Slow
SetTitleMatchMode, RegEx


; ##################################################
; ################### INITIALIZE ###################
; ##################################################
SetWorkingDir %A_ScriptDir%
;@Ahk2Exe-IgnoreBegin
VERSION := "1.0.0.0"
;@Ahk2Exe-IgnoreEnd
/*@Ahk2Exe-Keep
FileGetVersion, VERSION, %A_ScriptFullPath%
*/
TITLE = Depensa!

param := %0%
if (param = "/S")
	Menu, Tray, NoIcon
if (param = "-U")
{
	MsgBox, 262180, %TITLE% v%VERSION%, Continue to uninstall %TITLE%?
	IfMsgBox Yes
	{
		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%
		Loop, 100
			Progress, %A_Index%, , Uninstalling..., %TITLE%
		Sleep, 500
		Run, %A_ScriptDir%
		MsgBox, 262208, %TITLE% v%VERSION%, Thank you for using %TITLE%`n`nPlease remove remaining files manually.
	}
	ExitApp
}


; ##################################################
; ###################### MAIN ######################
; ##################################################
Visible = n
MenuItemHide = Hide
MenuItemShow = Show
;@Ahk2Exe-IgnoreBegin
Menu, Tray, Icon, PrivaTech.ico
;@Ahk2Exe-IgnoreEnd
/*@Ahk2Exe-Keep
Menu, Tray, Icon, %A_ScriptFullPath%
*/
Menu, Tray, Tip, %TITLE% v%VERSION%
Menu, Tray, Add, %MenuItemShow%, ShowHide
Menu, Tray, Add
Menu, Tray, Add, About
Menu, Tray, Add, &Exit, Exit
Menu, Tray, Default, %MenuItemShow%
Menu, Tray, NoStandard
GoSub, GUI
TrayTip, %TITLE% v%VERSION%, Manually scan removable drives here!
DriveGet, oldList, List, REMOVABLE
Gosub, REFRESH_LIST
SetTimer, CHECK_DRIVES

return ; =========== END OF AUTO EXECUTE ===========


; ##################################################
; #################### INCLUDES ####################
; ##################################################

#include func.ahk
#include gui.ahk
