-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

-- AHK has case insensitive grammer
local variables = {
  "A_AhkPath", "A_AhkVersion", "A_AppData", "A_AppDataCommon", "A_AutoTrim", 
  "A_BatchLines", "A_CaretX", "A_CaretY", "A_Computername", "A_ControlDelay", 
  "A_Cursor", "A_DD", "A_DDD", "A_DDDD", "A_DefaultMouseSpeed", 
  "A_Desktop", "A_Desktopcommon", "A_Detecthiddentext", "A_Detecthiddenwindows", "A_Endchar", 
  "A_EventInfo", "A_ExitReason", "A_FileEncoding", "A_FormatFloat", "A_FormatInteger", 
  "A_Gui", "A_GuiControl", "A_GuiControlEvent", "A_GuiEvent", "A_GuiHeight", 
  "A_GuiWidth", "A_GuiX", "A_GuiY", "A_Hour", "A_IconFile", 
  "A_IconHidden", "A_IconNumber", "A_IconTip", "A_Index", "A_IpAddress1", 
  "A_IpAddress2", "A_IpAddress3", "A_IpAddress4", "A_Is64bitOS", "A_IsAdmin", 
  "A_IsCompiled", "A_IsCritical", "A_IsPaused", "A_IsSuspended", "A_IsUnicode", 
  "A_KeyDelay", "A_Language", "A_LastError", "A_LineFile", "A_LineNumber", 
  "A_LoopField", "A_LoopFileAttrib", "A_LoopFileDir", "A_LoopFileExt", "A_LoopFileFullPath", 
  "A_LoopFileLongPath", "A_LoopFileName", "A_LoopFileShortName", "A_LoopFileShortPath", "A_LoopFileSize", 
  "A_LoopFileSizeKB", "A_LoopFileSizeMB", "A_LoopFileTimeAccessed", "A_LoopFileTimeCreated", "A_LoopFileTimeModified", 
  "A_LoopReadLine", "A_LoopRegKey", "A_LoopRegName", "A_LoopRegSubKey", "A_LoopRegTimeModified", 
  "A_LoopRegType", "A_MDay", "A_Min", "A_MM", "A_MMM", 
  "A_MMMM", "A_Mon", "A_MouseDelay", "A_MSec", "A_MyDocuments", 
  "A_Now", "A_NowUTC", "A_NumBatchLines", "A_OSType", "A_OSVersion", 
  "A_PriorHotkey", "A_PriorKey", "A_ProgramFiles", "A_Programs", "A_ProgramsCommon", 
  "A_PtrSize", "A_RegView", "A_ScreenDpi", "A_ScreenHeight", "A_ScreenWidth", 
  "A_ScriptDir", "A_ScriptFullPath", "A_ScriptHwnd", "A_ScriptName", "A_Sec", 
  "A_Space", "A_StartMenu", "A_StartMenuCommon", "A_StartUp", "A_StartUpCommon", 
  "A_StringCaseSense", "A_Tab", "A_Temp", "A_ThisFunc", "A_ThisHotkey", 
  "A_ThisLabel", "A_ThisMenu", "A_ThisMenuItem", "A_ThisMenuItemPos", "A_TickCount", 
  "A_TimeIdle", "A_TimeIdlePhysical", "A_TimeSincePriorHotkey", "A_TimeSinceThisHotkey", "A_TitleMatchMode", 
  "A_TitleMatchModeSpeed", "A_UserName", "A_WDay", "A_WinDelay", "A_WinDir", 
  "A_WorkingDir", "A_YDay", "A_Year", "A_YWeek", "A_YYYY", 
  "CipboardAll", "Clipboard", "ComSpec", "ErrorLevel", "False", 
  "ProgramFiles", "True", 
}

local keywords = {
  "Break", "ByRef", "Case", "Catch", "Class", 
  "Continue", "Else", "Else", "Exit", "ExitApp", 
  "Finally", "For", "Global", "Gosub", "Goto", 
  "If", "Local", "Loop", "OnExit", "Pause", 
  "Return", "Sleep", "static", "suspend", "Switch", 
  "Throw", "Try", "Until", "While",
}

local functions = {
  "_NewEnum", "Abs", "ACos", "Array", "Asc", 
  "ASin", "ATan", "Ceil", "Chr", "ComObjActive", 
  "ComObjArray", "ComObjConnect", "ComObjCreate", "ComObject", "ComObjError", 
  "ComObjFlags", "ComObjGet", "ComObjQuery", "ComObjType", "ComObjValue", 
  "Cos", "DllCall", "Exception", "Exp", "FileExist", 
  "FileOpen", "Floor", "Format", "Func", "GetKeyName", 
  "GetKeySC", "GetKeyState", "GetKeyVK", "IL_Add", "IL_Create", 
  "IL_Destroy", "InStr", "IsByRef", "IsFunc", "IsLabel", 
  "IsObject", "Ln", "Log", "LTrim", "LV_Add", 
  "LV_Delete", "LV_DeleteCol", "LV_GetCount", "LV_GetNext", "LV_GetText", 
  "LV_Insert", "LV_InsertCol", "LV_Modify", "LV_ModifyCol", "LV_SetImageList", 
  "Mod", "NumGet", "NumPut", "ObjAddRef", "ObjClone", 
  "Object", "ObjGetAddress", "ObjGetCapacity", "ObjHasKey", "ObjInsert", 
  "ObjMaxIndex", "ObjMinIndex", "ObjNewEnum", "ObjRelease", "ObjRemove", 
  "ObjSetCapacity", "OnMessage", "RegExMatch", "RegExReplace", "RegisterCallback", 
  "Round", "RTrim", "SB_SetIcon", "SB_SetParts", "SB_SetText", 
  "Sin", "Sqrt", "StrGet", "StrLen", "StrPut", 
  "StrReplace", "StrSplit", "SubStr", "Tan", "Trim", 
  "TV_Add", "TV_Delete", "TV_Get", "TV_GetChild", "TV_GetCount", 
  "TV_GetNext", "TV_GetParent", "TV_GetPrev", "TV_GetSelection", "TV_GetText", 
  "TV_Modify", "TV_SetImageList", "VarSetCapacity", "WinActive", "WinExist",
}

local commands = {
  "AutoTrim", "BlockInput", "Click", "ClipWait", "Control", 
  "ControlClick", "ControlFocus", "ControlGet", "ControlGetFocus", "ControlGetPos", 
  "ControlGetText", "ControlMove", "ControlSend", "ControlSendRaw", "ControlSetText", 
  "CoordMode", "Critical", "DetectHiddenText", "DetectHiddenWindows", "Drive", 
  "DriveGet", "DriveSpaceFree", "Edit", "EnvAdd", "EnvGet", 
  "EnvSet", "EnvSub", "EnvUpdate", "FileAppend", "FileCopy", 
  "FileCopyDir", "FileCreateDir", "FileCreateShortcut", "FileDelete", "FileEncoding", 
  "FileGetAttrib", "FileGetShortcut", "FileGetSize", "FileGetTime", "FileGetVersion", 
  "FileInstall", "FileMove", "FileMoveDir", "FileRead", "FileReadLine", 
  "FileRecycle", "FileRecycleEmpty", "FileRemoveDir", "FileSelectFile", "FileSelectFolder", 
  "FileSetAttrib", "FileSetTime", "FormatTime", "GroupActivate", "GroupAdd", 
  "GroupClose", "GroupDeactivate", "Gui", "GuiControl", "GuiControlGet", 
  "Hotkey", "ImageSearch", "IniDelete", "IniRead", "IniWrite", 
  "Input", "InputBox", "KeyHistory", "KeyWait", "ListHotkeys", 
  "ListLines", "ListVars", "Menu", "MouseClick", "MouseClickDrag", 
  "MouseGetPos", "MouseMove", "MsgBox", "OutputDebug", "PixelGetColor", 
  "PixelSearch", "PostMessage", "Process", "Random", "RegDelete", 
  "RegRead", "RegWrite", "Reload", "Run", "RunAs", 
  "RunWait", "Send", "SendEvent", "SendInput", "SendLevel", 
  "SendMessage", "SendMode", "SendPlay", "SendRaw", "SetBatchLines", 
  "SetCapsLockState", "SetControlDelay", "SetDefaultMouseSpeed", "SetEnv", "SetKeyDelay", 
  "SetMouseDelay", "SetNumLockState", "SetRegView", "SetScrollLockState", "SetStoreCapsLockMode", 
  "SetTimer", "SetTitleMatchMode", "SetWinDelay", "SetWorkingDir", "Shutdown", 
  "Sort", "SoundBeep", "SoundGet", "SoundGetWaveVolume", "SoundPlay", 
  "SoundSet", "SoundSetWaveVolume", "Splitpath", "StatusBarGetText", "StatusBarWait", 
  "StringCaseSense", "StringLower", "StringUpper", "SysGet", "Thread", 
  "ToolTip", "Transform", "TrayTip", "UrlDownloadToFile", "WinActivate", 
  "WinActivateBottom", "WinClose", "WinGet", "WinGetActiveStats", "WinGetActiveTitle", 
  "WinGetClass", "WinGetPos", "WinGetText", "WinGetTitle", "WinHide", 
  "WinKill", "WinMaximize", "WinMenuSelectItem", "WinMinimize", "WinMinimizeAll", 
  "WinMinimizeAllUndo", "WinMove", "WinRestore", "WinSet", "WinSetTitle", 
  "WinShow", "WinWait", "WinWaitActive", "WinWaitClose", "WinWaitNotActive",
}

local symbols = {}
for _, elementVar in ipairs(variables) do
  symbols[string.lower(elementVar)] = "operator" --a_year
  symbols[string.upper(elementVar)] = "operator" --A_YEAR
  symbols[string.format("%s%s", string.sub(elementVar, 1, 1), string.lower(string.sub(elementVar, 2)))] = "operator" --A_year
  symbols[elementVar] = "operator" --A_Year
end

for _, elementKeyword in ipairs(keywords) do
  symbols[string.lower(elementKeyword)] = "function" --byref
  symbols[string.upper(elementKeyword)] = "function" --BYREF
  symbols[string.format("%s%s", string.sub(elementKeyword, 1, 1), string.lower(string.sub(elementKeyword, 2)))] = "function" --Byref
  symbols[elementKeyword] = "function" --ByRef
end

for _, elementFunction in ipairs(functions) do
  symbols[string.lower(elementFunction)] = "keyword2" --lv_modifycol()
  symbols[string.upper(elementFunction)] = "keyword2" --LV_MODIFYCOL()
  symbols[string.format("%s%s", string.sub(elementFunction, 1, 1), string.lower(string.sub(elementFunction, 2)))] = "keyword2" --Lv_modifycol()
  symbols[elementFunction] = "keyword2" --LV_ModifyCol()
end

for _, elementCommands in ipairs(commands) do
  symbols[string.lower(elementCommands)] = "keyword" --fileencoding
  symbols[string.upper(elementCommands)] = "keyword" --FILEENCODING
  symbols[string.format("%s%s", string.sub(elementCommands, 1, 1), string.lower(string.sub(elementCommands, 2)))] = "keyword" --Fileencoding
  symbols[elementCommands] = "keyword" --FileEncoding
end

syntax.add {
  name = "AutoHotkey",
  files = { "%.ahk$"},
  comment = ";",
  patterns = {
    { pattern = { ";", "\n" },                  type = "comment"  },
    { pattern = { "/%*", "*%/" },               type = "comment"  },
    { pattern = { "[ruU]?%%", "[%% ]", '\\' },  type = "operator" },
    { pattern = { "[ruU]?%%", "[ ,]", '\\' },   type = "normal"   },
    { pattern = { '[ruU]?"""', '"""'; '\\' },   type = "string"   },
    { pattern = { '[ruU]?"', '"', '\\' },       type = "string"   },
    { pattern = "0x[%da-fA-F]+",                type = "number"   },
    { pattern = "-?%d+[%d%.eE]*",               type = "number"   },
    { pattern = "-?%.?%d+",                     type = "number"   },
    { pattern = "[%+%-=/%*%^<>!~|&]",           type = "operator" },
    { pattern = ":=",                           type = "operator" },
    { pattern = ".=",                           type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",             type = "function" },
    { pattern = "[%a_][%w_]*",                  type = "symbol"   },
  },
  symbols = symbols,  
}
