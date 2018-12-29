GUI:
  Gui, Add, ListView, -Multi x10 y10 r5 gPROCESS_DRIVE, Drive|Label|Size(MB)
  Gui, Font, s10 Bold, Verdana
  Gui, Add, Button, x10 wp h30 gPROCESS_DRIVE vPROCESS_DRIVE Default, SCAN
  Gui, Add, Progress, x10 y+30 wp vScanProgress h15 -Smooth
  Gui, Font, s8 Bold, Verdana
  Gui, Add, Text, x10 yp-20, Scanning
  Gui, Add, Text, x75 yp, :
  Gui, Add, Text, x+10 w160 cBlue vFileScanned, %FileScanned%
  Gui, Add, Text, x10 y+30, Detected
  Gui, Add, Text, x75 yp, :
  Gui, Add, Text, x+10 w115 cRed vFilesDetected, %FilesDetected%
  Gui, Font
  LV_ModifyCol(1, "40")
  LV_ModifyCol(2, "120")
  LV_ModifyCol(3, "AutoHdr")
  Gui, -MinimizeBox -MaximizeBox
  Gui, Show, Hide
return

DRIVE_GUI:
  Gui +Disabled
  Gui, 2: +AlwaysOnTop -SysMenu
  Gui, 2: Font, s10 Bold, Verdana
  Gui, 2: Add, Text, vText cRed, Please WAIT!
  Gui, 2: Font, s8 Bold, Verdana
  Gui, 2: Add, Text, xp y+10, Scanning removable drive . . .
  Gui, 2: Add, Text, x10 y+10, Letter
  Gui, 2: Add, Text, x75 yp, :
  Gui, 2: Add, Text, x+10 cBlue, %driveLetter%
  Gui, 2: Add, Text, x10, Label
  Gui, 2: Add, Text, x75 yp, :
  Gui, 2: Add, Text, x+10 cBlue, %driveLabel%
  Gui, 2: Add, Text, x10, Capacity
  Gui, 2: Add, Text, x75 yp, :
  Gui, 2: Add, Text, x+10 cBlue, %driveSpace% MB
  Gui, 2: Add, Progress, x10 y+30 vScanProgress2 w200 h15 -Smooth
  Gui, 2: Font, s8 Bold, Verdana
  Gui, 2: Add, Text, x10 yp-20, Scanning
  Gui, 2: Add, Text, x75 yp, :
  Gui, 2: Add, Text, x+10 w130 cBlue vFileScanned2, %FileScanned%
  Gui, 2: Add, Text, x10 y+30, Detected
  Gui, 2: Add, Text, x75 yp, :
  Gui, 2: Add, Text, x+10 w80 cRed vFilesDetected, %FilesDetected%
  Gui, 2: Show, Hide
  Gui, 2: +LastFound
  WinGetPos, , , GuiWidth
  GuiControlGet, GuiInfo, 2:Pos, Text
  GuiControl, 2: Move, Text, % "x" GuiWidth/2 - GuiInfoW/2
  Gui, 2: Show, Center, %TITLE% v%VERSION%
return

ShowHide:
  Gui, 3: Destroy
  Gui -Disabled
  if Visible = y
  {
    Gui, Cancel
    Menu, Tray, Rename, %MenuItemHide%, %MenuItemShow%
    Visible = n
  }
  else
  {
    Gui, Show, Center, %TITLE% v%VERSION%
    Menu, Tray, Rename, %MenuItemShow%, %MenuItemHide%
    Visible = y
  }
return

About:
  Gui +Disabled
  Gui, 3: -MinimizeBox -MaximizeBox
  ;@Ahk2Exe-IgnoreBegin
  Gui, 3: Add, Picture, x10 y10 w32 h32 gINSTALL, %TITLE%.ico
  ;@Ahk2Exe-IgnoreEnd
  /*@Ahk2Exe-Keep
  Gui, 3: Add, Picture, x10 y10 w32 h32 gINSTALL, %A_ScriptName%
  */
  Gui, 3: Font, s12 Bold, Verdana
  Gui, 3: Add, Text, x57 y10 gLink, %TITLE% v%VERSION%
  Gui, 3: Font, s8
  Gui, 3: Add, Text, x55 y+5, By:%A_Space%
  Gui, 3: Add, Text, x+0 cBlue gLink, PrivaTech -- GAFT
  Gui, 3: Show, Center, About
return

3GuiClose:
3GuiEscape:
  Gui, 1: -Disabled
  Gui Destroy
return

Link:
  Run, https://github.com/kermage/Depensa-
return

GuiEscape:
GuiClose:
  Goto, ShowHide
return

Exit:
  ExitApp
