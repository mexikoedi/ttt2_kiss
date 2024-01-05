CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.priority = 0
CLGAMEMODESUBMENU.title = "submenu_addons_kiss_title"
function CLGAMEMODESUBMENU:Populate(parent)
    local form = vgui.CreateTTT2Form(parent, "header_addons_kiss")
    form:MakeCheckBox({
        serverConvar = "ttt2_kiss_prepare_sound",
        label = "label_kiss_prepare_sound"
    })

    form:MakeCheckBox({
        serverConvar = "ttt2_kiss_primary_sound",
        label = "label_kiss_primary_sound"
    })

    form:MakeCheckBox({
        serverConvar = "ttt2_kiss_secondary_sound",
        label = "label_kiss_secondary_sound"
    })

    form:MakeSlider({
        serverConvar = "ttt2_kiss_damage",
        label = "label_kiss_damage",
        min = -100,
        max = 100,
        decimal = 0
    })

    form:MakeSlider({
        serverConvar = "ttt2_kiss_ammo",
        label = "label_kiss_ammo",
        min = 0,
        max = 100,
        decimal = 0
    })

    form:MakeSlider({
        serverConvar = "ttt2_kiss_clipSize",
        label = "label_kiss_clipSize",
        min = 0,
        max = 100,
        decimal = 0
    })

    form:MakeSlider({
        serverConvar = "ttt2_kiss_length",
        label = "label_kiss_length",
        min = 0,
        max = 5,
        decimal = 1
    })

    form:MakeSlider({
        serverConvar = "ttt2_kiss_delay",
        label = "label_kiss_delay",
        min = 0,
        max = 5,
        decimal = 1
    })
end