#Everything in this README file refers to features which have not yet been implemented

# Oxygen and Stamina System
A Gmod addon that attempts to provide a replacement for the Suit Power system

I'm not going to repeat everything that was on the workshop page you likely used to get here, and assuming that you're here you know how to program. As of the latest push (In development) some helpful functions have been added in order to allow you an integration into the system itself, so that you can build on it. It's a simple mod and so are the functions

`GetLocalStamina()` / `GetLocalOxygen()` / `GetLocalFlashlightBattery()`
These are all __Clientside__ functions, they return what the client thinks the stamina is, this value is not as reliable as the server.

`Player:GetStamina()` / `Player:GetOxygen()` / `Player:GetFlashlightBattery()`
These are the server sided versions of the previous functions, this value is accurate.

`Player:SetStamina()` / `Player:SetOxygen()` / `Player:SetFlashlightBattery()`
This will replace the value of the respective module with your own.

`OXST.timeFade(timeSince, fadeTime, max)`
This function is used to lerp the alpha of HUD elements if they are full and `sv_module_hudhide` is `1`. You should add this as the alpha perameter for all color values in your HUD, where timeSince is the time the hud was last not full (Passed as `timeFull` in the Override hooks, you can also add to the value to delay the fade), fadeTime is how long you want the fade transition to take, and max is the normal unfaded alpha value you want

Client Hook `OverrideDrawStamina(x, y, w, h, stamina, max_stamina, timeFull)` / `OverrideDrawOxygen(x, y, w, h, oxygen, max_oxygen, timeFull)` / `OverrideDrawBattery(x, y, w, h, battery, max_battery, timeFull)`
These hooks are called when the addon draws Hud elements, you should use `OXST.timeFade()` for all alpha values here, if you are replacing the HUD you should return true from this hook, otherwise the normal HUD will still display.

Server Hook `OnOxygenThink(ply, prethink, postthink)`
This hook is called once for each player on oxygen think. This is a think hook so don't perform any heavy computations here. `ply` is the target player, `prethink` is the value before changes, `postthink` is the value afterward. return a new oxygen value if you wish to alter it.

Server Hook `OnStaminaThink(ply, prethink, postthink, movedata)`
The exact same as the Oxygen think except for two major differences. This calls from a Move hook, which means that it executes after `GM:Think()`, it also passes a CMoveData.

Server Hook `OnBatteryThink(ply, prethink, postthink)`
The exact same as `OnOxygenThink()` but with the flashlight battery

That's it. 
