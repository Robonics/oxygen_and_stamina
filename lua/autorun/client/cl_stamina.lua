print("CL_ST Loaded")

CreateClientConVar("cl_stamina_hudpos_x", "30", true, false, "The X Position of the Stamina Indicator")
CreateClientConVar("cl_stamina_hudpos_y", "60", true, false, "The Y Position of the Stamina Indicator")
CreateClientConVar("cl_stamina_hudpos_w", "200", true, false, "The Width of the Stamina Indicator")
CreateClientConVar("cl_stamina_hudpos_h", "20", true, false, "The Height of the Stamina Indicator")
CreateClientConVar("cl_stamina_hudhide", "0", true, false, "Hide the Stamina Indicator when Oxygen is full")


local stamina = GetConVar("sv_stamina_maxstamina"):GetInt()

function GetLocalStamina() return stamina end

net.Receive("st_update", function()
    stamina = net.ReadInt(16)
end)

local minhud_st = Material("minhud_sprint")

local function animatedFade( timesince, fadetime, max )
    return max + ((math.Clamp((timesince - CurTime()), (fadetime * -1), 0) / fadetime) * max)
end

hook.Add("CreateMove", "st_cl_move", function(move)
    stamina = stamina or 1
    if(GetConVar("sv_stamina_enable"):GetBool() == false) then return end
    if(stamina <= GetConVar("sv_stamina_sprint_at"):GetInt()) then
        if(not LocalPlayer():IsSprinting()) then
            move:RemoveKey(IN_SPEED)
        end
    end
    if(stamina <= 0) then
        move:RemoveKey(IN_SPEED)
    end
    if(stamina <= 0 and GetConVar("sv_stamina_jumplimited"):GetBool()) then
        move:RemoveKey(IN_JUMP)
    end
end)

local timesincenotfull = CurTime()

hook.Add("HUDPaint", "st_hud", function()
    stamina = stamina or GetConVar("sv_stamina_maxstamina"):GetInt()
    if(GetConVar("sv_stamina_enable"):GetBool() == false) then return end
    if(GetConVar("cl_stamina_hudhide"):GetBool() and stamina ~= GetConVar("sv_stamina_maxstamina"):GetInt()) then
        timesincenotfull = CurTime()
    end
    x = GetConVar("cl_stamina_hudpos_x"):GetInt()
    y = GetConVar("cl_stamina_hudpos_y"):GetInt()
    w = GetConVar("cl_stamina_hudpos_w"):GetInt()
    h = GetConVar("cl_stamina_hudpos_h"):GetInt()
    stamina = stamina or 1

    if( hook.Run("StaminaHUDPaint", x, y, w, h, timesincenotfull) ) then return end

    draw.RoundedBox(5, x, y, w, h, Color(45, 45, 45, animatedFade( timesincenotfull, 3, 155)))
    draw.RoundedBox(5, x + h + 2, y + 2, w - (h + 4), h - 4, Color(40, 40, 40, animatedFade( timesincenotfull, 3, 255)))
    if(stamina <= GetConVar("sv_stamina_sprint_at"):GetInt()) then
        draw.RoundedBox(5, x + h + 2, y + 2, (stamina / GetConVar("sv_stamina_maxstamina"):GetInt()) * (w - (h + 4)) or w - (h + 4), h - 4, Color(200, 80, 80, animatedFade( timesincenotfull, 3, 255)))
    else
        draw.RoundedBox(5, x + h + 2, y + 2, (stamina / GetConVar("sv_stamina_maxstamina"):GetInt()) * (w - (h + 4)) or w - (h + 4), h - 4, Color(80, 200, 80, animatedFade( timesincenotfull, 3, 255)))
    end
    draw.SimpleText( math.Round((stamina / GetConVar("sv_stamina_maxstamina"):GetInt()) * 100) .. '%', "minhud_big", x + ( (h + 2) + ((w - h) / 2) ), y + (h / 2), Color(255,255,255,animatedFade( timesincenotfull, 3, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    surface.SetMaterial(minhud_st)
    surface.DrawTexturedRect(x, y, h, h)

    hook.Run("StaminaHUDPostPaint", x, y, w, h, timesincenotfull)

end)