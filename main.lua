require('mobdebug').start();
StartDebug();
local mod = RegisterMod("AI Final", 1);


--[[ uncomment this when we need to include config
local _, err = pcall(require, "config")
err = tostring(err)
if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
    if string.match(err, "true") then
        err = "Error: require passed in config"
    end
    Isaac.DebugString(err)
    print(err)
end
  require("descriptions.ab+."..EIDConfig["Language"])
  --]]
Isaac.ConsoleOutput("----------------------------\n--- AI Final Initialized ---\n----------------------------\n")
-- Make Isaac invincible
Isaac.ExecuteCommand("debug 3") 	
-- Make all enemies in room die
--Isaac.ExecuteCommand("debug 10")

function onInputRequest(arg0, entity, inputHook, buttonAction)
  if inputHook == InputHook.GET_ACTION_VALUE then
    return 0.0
  end
  if buttonAction == ButtonAction.ACTION_LEFT or buttonAction == ButtonAction.ACTION_SHOOTUP then
    Isaac.ConsoleOutput("shootleft\n")
    Isaac.ConsoleOutput(buttonAction)
    return true
  end
  return false
end

function onDamage(_,entity,_,_,source)
	Isaac.ConsoleOutput("onDamage Triggered:\n")
  --Isaac.GetPlayer(0):FireTear(Isaac.GetPlayer(0).Position, Vector.FromAngle(90):Resized(100), false,false,false)
  
  -- get the player entity
  local player = Isaac.GetPlayer(0)
  local fireFrom = player.Position
  local fireDir = Vector.FromAngle(90):Resized(1)
  player:FireTear(fireFrom, fireDir, false,false,false)
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onDamage, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION , onInputRequest)
