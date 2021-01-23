print("CL_OX Loaded")

CreateClientConVar("cl_oxygen_hudpos_x", "30", true, false, "The X Position of the Oxygen Indicator")
CreateClientConVar("cl_oxygen_hudpos_y", "30", true, false, "The Y Position of the Oxygen Indicator")
CreateClientConVar("cl_oxygen_hudpos_w", "200", true, false, "The Width of the Oxygen Indicator")
CreateClientConVar("cl_oxygen_hudpos_h", "20", true, false, "The Height of the Oxygen Indicator")
CreateClientConVar("cl_oxygen_hudhide", "0", true, false, "Hide the Oxygen Indicator when Oxygen is full")
CreateClientConVar("cl_oxygen_motionblur", "1", true, false, "Show a motion blur effect when low on oxygen")


local oxygen = GetConVar("sv_oxygen_maxoxygen"):GetInt()

function GetLocalOxygen() return oxygen end

net.Receive("ox_update", function()
    oxygen = net.ReadInt(16)
end)

local minhud_o2 = Material("minhud_o2")

local function animatedFade( timesince, fadetime, max )
    return max + ((math.Clamp((timesince - CurTime()), (fadetime * -1), 0) / fadetime) * max)
end

surface.CreateFont( "minhud_big", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 16,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local timesincenotfull = CurTime()

hook.Add("HUDPaint", "ox_hud", function()

	if(GetConVar("sv_oxygen_enable"):GetBool() == false) then return end
	if(GetConVar("cl_oxygen_hudhide"):GetBool() and oxygen ~= GetConVar("sv_oxygen_maxoxygen"):GetInt()) then
		timesincenotfull = CurTime()
	end
    x = GetConVar("cl_oxygen_hudpos_x"):GetInt()
    y = GetConVar("cl_oxygen_hudpos_y"):GetInt()
    w = GetConVar("cl_oxygen_hudpos_w"):GetInt()
    h = GetConVar("cl_oxygen_hudpos_h"):GetInt()
	oxygen = oxygen or 200
	
	if(hook.Run("OxygenHUDPaint", x, y, w, h, timesincenotfull) == true) then return end

    draw.RoundedBox(5, x, y, w, h, Color(45, 45, 45, animatedFade( timesincenotfull, 3, 155)))
    draw.RoundedBox(5, x + h + 2, y + 2, w - (h + 4), h - 4, Color(40, 40, 40, animatedFade( timesincenotfull, 3, 255)))
    draw.RoundedBox(5, x + h + 2, y + 2, (oxygen / GetConVar("sv_oxygen_maxoxygen"):GetInt()) * (w - (h + 4)) or w - (h + 4), h - 4, Color(100, 100, 255, animatedFade( timesincenotfull, 3, 255)))
    draw.SimpleText( math.Round((oxygen / GetConVar("sv_oxygen_maxoxygen"):GetInt()) * 100) .. '%', "minhud_big", x + ( (h + 2) + ((w - h) / 2) ), y + (h / 2), Color(255,255,255,animatedFade( timesincenotfull, 3, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    surface.SetMaterial(minhud_o2)
	surface.DrawTexturedRect(x, y, h, h)
	
	hook.Run("OxygenHUDPostPaint", x, y, w, h, timesincenotfull)

end)

local function simpleLerp( a, b, t)
    return a + (b - a) * t
end

hook.Add("RenderScreenspaceEffects", "ox_render_lowoxygen", function( origin, angles, fov )
	oxygen = oxygen or 200
    if(oxygen <=  ( GetConVar("sv_oxygen_maxoxygen"):GetInt() / 4) and GetConVar("cl_oxygen_motionblur"):GetBool()) then
        DrawMotionBlur( simpleLerp(0.3, 1, (oxygen / ( GetConVar("sv_oxygen_maxoxygen"):GetInt() / 4) ) ), 0.8, 0.01 )
    end
end)