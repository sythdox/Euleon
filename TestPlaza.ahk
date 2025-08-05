#Requires AutoHotkey v2.0

mainGui := Gui()
mainGui.Title := "Euleon Settings"
mainGui.SetFont("s10", "Segoe UI")

; Add the "Always on Top" toggle checkbox
toggleTopUI := mainGui.AddCheckBox("x20 y20 w200", "Always on Top")

; Proper event handler using WinSetAlwaysOnTop (correct function in v2)
toggleTopUI.OnEvent("Click", (*) => (
    WinSetAlwaysOnTop(toggleTopUI.Value, mainGui.Hwnd)
))

mainGui.Show("w300 h100")
