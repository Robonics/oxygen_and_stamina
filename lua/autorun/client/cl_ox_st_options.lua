OXST = {
	animatedFade = function( timesince, fadetime, max )
		return max + ((math.Clamp((timesince - CurTime()), (fadetime * -1), 0) / fadetime) * max)
	end
}

hook.Add( "AddToolMenuTabs", "ox_st_tab", function()
	spawnmenu.AddToolTab("ox_st_tab", "Oxygen & Stamina", "icon16/plugin.png") -- Add a new tab

	spawnmenu.AddToolCategory("ox_st_tab", "ox_st_server_category", "Server Options") -- Add a category into that new tab

	spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_server_category", "ox_st_server_modules", "Combination", "", "", function( panel )
        panel:ClearControls()
        panel:NumSlider( "Mutual Effect", "sv_ox_st_should_affect_both", 0, 2, 1 )
        panel:ControlHelp( "Should a lack of oxygen affect how fast you run out of stamina and vice versa. This is a multipler so setting it to 0 disables it and setting it to 2 sets it to the maximum. At a value of 1 Oxygen decreases at a double rate when stamina is empty and vice versa." )
    end ) -- Add an entry to our new category
    spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_server_category", "ox_st_server_oxygen", "Oxygen", "", "", function( panel )
        panel:ClearControls()
        panel:CheckBox( "Enable Oxygen", "sv_oxygen_enable" )
        panel:NumSlider( "Max Oxygen", "sv_oxygen_maxoxygen", 10, 10000, 0 )
        panel:ControlHelp( "The maximum amount of oxygen each player has, use this in order to control how fast they drown. Oxygen is lost a 1 point per tick while underwater" )
        panel:NumSlider("Recover Amount", "sv_oxygen_recoveramount", 1, 10, 0)
        panel:ControlHelp( "The amount of oxygen to recover each tick when not underwater. Setting this to 2 will recover oxygen 2x as fast as it is lost, ect." )
        panel:NumSlider("Damage Time", "sv_oxygen_damage_timer", 0.1, 3, 1 )
        panel:ControlHelp( "How often to apply drowning damage to the player in seconds. 1 Second is the same rate as vanilla drowning." )
        panel:NumSlider("Damage Amount", "sv_oxygen_damage_amount", 1, 150, 0 )
        panel:ControlHelp( "How much damage is done each damage tick while the player is drowning, the vanilla amount is 5" )
    end ) -- Add an entry to our new category
    spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_server_category", "ox_st_server_stamina", "Stamina", "", "", function( panel )
        panel:ClearControls()
        panel:CheckBox( "Enable Stamina", "sv_stamina_enable" )
        panel:NumSlider( "Max Stamina", "sv_stamina_maxstamina", 10, 10000, 0 )
        panel:ControlHelp( "The maximum amount of stamina each player has, use this in order to control how fast they run out. Stamina is lost a 1 point per tick while running" )
        panel:NumSlider("Recover Amount", "sv_stamina_recoveramount", 1, 10, 0)
        panel:ControlHelp( "The amount of stamina to recover each tick" )
        panel:NumSlider("Recover Time", "sv_stamina_recovertime", 0, 10, 0 )
        panel:ControlHelp( "How Long after the last time the player lost stamina to wait before they start recovering." )
        panel:NumSlider("Sprint At", "sv_stamina_sprint_at", 0, 5000, 0 )
        panel:ControlHelp( "How much stamina the player needs to START sprinting, this will not come into play if the player is already sprinting" )
        panel:NumSlider("Jump Cost", "sv_stamina_jumpcost", 0, 150, 0 )
        panel:ControlHelp( "How Much Stamina Jumping uses, if you don't want it to use any set this to 0" )
        panel:CheckBox("Need stamina to Jump", "sv_stamina_jumplimited")
        panel:ControlHelp("If this is enabled the player will not be able to jump at 0% stamina")
        panel:NumSlider("Swim Cost", "sv_stamina_swimuses", -1, 1, 1 )
        panel:ControlHelp("How much stamina swimming uses if any,\nAnything <0: Swimming has No Effect\n0: Swimming will not drain stamina but stamina cannot be recovered in the water\n0.1+: Swimming will use this amount per tick, sprinting cost is added to this number if the player is sprint swimming")
    end ) -- Add an entry to our new category
    spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_server_category", "ox_st_server_flashlight", "Flashlight", "", "", function( panel )
        panel:ClearControls()
        panel:CheckBox( "Enable Flashlight", "sv_flashlight_enablebattery" )
        panel:NumSlider( "Max Battery", "sv_flashlight_maxbattery", 10, 100000, 0 )
        panel:ControlHelp( "The maximum amount of flashlight battery each player has, use this in order to control how fast they run out. Battery is lost a 1 point per tick while the flashlight is on" )
    end ) -- Add an entry to our new category
    
    spawnmenu.AddToolCategory("ox_st_tab", "ox_st_client_category", "Client Options") -- Add a category into that new tab
    spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_client_category", "ox_st_client_oxygen", "Oxygen", "", "", function( panel )
        panel:ClearControls()
        panel:NumSlider( "HUD X", "cl_oxygen_hudpos_x", 0, 2000, 0 )
        panel:NumSlider("HUD Y", "cl_oxygen_hudpos_y", 1, 2000, 0)
        panel:NumSlider("HUD Width", "cl_oxygen_hudpos_w", 0, 2000, 0 )
        panel:NumSlider("HUD Height", "cl_oxygen_hudpos_h", 0, 2000, 0 )
        panel:CheckBox("Hide When Full", "cl_oxygen_hudhide")
        panel:CheckBox("Low Oxygen Motion Blur", "cl_oxygen_motionblur")
    end ) -- Add an entry to our new category
    spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_client_category", "ox_st_client_stamina", "Stamina", "", "", function( panel )
        panel:ClearControls()
        panel:NumSlider( "HUD X", "cl_stamina_hudpos_x", 0, 2000, 0 )
        panel:NumSlider("HUD Y", "cl_stamina_hudpos_y", 1, 2000, 0)
        panel:NumSlider("HUD Width", "cl_stamina_hudpos_w", 0, 2000, 0 )
        panel:NumSlider("HUD Height", "cl_stamina_hudpos_h", 0, 2000, 0 )
        panel:CheckBox("Hide When Full", "cl_stamina_hudhide")
        panel:CheckBox("Low Stamina Motion Blur", "cl_stamina_motionblur")
    end ) -- Add an entry to our new category
    spawnmenu.AddToolMenuOption( "ox_st_tab", "ox_st_client_category", "ox_st_client_flashlight", "Flashlight", "", "", function( panel )
        panel:ClearControls()
        panel:NumSlider( "HUD X", "cl_flashlight_hudpos_x", 0, 2000, 0 )
        panel:NumSlider("HUD Y", "cl_flashlight_hudpos_y", 1, 2000, 0)
        panel:NumSlider("HUD Width", "cl_flashlight_hudpos_w", 0, 2000, 0 )
        panel:NumSlider("HUD Height", "cl_flashlight_hudpos_h", 0, 2000, 0 )
        panel:CheckBox("Hide When Full", "cl_flashlight_hudhide")
    end ) -- Add an entry to our new category
end)