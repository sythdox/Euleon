#Requires AutoHotkey v2.0

mainGui := Gui()
mainGui.Title := "Euleon Settings"
mainGui.SetFont("s10", "Segoe UI")


toggleTopUI := mainGui.AddCheckBox("x20 y20 w200", "Always on Top")


toggleTopUI.OnEvent("Click", (*) => (
    WinSetAlwaysOnTop(toggleTopUI.Value, mainGui.Hwnd)
))

mainGui.Show("w300 h100")

