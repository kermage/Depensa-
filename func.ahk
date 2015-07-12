CHECK_DRIVES:
  SetTimer, CHECK_DRIVES, Off
  Gosub, REFRESH_LIST
  DriveGet, newList, List, REMOVABLE
  If (newList AND newList != oldList)
  {
    Loop, Parse, oldList
      StringReplace, newList, newList, %A_LoopField%
    If newList
      SHOW_DRIVE(newList)
  }
  DriveGet, oldList, List, REMOVABLE
  SetTimer, CHECK_DRIVES, On
return

SHOW_DRIVE( _Drive ) {
  global
  driveLetter = %_Drive%:
  DriveGet, driveLabel, Label, %_Drive%:\
  DriveGet, driveSpace, Capacity, %_Drive%:\
  GoSub, DRIVE_GUI
  SCAN_DRIVE(driveLetter, 1)
  IfExist, %driveLetter%\
    Run, %driveLetter%\
  Sleep, 1000
  Gui, 2: Destroy
  Gui -Disabled
}

SCAN_DRIVE( _Drive, which ){  
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
  FormatTime, scanTime, %A_Now%, MMddyyhhmmss
  recoveredFolder = RECOVERED - %scanTime%
  scanLogFile = %TITLE% - Scan.log
  GuiControl, Disable, PROCESS_DRIVE
  Loop, %_Drive%\*.*, 1, 1
    totCount++
  Loop, %_Drive%\*.*, 1, 1
  {
    curCount++
    posProgress := Round((100*curCount)/totCount)
    If which = 0
    {
      GuiControl, , ScanProgress, %posProgress%
      GuiControl, , FileScanned, %A_LoopFileName%
    }
    Else If which = 1
    {
      GuiControl, 2:, ScanProgress2, %posProgress%
      GuiControl, 2:, FileScanned2, %A_LoopFileName%
    }
    FileGetAttrib, fileAttribute, %A_LoopFileFullPath%
    If fileAttribute contains R,S,H
      FileSetAttrib, -%fileAttribute%, %A_LoopFileFullPath%
    StringTrimRight, blankSpace, A_LoopFileFullPath, 2
    If A_LoopFileDir = %blankSpace%
    {
      infectCount++
      recoveredFiles = %recoveredFiles%%A_LoopFileDir%\%recoveredFolder%`n
      FileMoveDir, %A_LoopFileFullPath%, %A_LoopFileDir%\%recoveredFolder%, R
    }
    If A_LoopFileName = autorun.inf
    {
      FileRead, fileContent, %A_LoopFileFullPath%
      If fileContent contains VBScript,WScript,autorun,inf,ini,lnk,vbs,bat
      {
        autorunCount++
        autorunFiles = %autorunFiles%%A_LoopFileFullPath%`n
        FileDelete, %A_LoopFileFullPath%
      }
    }
    If A_LoopFileExt = lnk
    {
      FileGetShortcut, %A_LoopFileFullPath%, outTarget, outDir, outArgs
      If OutTarget contains VBScript,WScript,autorun,inf,ini,lnk,vbs,bat
      {
        shortcutCount++
        shortcutFiles = %shortcutFiles%%A_LoopFileFullPath%`n
        FileDelete, %A_LoopFileFullPath%
      }
      If OutArgs contains VBScript,WScript,autorun,inf,ini,lnk,vbs,bat
      {
        shortcutCount++
        shortcutFiles = %shortcutFiles%%A_LoopFileFullPath%`n
        FileDelete, %A_LoopFileFullPath%
      }
    }
    IfExist, %A_LoopFileDir%\%A_LoopFileName%.lnk
    {
      shortcutCount++
      shortcutFiles = %shortcutFiles%%A_LoopFileFullPath%`n
      FileDelete, %A_LoopFileDir%\%A_LoopFileName%.lnk
    }
    detectCount := infectCount + autorunCount + shortcutCount
    If which = 0
      GuiControl, , FilesDetected, %detectCount% / %curCount%
    Else If which = 1
      GuiControl, 2:, FilesDetected, %detectCount% / %curCount%
    Sleep, 25
  }
  FileAppend, %A_Space%%A_Space%%TITLE% - Scan`n, %driveLetter%\%scanLogFile%
  FileAppend, MMddyyhhmmss %scanTime%`n`n, %driveLetter%\%scanLogFile%
  FileAppend, Scanned:`t%curCount%`n, %driveLetter%\%scanLogFile%
  If autorunCount
  {
    FileAppend, Autoruns:`t%autorunCount%`n, %driveLetter%\%scanLogFile%
    FileAppend, %autorunFiles%`n, %driveLetter%\%scanLogFile%
  }
  Else
    FileAppend, Autoruns:`tNone`n, %driveLetter%\%scanLogFile%
  If shortcutCount
  {
    FileAppend, Shortcuts:`t%shortcutCount%`n, %driveLetter%\%scanLogFile%
    FileAppend, %autorunFiles%`n, %driveLetter%\%scanLogFile%
  }
  Else
    FileAppend, Shortcuts:`tNone`n, %driveLetter%\%scanLogFile%
  If infectCount
  {
    FileAppend, Recovered:`t%infectCount%`n, %driveLetter%\%scanLogFile%
    FileAppend, %recoveredFiles%`n, %driveLetter%\%scanLogFile%
  }
  FileAppend, `n, %driveLetter%\%scanLogFile%
  Message =
  ( LTrim
    `n%A_Space% %A_Space% SCAN COMPLETE!
    
    Scanned`t. . .%A_Space% %A_Space%%curCount%
    Infected`t. . .%A_Space% %A_Space%%infectCount%
    Autoruns`t. . .%A_Space% %A_Space%%autorunCount%
    Shortcuts`t. . .%A_Space% %A_Space%%shortcutCount%
  )
  If which = 0
    GuiControl, , FileScanned, FINISHED!
  Else If which = 1
    GuiControl, 2:, FileScanned2, FINISHED!
  Gui +OwnDialogs
  MsgBox, 262208, %TITLE%, %Message%
  If which = 0
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
    ThisLetter = %A_LoopField%:
    DriveGet, ThisLabel, Label, %A_LoopField%:\
    DriveGet, ThisSize, Capacity, %A_LoopField%:\
    LV_Add("", ThisLetter, ThisLabel, ThisSize)
  }
  LV_Modify(StrLen(DL), "+Select")
return

PROCESS_DRIVE:
  SetTimer, CHECK_DRIVES, Off
  rowSelected := LV_GetNext()
  If(rowSelected = 0)
  {
    Gui +OwnDialogs
    MsgBox, 262192, %TITLE%, No drive selected
  }
  Else
  {
    LV_GetText(driveSelected, rowSelected, 1)
    SCAN_DRIVE(driveSelected, 0)
    Sleep, 500
  }
  SetTimer, CHECK_DRIVES, On
return

INSTALL:
  Gui +OwnDialogs
  If not A_IsAdmin
  {
    MsgBox, 262192, %TITLE%, Admin mode required
    return
  }
  MsgBox, 262180, %TITLE%, Install %TITLE% in Silent Mode?
  IfMsgBox Yes
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%, "%A_ScriptFullPath%" /S
  Else
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, %TITLE%, "%A_ScriptFullPath%"
  Loop, 100
    Progress, %A_Index%, , Installing..., %TITLE%
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies, NoDriveTypeAutoRun, 0x05
  FileCreateShortcut, "%A_ScriptFullPath%", %A_ScriptDir%\Uninstall.lnk, "%A_ScriptDir%", -U, , %A_ScriptFullPath%
  Sleep, 500
  MsgBox, 262208, %TITLE%, Installation Complete!`n`nPlease restart %TITLE%
  ExitApp
return
