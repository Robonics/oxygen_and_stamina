print("CL_FL Loaded")

CreateClientConVar("cl_flashlight_hudpos_x", "30", true, false, "The X Position of the Battery Indicator")
CreateClientConVar("cl_flashlight_hudpos_y", "90", true, false, "The Y Position of the Battery Indicator")
CreateClientConVar("cl_flashlight_hudpos_w", "200", true, false, "The Width of the Battery Indicator")
CreateClientConVar("cl_flashlight_hudpos_h", "20", true, false, "The Height of the Battery Indicator")
CreateClientConVar("cl_flashlight_hudhide", "0", true, false, "Hide the Flashlight Indicator when Oxygen is full")

local flashlight = GetConVar("sv_flashlight_maxbattery"):GetInt()

function GetLocalFlashlightBattery() return flashlight end

net.Receive("fl_update", function()
    flashlight = net.ReadInt(16)
end)

local minhud_fl = Material("minhud_battery")

local function animatedFade( timesince, fadetime, max )
    return max + ((math.Clamp((timesince - CurTime()), (fadetime * -1), 0) / fadetime) * max)
end

local timesincenotfull = CurTime()

hook.Add("HUDPaint", "fl_hud", function()
    if(GetConVar("sv_flashlight_enablebattery"):GetBool() == false) then return end
    if(GetConVar("cl_flashlight_hudhide"):GetBool() and flashlight ~= GetConVar("sv_flashlight_maxbattery"):GetInt()) then
        timesincenotfull = CurTime()
    end
    x = GetConVar("cl_flashlight_hudpos_x"):GetInt()
    y = GetConVar("cl_flashlight_hudpos_y"):GetInt()
    w = GetConVar("cl_flashlight_hudpos_w"):GetInt()
    h = GetConVar("cl_flashlight_hudpos_h"):GetInt()
    flashlight = flashlight or 300

    if( hook.Run("FlashlightHUDPaint", x, y, w, h, timesincenotfull) ) then return end

    draw.RoundedBox(5, x, y, w, h, Color(45, 45, 45, animatedFade( timesincenotfull, 3, 155)))
    draw.RoundedBox(5, x + h + 2, y + 2, w - (h + 4), h - 4, Color(40, 40, 40, animatedFade( timesincenotfull, 3, 255)))
    draw.RoundedBox(5, x + h + 2, y + 2, (flashlight / GetConVar("sv_flashlight_maxbattery"):GetInt()) * (w - (h + 4)) or w - (h + 4), h - 4, Color(80, 80, 200, animatedFade( timesincenotfull, 3, 255)))
    draw.SimpleText( math.Round((flashlight / GetConVar("sv_flashlight_maxbattery"):GetInt()) * 100) .. '%', "minhud_big", x + ( (h + 2) + ((w - h) / 2) ), y + (h / 2), Color(255,255,255,animatedFade( timesincenotfull, 3, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    surface.SetMaterial(minhud_fl)
    surface.DrawTexturedRect(x, y, h, h)

    hook.Run("FlashlightHUDPostPaint", x, y, w, h, timesincenotfull)

end)