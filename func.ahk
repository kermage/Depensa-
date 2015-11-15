CHECK_DRIVES:
  SetTimer, CHECK_DRIVES, Off
  DriveGet, newList, List, REMOVABLE
  if (newList AND newList != oldList)
  {
    Gosub, REFRESH_LIST
    Loop, Parse, oldList
      StringReplace, newList, newList, %A_LoopField%
    if newList
      SHOW_DRIVE(newList)
  }
  DriveGet, oldList, List, REMOVABLE
  SetTimer, CHECK_DRIVES, On
return

SHOW_DRIVE( _Drive ) {
  global
  driveLetter = %_Drive%:\
  DriveGet, driveLabel, Label, %_Drive%:\
  DriveGet, driveSpace, Capacity, %_Drive%:\
  GoSub, DRIVE_GUI
  SCAN_DRIVE(_Drive, 1)
  IfExist, %_Drive%:\
    Run, %_Drive%:\
  Sleep, 1000
  Gui, 2: Destroy
  Gui -Disabled
}

SCAN_DRIVE( _Drive, which ) {
  global TITLE
  infectCount = 0
  autorunCount = 0
  shortcutCount = 0
  totCount = 0
  detectCount = 0
  curCount = 0
  FileScanned =
  FilesDetected =
  ScanProgress =
  FormatTime, scanTime, %A_Now%, MMddyyhhmm
  recoveredFolder = RECOVERED - %scanTime%
  infectedFolder = INFECTED - %scanTime%
  scanLogFile = %TITLE% - Scan.log
  GuiControl, Disable, PROCESS_DRIVE
  Loop, %_Drive%:\*.*, 1, 1
  {
    if A_LoopFileFullPath contains System Volume Information,Desktop.ini,Thumbs.db,%scanLogFile%,RECOVERED,INFECTED
      continue
    totCount++
  }
  Loop, %_Drive%:\*.*, 1, 1
  {
    if A_LoopFileFullPath contains System Volume Information,Desktop.ini,Thumbs.db,%scanLogFile%,RECOVERED,INFECTED
      continue
    curCount++
    posProgress := Round((100*curCount)/totCount)
    if which = 0
    {
      GuiControl, , ScanProgress, %posProgress%
      GuiControl, , FileScanned, %A_LoopFileName%
    }
    else if which = 1
    {
      GuiControl, 2:, ScanProgress2, %posProgress%
      GuiControl, 2:, FileScanned2, %A_LoopFileName%
    }
    FileGetAttrib, fileAttribute, %A_LoopFileFullPath%
    if fileAttribute contains R,S,H
      FileSetAttrib, -%fileAttribute%, %A_LoopFileFullPath%
    StringTrimRight, blankSpace, A_LoopFileFullPath, 2
    if A_LoopFileDir = %blankSpace%
    {
      infectCount++
      recoveredFiles = %recoveredFiles%`t%A_LoopFileDir%\%recoveredFolder%`n
      FileMoveDir, %A_LoopFileFullPath%, %A_LoopFileDir%\%recoveredFolder%, R
    }
    if A_LoopFileName = autorun.inf
    {
      FileRead, fileContent, %A_LoopFileFullPath%
      if fileContent contains VBScript,WScript,autorun,inf,ini,lnk,vbs,bat
      {
        autorunCount++
        autorunFiles = %autorunFiles%`t%A_LoopFileFullPath%`n
        IfNotExist, %infectedFolder%
          FileCreateDir, %A_LoopFileDir%\%infectedFolder%
        FileMove, %A_LoopFileFullPath%, %A_LoopFileDir%\%infectedFolder%
      }
    }
    if A_LoopFileExt = lnk
    {
      FileGetShortcut, %A_LoopFileFullPath%, outTarget, outDir, outArgs
      if OutTarget contains VBScript,WScript,autorun,inf,ini,lnk,vbs,bat
      {
        shortcutCount++
        shortcutFiles = %shortcutFiles%`t%A_LoopFileFullPath%`n
        IfNotExist, %infectedFolder%
          FileCreateDir, %A_LoopFileDir%\%infectedFolder%
        FileMove, %A_LoopFileFullPath%, %A_LoopFileDir%\%infectedFolder%
      }
      if OutArgs contains VBScript,WScript,autorun,inf,ini,lnk,vbs,bat
      {
        shortcutCount++
        shortcutFiles = %shortcutFiles%`t%A_LoopFileFullPath%`n
        IfNotExist, %infectedFolder%
          FileCreateDir, %A_LoopFileDir%\%infectedFolder%
        FileMove, %A_LoopFileFullPath%, %A_LoopFileDir%\%infectedFolder%
      }
    }
    IfExist, %A_LoopFileDir%\%A_LoopFileName%.lnk
    {
      shortcutCount++
      shortcutFiles = %shortcutFiles%`t%A_LoopFileFullPath%`n
      IfNotExist, %infectedFolder%
        FileCreateDir, %A_LoopFileDir%\%infectedFolder%
      FileMove, %A_LoopFileDir%\%A_LoopFileName%.lnk, %A_LoopFileDir%\%infectedFolder%
    }
    detectCount := infectCount + autorunCount + shortcutCount
    if which = 0
      GuiControl, , FilesDetected, %detectCount% / %curCount%
    else if which = 1
      GuiControl, 2:, FilesDetected, %detectCount% / %curCount%
  }
  FileAppend, ===================================`n, %_Drive%:\%scanLogFile%
  FileAppend, Time`t`t:`t%scanTime%`n, %_Drive%:\%scanLogFile%
  FileAppend, Scanned`t`t:`t%curCount%`n`n, %_Drive%:\%scanLogFile%
  if autorunCount
  {
    FileAppend, Autoruns`t`t:`t%autorunCount%`n, %_Drive%:\%scanLogFile%
    FileAppend, `t%autorunFiles%`n, %_Drive%:\%scanLogFile%
  }
  else
    FileAppend, Autoruns`t`t:`tNone`n`n, %_Drive%:\%scanLogFile%
  if shortcutCount
  {
    FileAppend, Shortcuts`t`t:`t%shortcutCount%`n, %_Drive%:\%scanLogFile%
    FileAppend, `t%shortcutFiles%`n, %_Drive%:\%scanLogFile%
  }
  else
    FileAppend, Shortcuts`t`t:`tNone`n`n, %_Drive%:\%scanLogFile%
  if infectCount
  {
    FileAppend, Recovered`t:`t%infectCount%`n, %_Drive%:\%scanLogFile%
    FileAppend, `t%recoveredFiles%`n, %_Drive%:\%scanLogFile%
  }
  FileAppend, ===================================`n, %_Drive%:\%scanLogFile%
  Message =
  ( LTrim
    `n%A_Space% %A_Space% SCAN COMPLETE!
    
    Scanned`t. . .%A_Space% %A_Space%%curCount%
    Infected`t. . .%A_Space% %A_Space%%infectCount%
    Autoruns`t. . .%A_Space% %A_Space%%autorunCount%
    Shortcuts`t. . .%A_Space% %A_Space%%shortcutCount%
  )
  if which = 0
    GuiControl, , FileScanned, FINISHED!
  else if which = 1
    GuiControl, 2:, FileScanned2, FINISHED!
  Gui +OwnDialogs
  MsgBox, 262208, %TITLE% v%VER%, %Message%
  if which = 0
  {
    GuiControl, , ScanProgress, 0
    GuiControl, , FileScanned,
    GuiControl, , FilesDetected,
  }
  GuiControl, Enable, PROCESS_DRIVE
}

REFRESH_LIST:
  LV_Delete()
  DriveGet, DL, List, REMOVABLE
  Loop, Parse, DL
  {
    DriveGet, ThisLabel, Label, %A_LoopField%:\
    DriveGet, ThisSize, Capacity, %A_LoopField%:\
    LV_Add("", A_LoopField, ThisLabel, ThisSize)
  }
  LV_Modify(StrLen(DL), "+Select")
return

PROCESS_DRIVE:
  SetTimer, CHECK_DRIVES, Off
  rowSelected := LV_GetNext()
  if rowSelected = 0
  {
    if A_GuiEvent != ColClick
    {
      Gui +OwnDialogs
      MsgBox, 262192, %TITLE% v%VER%, No drive selected
    }
  }
  else
  {
    LV_GetText(driveSelected, rowSelected, 1)
    if A_GuiEvent != ColClick
    {
      SCAN_DRIVE(driveSelected, 0)
      Sleep, 500
    }
  }
  SetTimer, CHECK_DRIVES, On
return

INSTALL:
  Gui +OwnDialogs
  if not A_IsAdmin
  {
    MsgBox, 262192, %TITLE% v%VER%, Admin mode required
    return
  }
  MsgBox, 262180, %TITLE% v%VER%, Install %TITLE% in Silent Mode?
  IfMsgBox Yes
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%, "%A_ScriptFullPath%" /S
  else
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%, "%A_ScriptFullPath%"
  Loop, 100
    Progress, %A_Index%, , Installing..., %TITLE%
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies, NoDriveTypeAutoRun, 0x05
  FileCreateShortcut, "%A_ScriptFullPath%", %A_ScriptDir%\Uninstall.lnk, "%A_ScriptDir%", -U, , %A_ScriptFullPath%
  Sleep, 500
  MsgBox, 262208, %TITLE% v%VER%, Installation Complete!`n`nPlease restart %TITLE%
  ExitApp
return
