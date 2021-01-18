print("SV_ST_OX loaded")

CreateConVar("sv_oxygen_maxoxygen", "1000", FCVAR_ARCHIVE, "The Maximum amount of Oxygen a player can have (use this to determine how fast they drown, 1 oxy point is lost per tick but this can change with lag)")
CreateConVar("sv_oxygen_recoveramount", "5", FCVAR_ARCHIVE, "The Amount per tick to recover outside of the water")
CreateConVar("sv_ox_st_should_affect_both", "1", FCVAR_ARCHIVE, "Should Lack of Stamina or Oxygen inhibit the other slightly, this is a multiplyer, so lower amounts will cause it to affect less and vice versa")
CreateConVar("sv_oxygen_damage_timer", "1", FCVAR_ARCHIVE, "The Time (in seconds) to wait between each damage tick while drowning")
CreateConVar("sv_oxygen_damage_amount", "5", FCVAR_ARCHIVE, "The damage to deal each damage tick while drowning")
--CreateConVar("sv_stamina_overuse_amount", "10", FCVAR_ARCHIVE, "If > 0, the player will be able to use this many stamina points after running out, essencially bonus stamina to give a slight advantage")
CreateConVar("sv_stamina_enable", "1", FCVAR_ARCHIVE, "Enable Stamina?")
CreateConVar("sv_oxygen_enable", "1", FCVAR_ARCHIVE, "Enable Oxygen?")
CreateConVar("sv_stamina_sprint_at", "10", FCVAR_ARCHIVE, "How much stamina the player needs to sprint again")
CreateConVar("sv_stamina_maxstamina", "300", FCVAR_ARCHIVE, "The maximum amount of stamina a player can have")
CreateConVar("sv_stamina_recoveramount", "5", FCVAR_ARCHIVE, "How much to recover per tick when not sprinting")
CreateConVar("sv_stamina_recovertime", "3", FCVAR_ARCHIVE, "The Amount of time to wait before stamina recovery begins")
CreateConVar("sv_stamina_jumpcost", "25", FCVAR_ARCHIVE, "How much stamina jumping costs")
CreateConVar("sv_stamina_jumplimited", "1", FCVAR_ARCHIVE, "You must have stamina to jump")
CreateConVar("sv_stamina_swimuses", "0", FCVAR_ARCHIVE, "Does swimming consume stamina? -1: No | 0: No Recovery | 0.1+: Yes by this amount")

CreateConVar("sv_flashlight_enablebattery", "0", FCVAR_ARCHIVE, "Should the flashlight battery be enabled")
CreateConVar("sv_flashlight_maxbattery", "3000", FCVAR_ARCHIVE, "Max Flashlight Battery")

util.AddNetworkString("ox_update")
util.AddNetworkString("st_update")
util.AddNetworkString("fl_update")

hook.Add("Think", "ox_think", function()
    if(GetConVar("sv_oxygen_enable"):GetBool() == false) then return end
    for k, ply in ipairs(player.GetAll()) do
        
        ply.oxygen = ply.oxygen or 200
        ply.last_oxygen = ply.last_oxygen or 200
        ply.last_dmg = ply.last_dmg or CurTime()
        ply.stamina = ply.stamina or 10
        max_oxygen = GetConVar("sv_oxygen_maxoxygen"):GetInt()

        if(ply:Alive() and IsValid(ply)) then
            if(ply:WaterLevel() == 3) then
                if(ply.oxygen > 0) then
                    ply.oxygen = ply.oxygen - 1 - ( ( 1 - (ply.stamina / GetConVar("sv_stamina_maxstamina"):GetInt()) ) * GetConVar("sv_ox_st_should_affect_both"):GetFloat())
                else
                    if(ply.last_dmg <= CurTime() - GetConVar("sv_oxygen_damage_timer"):GetFloat()) then
                        damage = DamageInfo()
                        damage:SetAttacker( game.GetWorld() )
                        damage:SetInflictor( game.GetWorld() )
                        damage:SetDamage( GetConVar("sv_oxygen_damage_amount"):GetInt() )
                        damage:SetDamageType(DMG_DROWN)
            
                        if(IsValid(ply) and damage) then
                            ply:TakeDamageInfo( damage )
                        end
                        ply.last_dmg = CurTime()
                    end
                end
            else
                if(ply.oxygen < max_oxygen) then
                    ply.oxygen = ply.oxygen + GetConVar("sv_oxygen_recoveramount"):GetInt()
                end
                if(ply.oxygen > max_oxygen) then
                    ply.oxygen = max_oxygen
                end
            end
            if(ply.oxygen ~= ply.last_oxygen) then
                net.Start("ox_update")
                net.WriteInt(ply.oxygen, 16)
                net.Send(ply)

            end
            ply.last_oxygen = ply.oxygen
        end

        ply.oxygen = hook.Run("OxygenThink", ply, ply.oxygen, ply.last_oxygen) or ply.oxygen

    end
end)

local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
    -- Using bitwise operations to clear the key bits.
    local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
    self:SetButtons(newbuttons)
end

local wasJumping = false

hook.Add("SetupMove", "st_move_limit", function(ply, mvd, cmd)
    if(GetConVar("sv_stamina_enable"):GetBool() == false) then return end
    ply.stamina = ply.stamina or GetConVar("sv_stamina_maxstamina"):GetInt()
    ply.last_stamina = ply.last_stamina or ply.stamina
    ply.last_stamina_use = ply.last_stamina_use or CurTime()
    if(mvd:KeyDown(IN_SPEED) and ply:IsOnGround() and mvd:GetVelocity() ~= Vector(0, 0, 0)) then
        if(ply.stamina > 0) then
            ply.stamina = ply.stamina - 1 - ( ( 1 - (ply.oxygen / GetConVar("sv_oxygen_maxoxygen"):GetInt()) ) * GetConVar("sv_ox_st_should_affect_both"):GetFloat())
        end
        ply.last_stamina_use = CurTime()
    end
    if(not mvd:KeyDown(IN_JUMP) and ply:IsOnGround()) then wasJumping = false end
    if (mvd:KeyDown(IN_JUMP) and ply:IsOnGround() and wasJumping == false) then
        if(ply.stamina > 0) then
            ply.stamina = ply.stamina - GetConVar("sv_stamina_jumpcost"):GetInt()
        end
        ply.last_stamina_use = CurTime()

        wasJumping = true

    end
    if(GetConVar("sv_stamina_swimuses"):GetInt() >= 0 and ply:WaterLevel() > 1 and not ply:IsOnGround()) then
        if(ply.stamina > 0) then
            ply.stamina = ply.stamina - GetConVar("sv_stamina_swimuses"):GetFloat()
        end
        ply.last_stamina_use = CurTime()
    end
    if(ply.last_stamina_use <= CurTime() - GetConVar("sv_stamina_recovertime"):GetInt()) then
        if(ply.stamina < GetConVar("sv_stamina_maxstamina"):GetInt()) then
            ply.stamina = ply.stamina + GetConVar("sv_stamina_recoveramount"):GetInt()
        end
        if(ply.stamina > GetConVar("sv_stamina_maxstamina"):GetInt()) then
            ply.stamina = GetConVar("sv_stamina_maxstamina"):GetInt()
        end
    end
    if(ply.stamina < 0) then
        ply.stamina = 0
    end
    if(ply.last_stamina ~= ply.stamina) then
        net.Start("st_update")
        net.WriteInt(ply.stamina, 16)
        net.Send(ply)
    end

    ply.stamina = hook.Run("StaminaThink", ply, ply.stamina, ply.last_stamina, mvd, cmd) or ply.stamina

    ply.last_stamina = ply.stamina
end)

hook.Add("Think", "fl_think", function()
    if(GetConVar("sv_flashlight_enablebattery"):GetBool() == false) then return end 
    for k, ply in ipairs(player.GetAll()) do
        ply.flashlight = ply.flashlight or GetConVar("sv_flashlight_maxbattery"):GetInt()
        ply.last_flashlight = ply.last_flashlight or ply.flashlight

        if(ply:FlashlightIsOn()) then
            ply.flashlight = ply.flashlight - 1
        else
            if(ply.flashlight < GetConVar("sv_flashlight_maxbattery"):GetInt()) then
                ply.flashlight = ply.flashlight + 1
            end
        end

        if(ply.flashlight <= 0) then
            ply:Flashlight( false )
        end

        if(ply.last_flashlight ~= ply.flashlight) then
            net.Start("fl_update")
            net.WriteInt(ply.flashlight, 16)
            net.Send(ply)
        end

        ply.flashlight = hook.Run("FlashlightThink", ply, ply.flashlight, ply.last_flashlight) or ply.flashlight

        ply.last_flashlight = ply.flashlight
    end
end)

hook.Add("PlayerSpawn", "ox_st_spawnreset", function(ply, trans)

    if( not trans ) then

        ply.oxygen = GetConVar("sv_oxygen_maxoxygen"):GetInt()
        ply.stamina = GetConVar("sv_stamina_maxstamina"):GetInt()
        ply.flashlight = GetConVar("sv_flashlight_maxbattery"):GetInt()

    end

end)