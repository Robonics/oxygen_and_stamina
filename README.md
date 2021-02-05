# Oxygen and Stamina System
## Implemented as of Version 7

A Gmod addon that attempts to provide a replacement for the Suit Power system

I'm not going to repeat everything that was on the workshop page you likely used to get here, and assuming that you're here you know how to program. As of the latest push (In development) some helpful functions have been added in order to allow you an integration into the system itself, so that you can build on it. It's a simple mod and so are the functions

`GetLocalStamina()` / `GetLocalOxygen()` / `GetLocalFlashlightBattery()`
These are client functions that will return the value of their respective value

`_G.OXST.timeFade(timeSince, fadeTime, max)`
This function is used to lerp the alpha of HUD elements if they are full and `sv_module_hudhide` is `1`. You should add this as the alpha perameter for all color values in your HUD, where timeSince is the time the hud was last not full (Passed as `timeFull` in the Override hooks, you can also add to the value to delay the fade), fadeTime is how long you want the fade transition to take, and max is the normal unfaded alpha value you want

Client Hook `StaminaHUDPaint(x, y, w, h, timeFull)` / `OxygenHUDPaint(x, y, w, h, timeFull)` / `FlashlightHUDPaint(x, y, w, h, timeFull)`
These hooks are called when the addon draws Hud elements, you should use `OXST.timeFade()` for all alpha values here, if you are replacing the HUD you should `return true` from this hook, otherwise the normal HUD will still display.

Client Hook `StaminaHUDPostPaint(x, y, w, h, timeFull)` / `OxygenHUDPostPaint(x, y, w, h, timeFull)` / `FlashlightHUDPostPaint(x, y, w, h, timeFull)`
This hook is called after the default hud has been drawn, use this to draw on top of it

Server Hook `OxygenThink(ply, prethink, postthink)`
This hook is called once for each player on oxygen think. This is a think hook so don't perform any heavy computations here. `ply` is the target player, `prethink` is the value before changes, `postthink` is the value afterward. return a new oxygen value if you wish to alter it.

Server Hook `StaminaThink(ply, prethink, postthink, CMoveData, CUserCMD)`
The exact same as the Oxygen think except for two major differences. This calls from a `GM:SetupMove` hook, which means that it executes after `GM:Think()`, it also passes a CMoveData and CUserCMD.

Server Hook `FlashlightThink(ply, prethink, postthink)`
The exact same as `OnOxygenThink()` but with the flashlight battery
