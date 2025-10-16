#Requires AutoHotkey v2.0

appName := "Euleon"
settingsFile := A_ScriptDir "\settings.json"

logoPath := A_ScriptDir "\resources\uipack\logo.png"
gamesIcon1 := A_ScriptDir "\resources\uipack\AnimeRangersX.png"
gamesIcon2 := A_ScriptDir "\resources\uipack\bgsi.png"
iconDiscordUser := A_ScriptDir "\resources\uipack\discord_user.png"
iconDiscordServer := A_ScriptDir "\resources\uipack\discord_server.png"
iconGunsLol := A_ScriptDir "\resources\uipack\gunslol.png"

mainGui := Gui("+AlwaysOnTop -Resize", appName)
mainGui.BackColor := "F0F0F0"
mainGui.SetFont("s10", "Segoe UI")


if FileExist(logoPath)
    mainGui.AddPicture("x10 y10 w32 h32", logoPath)
mainGui.SetFont("s12 bold", "Segoe UI")
mainGui.AddText("x50 y16 cBlack", appName)
mainGui.SetFont("s10", "Segoe UI")


navX := 10, navY := 60, navW := 150, navH := 330
mainGui.AddGroupBox("x" navX " y" navY " w" navW " h" navH, "Navigation")

navItems := ["Home", "Gamemodes", "Autos", "Traits", "Settings", "Games", "Credits"]
contentControls := Map()

for index, name in navItems {
    btn := mainGui.AddButton("x" (navX + 10) " y" (navY + 30*(index-1) + 20) " w" (navW - 20) " h28", name)
    btn.OnEvent("Click", ShowPage.Bind(name))

    ctrl := mainGui.AddText("x180 y70 w320 h300 +Border cGray", name " page content.")
    ctrl.Visible := false
    contentControls[name] := ctrl
}


settingsHeader := mainGui.AddText("x180 y70 w320 Center cBlack", "Settings")
settingsHeader.Visible := false

togglePrivate := mainGui.AddCheckBox("x180 y110 w200", "Private server")
togglePrivate.Visible := true

psInput := mainGui.AddEdit("x400 y110 w120 h22")
psInput.Visible := true

toggleDarkMode := mainGui.AddCheckBox("x180 y150 w200", "Enable Dark Mode")
toggleDarkMode.Visible := true

togglePrivate.OnEvent("Click", (*) => SaveSettings())
psInput.OnEvent("Change", (*) => SaveSettings())
toggleDarkMode.OnEvent("Click", (*) => (ApplyTheme(toggleDarkMode.Value), SaveSettings()))

contentControls["Settings"] := [settingsHeader, togglePrivate, psInput, toggleDarkMode]


gamesHeader := mainGui.AddText("x180 y70 w320 Center cBlack", "Games")
gamesHeader.Visible := false

if FileExist(gamesIcon1) {
    game1 := mainGui.AddPicture("x180 y110 w96 h96", gamesIcon1)
} else {
    game1 := mainGui.AddText("x180 y110 w96 h96 cRed", "Missing: AnimeRangersX.png")
}
game1.Visible := false
game1Label := mainGui.AddText("x180 y210 w96 Center cGreen", "(Up to date)")
game1Label.Visible := false

if FileExist(gamesIcon2) {
    game2 := mainGui.AddPicture("x300 y110 w96 h96", gamesIcon2)
} else {
    game2 := mainGui.AddText("x300 y110 w96 h96 cRed", "Missing: bgsi.png")
}
game2.Visible := false
game2Label := mainGui.AddText("x300 y210 w96 Center cRed", "(Outdated)")
game2Label.Visible := false

contentControls["Games"] := [gamesHeader, game1, game1Label, game2, game2Label]


creditsHeader := mainGui.AddText("x180 y70 w320 Center cBlack", "Credits")
creditsHeader.Visible := false

picDU := mainGui.AddPicture("x180 y110 w20 h20", iconDiscordUser)
picDU.Visible := false
discordUser := mainGui.AddText("x205 y112 w320 Left", "Discord: syth.dox")
discordUser.Visible := false

picDS := mainGui.AddPicture("x180 y140 w20 h20", iconDiscordServer)
picDS.Visible := false
discordServer := mainGui.AddText("x205 y142 w320 Left cBlue", "Server: https://discord.gg/eHpGP8MnYa")
discordServer.Visible := false
discordServer.SetFont("underline")
discordServer.OnEvent("Click", (*) => Run("https://discord.gg/eHpGP8MnYa"))

picGL := mainGui.AddPicture("x180 y170 w20 h20", iconGunsLol)
picGL.Visible := false
gunsLink := mainGui.AddText("x205 y172 w320 Left cBlue", "Guns.lol: https://guns.lol/sythdox")
gunsLink.Visible := false
gunsLink.SetFont("underline")
gunsLink.OnEvent("Click", (*) => Run("https://guns.lol/sythdox"))

contentControls["Credits"] := [creditsHeader, picDU, discordUser, picDS, discordServer, picGL, gunsLink]


ApplyTheme(isDarkMode) {
    global mainGui, contentControls

    bg := isDarkMode ? "1E1E1E" : "F0F0F0"
    text := isDarkMode ? "White" : "Black"

    mainGui.BackColor := bg

    for _, ctrl in contentControls {
        if Type(ctrl) == "Array" {
            for item in ctrl {
                try item.SetFont("", "", text)
            }
        } else {
            try ctrl.SetFont("", "", text)
        }
    }
}


ShowPage(name*) {
    global contentControls
    thisTab := name[1]

    for _, controls in contentControls {
        if Type(controls) == "Array" {
            for ctrl in controls
                ctrl.Visible := false
        } else {
            controls.Visible := false
        }
    }

    if Type(contentControls[thisTab]) == "Array" {
        for ctrl in contentControls[thisTab]
            ctrl.Visible := true
    } else {
        contentControls[thisTab].Visible := true
    }
}


LoadSettings() {
    global togglePrivate, psInput, toggleDarkMode, settingsFile

    if !FileExist(settingsFile)
        return

    raw := FileRead(settingsFile)
    if !raw or InStr(raw, "{") = 0
        return

    try {
        enabled := InStr(raw, '"privateServerEnabled": true') ? true : false
        code := ""
        if RegExMatch(raw, '"privateServerCode"\s*:\s*"([^"]*)"', &found)
            code := found[1]

        dark := InStr(raw, '"darkMode": true') ? true : false

        togglePrivate.Value := enabled
        psInput.Text := code
        toggleDarkMode.Value := dark
        ApplyTheme(dark)
    } catch Error as e {
        MsgBox "Error loading settings: " e.Message
    }
}

SaveSettings() {
    global togglePrivate, psInput, toggleDarkMode, settingsFile

    enabled := togglePrivate.Value ? "true" : "false"
    dark := toggleDarkMode.Value ? "true" : "false"
    code := psInput.Text

    json := "{`n"
    json .= '  "privateServerEnabled": ' enabled ",`n"
    json .= '  "privateServerCode": "' StrReplace(code, '"', '\"') '",' "`n"
    json .= '  "darkMode": ' dark "`n"
    json .= "}"

    if FileExist(settingsFile)
        FileDelete settingsFile

    FileAppend json, settingsFile
}


mainGui.Show("w540 h440")
LoadSettings()
ShowPage("Home")

