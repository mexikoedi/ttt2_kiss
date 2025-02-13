if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/weapon_kiss.vmt")
    resource.AddFile("materials/cube/cube_thing/human_heart.vmt")
    resource.AddFile("sound/kiss_prepare.wav")
    resource.AddFile("sound/kiss_start_1.wav")
    resource.AddFile("sound/kiss_start_2.wav")
    resource.AddFile("sound/kiss_start_3.wav")
    resource.AddFile("sound/kiss_start_4.wav")
    resource.AddFile("sound/kiss_start_5.wav")
    resource.AddFile("sound/kiss_start_6.wav")
    resource.AddFile("sound/kiss_meme_1.wav")
    resource.AddFile("sound/kiss_meme_2.wav")
    resource.AddFile("sound/kiss_meme_3.wav")
    resource.AddFile("models/weapons/c_kiss.mdl")
    resource.AddFile("models/humanheart/human_heart.mdl")
end

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_SPECIAL
SWEP.InLoadoutFor = nil
SWEP.CanBuy = nil
SWEP.LimitedStock = true
SWEP.Icon = "vgui/ttt/weapon_kiss"
SWEP.EquipMenuData = {
    type = "item_weapon",
    name = "ttt2_kiss_name",
    desc = "ttt2_kiss_desc"
}

SWEP.Author = "mexikoedi"
SWEP.PrintName = "Kiss"
SWEP.Contact = "Steam"
SWEP.Instructions = "Left click to kiss someone and secondary attack to play random sounds."
SWEP.Purpose = "Kiss and have fun with everyone."
SWEP.ViewModelFOV = 80
SWEP.ViewModelFlip = false
SWEP.NoSights = false
SWEP.AllowDrop = true
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.AdminSpawnable = false
SWEP.AutoSpawnable = true
SWEP.Primary.ClipSize = GetConVar("ttt2_kiss_clipSize"):GetInt()
SWEP.Primary.DefaultClip = GetConVar("ttt2_kiss_ammo"):GetInt()
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 3
SWEP.ViewModel = Model("models/weapons/c_kiss.mdl")
SWEP.WorldModel = Model("models/humanheart/human_heart.mdl")
SWEP.KissDistance = 48
SWEP.KissTime = 0.30
SWEP.NextKissTime = 0.68
SWEP.KissDamping = 0.14
SWEP.KissFOVDecrease = 0.3
SWEP.CameraViewMult = 1
SWEP.AnimEaseIn = 0.2
SWEP.AnimEaseOut = 0.8
SWEP.KissOrigin = Vector(0, -9, 5)
SWEP.KissAngles = Angle(-8, 0, 0)
local kiss_hull = Vector(8, 8, 8)
local prepare_sound = "kiss_prepare.wav"
local nextAttack = 0
local sounds = {"kiss_start_1.wav", "kiss_start_2.wav", "kiss_start_3.wav", "kiss_start_4.wav", "kiss_start_5.wav", "kiss_start_6.wav",}
local sounds2 = {"kiss_meme_1.wav", "kiss_meme_2.wav", "kiss_meme_3.wav",}
SWEP.ActInfo = {
    [ACT_VM_DRAW] = {
        length = 0.8
    },
    [ACT_VM_PRIMARYATTACK] = {
        length = GetConVar("ttt2_kiss_length"):GetFloat()
    }
}

function SWEP:Initialize()
    if CLIENT then self:AddTTT2HUDHelp("ttt2_kiss_help1", "ttt2_kiss_help2") end
    if SERVER then
        self.Primary.ClipSize = GetConVar("ttt2_kiss_clipSize"):GetInt()
        self.Primary.DefaultClip = GetConVar("ttt2_kiss_ammo"):GetInt()
    end

    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if SERVER then owner:LagCompensation(true) end
    local ct = CurTime()
    local pos = owner:GetShootPos()
    local dir = owner:GetAimVector()
    if nextAttack > ct then return end
    if SERVER and GetRoundState() ~= ROUND_ACTIVE then
        owner:ChatPrint("Round is not active, you can't use this weapon!")
        owner:LagCompensation(false)
        return
    end

    dir:Mul(self.KissDistance)
    local tr = util.TraceLine({
        start = pos,
        endpos = pos + dir,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    if not IsValid(tr.Entity) then
        tr = util.TraceHull({
            start = pos,
            endpos = pos + dir,
            filter = owner,
            mins = kiss_hull * -1,
            maxs = kiss_hull * 1,
            mask = MASK_SHOT_HULL
        })
    end

    if not self:CanKiss(tr.Entity) then
        if SERVER then owner:LagCompensation(false) end
        return
    end

    self:SetKissVictim(tr.Entity)
    self:SetNextKiss(ct + self.KissTime)
    if SERVER and GetConVar("ttt2_kiss_primary_sound"):GetBool() then owner:EmitSound(sounds[math.random(#sounds)]) end
    self:PlayActivity(ACT_VM_PRIMARYATTACK)
    self:SetHoldType("fist")
    self:TakePrimaryAmmo(1)
    if SERVER and self:Clip1() <= 0 then timer.Simple(GetConVar("ttt2_kiss_length"):GetFloat() + 0.1, function() if owner:IsActive() then self:Remove() end end) end
    nextAttack = ct + GetConVar("ttt2_kiss_delay"):GetFloat()
    if SERVER then owner:LagCompensation(false) end
end

SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()
    if self.NextSecondaryAttack > CurTime() then return end
    self.NextSecondaryAttack = CurTime() + self.Secondary.Delay
    local owner = self:GetOwner()
    if SERVER and GetConVar("ttt2_kiss_secondary_sound"):GetBool() then owner:EmitSound(sounds2[math.random(#sounds2)]) end
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    self:PlayActivity(ACT_VM_DRAW)
    if SERVER then
        if GetConVar("ttt2_kiss_prepare_sound"):GetBool() then owner:EmitSound(prepare_sound) end
        owner:DrawWorldModel(false)
    end

    if CLIENT then
        local vm = owner:GetViewModel()
        vm:SetPoseParameter("idle_pose", 0)
    end
    return true
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then
        owner:StopSound("kiss_meme_1.wav")
        owner:StopSound("kiss_meme_2.wav")
        owner:StopSound("kiss_meme_3.wav")
    end
    return not self:GetKissInfo()
end

function SWEP:Think()
    local owner = self:GetOwner()
    local vm = owner:GetViewModel()
    local ct = CurTime()
    local ft = FrameTime()
    local idleTime = self:GetNextIdle()
    if idleTime > 0 and ct > idleTime then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("idle"))
        self:UpdateNextIdle()
    end

    local nextKissTime = self:GetNextKiss()
    if nextKissTime > 0 and ct > nextKissTime then
        self:Kiss()
        self:SetNextKiss(0)
    end

    local kissing = self:GetNextPrimaryFire() > ct
    local victim = self:GetKissVictim()
    if IsValid(victim) and (not kissing or not self:CanKiss(victim)) then
        self:AbortKiss()
        kissing = false
    elseif not IsValid(victim) then
        kissing = false
    end

    if CLIENT then
        if self.KissDamping <= 0 then
            self._kissMult = kissing and 1 or 0
        else
            self._kissMult = Lerp(ft * 1 / self.KissDamping, self._kissMult, kissing and 1 or 0)
        end

        self.KissMult = math.EaseInOut(self._kissMult, self.AnimEaseIn, self.AnimEaseOut)
        if IsValid(victim) and self:ShouldAnimateKiss() then
            self.lastKissVictim = victim
        elseif not self:ShouldAnimateKiss() then
            self.lastKissVictim = nil
        end
    end
end

function SWEP:PlayActivity(act)
    self:SendWeaponAnim(act)
    local info = self.ActInfo[act]
    if not info then return false end
    if info.length then
        local nextAct = CurTime() + info.length
        self:SetNextPrimaryFire(nextAct)
    end

    self:UpdateNextIdle()
end

function SWEP:UpdateNextIdle()
    local owner = self:GetOwner()
    local vm = owner:GetViewModel()
    self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

local function IsLookingAt(ent, pos)
    if isentity(pos) then pos = pos:EyePos() end
    local diff = pos - ent:EyePos()
    return ent:EyeAngles():Forward():Dot(diff) / diff:Length() >= 0.25
end

local function GetKissDistance(kisser, victim)
    local ep = kisser:EyePos()
    ep:Sub(victim:EyePos())
    return ep:Length()
end

function SWEP:CanKiss(victim)
    if not IsValid(victim) then return false end
    local owner = self:GetOwner()
    local friendEnt = victim:IsNPC()
    if not (friendEnt or victim:IsPlayer()) then return false end
    if not IsLookingAt(victim, owner) then
        return false
    elseif GetKissDistance(owner, victim) > self.KissDistance then
        return false
    end
    return true
end

function SWEP:Kiss()
    local victim = self:GetKissVictim()
    if not IsValid(victim) then return end
    if SERVER then
        local owner = self:GetOwner()
        local dmginfo = DamageInfo()
        local dmg = 0
        local inflictor = ents.Create("weapon_ttt2_kiss")
        dmg = GetConVar("ttt2_kiss_damage"):GetInt()
        if dmg >= 0 then
            dmginfo:SetAttacker(owner)
            dmginfo:SetDamageType(DMG_GENERIC)
            dmginfo:SetInflictor(inflictor)
            dmginfo:SetDamage(dmg)
            victim:TakeDamageInfo(dmginfo)
        elseif dmg < 0 and owner:Health() < 100 and victim:Health() < 100 then
            if owner:Health() - dmg >= 100 and victim:Health() - dmg >= 100 then
                owner:SetHealth(100)
                victim:SetHealth(100)
            elseif owner:Health() - dmg >= 100 and victim:Health() - dmg <= 100 then
                owner:SetHealth(100)
                victim:SetHealth(victim:Health() - dmg)
            elseif owner:Health() - dmg <= 100 and victim:Health() - dmg >= 100 then
                owner:SetHealth(owner:Health() - dmg)
                victim:SetHealth(100)
            elseif owner:Health() - dmg <= 100 and victim:Health() - dmg <= 100 then
                owner:SetHealth(owner:Health() - dmg)
                victim:SetHealth(victim:Health() - dmg)
            end
        elseif dmg < 0 and owner:Health() < 100 and victim:Health() >= 100 then
            if owner:Health() - dmg >= 100 then
                owner:SetHealth(100)
            else
                owner:SetHealth(owner:Health() - dmg)
            end
        elseif dmg < 0 and owner:Health() >= 100 and victim:Health() < 100 then
            if victim:Health() - dmg >= 100 then
                victim:SetHealth(100)
            else
                victim:SetHealth(victim:Health() - dmg)
            end
        end
    end

    self:SetHoldType("normal")
end

function SWEP:AbortKiss()
    self:SetNextKiss(0)
    self:SetKissVictim(nil)
    self:PlayActivity(ACT_VM_IDLE)
end

function SWEP:GetKissInfo()
    local kiss = self:GetNextPrimaryFire() > CurTime()
    if kiss then return true, self:GetKissVictim() end
    return false, nil
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextKiss")
    self:NetworkVar("Float", 1, "NextIdle")
    self:NetworkVar("Entity", 0, "KissVictim")
end

if CLIENT then
    function SWEP:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, "header_equipment_additional")
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

    SWEP._kissMult = 0
    SWEP.KissMult = 0
    local npc_attachment_lookup = {
        {
            attachment = "mouth",
            origin = Vector(0, 0, 0),
            angles = Angle(0, 0, 0)
        },
        {
            attachment = "anim_attachment_head",
            origin = Vector(0, 8, 0),
            angles = Angle(-90, 0, -90)
        },
        {
            attachment = "eyes",
            origin = Vector(0, 0, -2),
            angles = Angle(0, 0, 0)
        }
    }

    local found_bones = {}
    local function FindHeadBone(ent)
        local name = ent:GetClass()
        if isnumber(found_bones[name]) then
            return found_bones[name]
        elseif found_bones[name] == false then
            return nil
        end

        for i = 0, ent:GetBoneCount() - 1 do
            local boneName = ent:GetBoneName(i)
            if boneName and boneName:lower():match("head") then
                found_bones[name] = i
                return i
            end
        end

        found_bones[name] = false
    end

    function SWEP:GetKissPos()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local victim = self.lastKissVictim
        local ep, ea = owner:EyePos(), owner:EyeAngles()
        if IsValid(victim) and self:ShouldAnimateKiss() then
            local attID, pos, ang
            for i = 1, #npc_attachment_lookup do
                local tbl = npc_attachment_lookup[i]
                attID = victim:LookupAttachment(tbl.attachment)
                if attID and attID >= 0 then
                    local att = victim:GetAttachment(attID)
                    if att then
                        pos, ang = att.Pos, att.Ang
                        ang:RotateAroundAxis(ang:Right(), tbl.angles.p)
                        ang:RotateAroundAxis(ang:Up(), tbl.angles.y)
                        ang:RotateAroundAxis(ang:Forward(), tbl.angles.r)
                        pos = pos + tbl.origin.x * ang:Right()
                        pos = pos + tbl.origin.y * ang:Forward()
                        pos = pos + tbl.origin.z * ang:Up()
                        break
                    end
                end
            end

            if not pos or not ang then
                local boneID = FindHeadBone(victim)
                if boneID then
                    pos = victim:GetBonePosition(boneID)
                else
                    pos = victim:EyePos() - Vector(0, 0, 8)
                end

                ang = (ep - pos):Angle()
            end

            ang:RotateAroundAxis(ang:Up(), 180)
            pos = pos + self.KissOrigin.x * ang:Right()
            pos = pos + self.KissOrigin.y * ang:Forward()
            pos = pos + self.KissOrigin.z * ang:Up()
            ang:RotateAroundAxis(ang:Right(), self.KissAngles.p)
            ang:RotateAroundAxis(ang:Up(), self.KissAngles.y)
            ang:RotateAroundAxis(ang:Forward(), self.KissAngles.r)
            return pos, ang
        end
        return ep, ea
    end

    function SWEP:ShouldAnimateKiss()
        return math.Round(self.KissMult, 2) > 0
    end

    local idle_pose = 0
    function SWEP:PreDrawViewModel(vm, _, ply)
        local ft = FrameTime()
        local attID = vm:LookupAttachment("camera")
        local act = vm:GetSequenceActivity(vm:GetSequence())
        if attID and attID >= 0 and ply:GetInternalVariable("m_bInZoom") ~= true then
            local vm_origin = vm:GetPos()
            local vm_angles = vm:GetAngles()
            vm:SetAngles(Angle(0, 0, 0))
            vm:InvalidateBoneCache()
            self.AttData = vm:GetAttachment(attID)
            vm:SetAngles(vm_angles)
            local attpos = self.AttData.Pos
            local attang = self.AttData.Ang
            attpos:Sub(vm_origin)
            attang:RotateAroundAxis(attang:Up(), -90)
            attang:Normalize()
            local mult = self.ViewModelFOV / ply:GetFOV() * self.CameraViewMult
            attpos:Mul(mult)
            attang:Normalize()
        elseif self.AttData then
            self.AttData = nil
        end

        local anim_idle = not self.ActInfo[act] and ply:GetMoveType() == MOVETYPE_WALK
        local vel = ply:GetVelocity()
        local speed = vel:Length()
        local pose_to = anim_idle and math.Clamp(speed / ply:GetRunSpeed(), 0, 1) or 0
        idle_pose = Lerp(ft * 4, idle_pose, pose_to)
        local pose = math.EaseInOut(idle_pose, self.AnimEaseIn, self.AnimEaseOut)
        vm:SetPoseParameter("idle_pose", pose)
        vm:InvalidateBoneCache()
        render.SetBlend(0)
    end

    function SWEP:ShouldDrawViewModel()
        return true
    end

    function SWEP:PostDrawViewModel(_, _, ply)
        if not IsValid(ply) then return end
        local vm_depth = self.ViewModelFOV / ply:GetFOV()
        local hands = ply:GetHands()
        if not IsValid(hands) then return end
        render.SetBlend(1)
        render.DepthRange(0, vm_depth)
        hands:DrawModel()
        render.DepthRange(0, 1)
    end

    function SWEP:CalcViewModelView(_, _, _, vm_origin, vm_angles)
        if self:ShouldAnimateKiss() then
            local pos, ang = self:GetKissPos()
            if pos == nil or ang == nil then return end
            vm_origin = LerpVector(self.KissMult, vm_origin, pos)
            vm_angles = LerpAngle(self.KissMult, vm_angles, ang)
        end
        return vm_origin, vm_angles
    end

    function SWEP:CalcView(ply, origin, angles, fov)
        if not IsValid(ply) then return end
        if ply:GetViewEntity() ~= ply then return end
        if self:ShouldAnimateKiss() then
            local pos, ang = self:GetKissPos()
            if pos == nil or ang == nil then return end
            origin = LerpVector(self.KissMult, origin, pos)
            angles = LerpAngle(self.KissMult, angles, ang)
            fov = fov - self.KissMult * fov * self.KissFOVDecrease
        end

        local att = self.AttData
        if att then
            origin:Add(att.Pos)
            angles:Add(att.Ang)
        end
        return origin, angles, fov
    end
end