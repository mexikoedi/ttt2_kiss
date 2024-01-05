-- convars added with default values
CreateConVar("ttt2_kiss_prepare_sound", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sound of the preparing")
CreateConVar("ttt2_kiss_primary_sound", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sound of the primary attack")
CreateConVar("ttt2_kiss_secondary_sound", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sound of the secondary attack")
CreateConVar("ttt2_kiss_damage", "-10", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage of the kiss (Negative values heal)")
CreateConVar("ttt2_kiss_ammo", "3", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Default ammo amount of kisses when bought")
CreateConVar("ttt2_kiss_clipSize", "3", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Default clipsize amount of kisses")
CreateConVar("ttt2_kiss_length", "0.80", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Length of the kiss animation")
CreateConVar("ttt2_kiss_delay", "3.00", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Delay until the next kiss")
if CLIENT then
    -- Use string or string.format("%.f",<steamid64>) 
    -- addon dev emblem in scoreboard
    hook.Add("TTT2FinishedLoading", "TTT2RegistermexikoediAddonDev", function() AddTTT2AddonDev("76561198279816989") end)
end