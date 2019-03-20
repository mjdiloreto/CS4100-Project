require('mobdebug').start();             -- enable debugging checkpoints
StartDebug();                            -- enable debugging
local mod = RegisterMod("AI Final", 1);  -- register mod in game

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
  
--------------------------------
-------- PROJECT HEADER --------
--------------------------------
Isaac.ConsoleOutput("----------------------------------\n")
Isaac.ConsoleOutput("--- CS4100 Project Initialized ---\n")
Isaac.ConsoleOutput("----------------------------------\n")
Isaac.ConsoleOutput("\n")

modEnabled = true

--------------------------------
-------- DEBUG COMMANDS --------
--------------------------------
-- Define debug variables
local makeIsaacInvincible = true
local killAllEnemiesOnRoomStart = false

function onGameStarted()
  Isaac.ConsoleOutput("### New Game Started ###\n")
  
  -- Isaac takes damage but his health never decreases
  if makeIsaacInvincible then
    Isaac.ExecuteCommand("debug 3")
  end
  
  -- Make all enemies in room die when entering the room
  if killAllEnemiesOnRoomStart then
    Isaac.ExecuteCommand("debug 10")
  end
  
  -- print variables to console
  Isaac.ConsoleOutput(string.format("makeIsaacInvincible = %s\n", tostring(makeIsaacInvincible)))
  Isaac.ConsoleOutput(string.format("killAllEnemiesOnRoomStart = %s\n", tostring(killAllEnemiesOnRoomStart)))
end

-- bind the MC_POST_GAME_STARTED callback to onGameStarted
-- this event is called when a new game is started or a game is loaded from a save state
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStarted)

------------------------------------
-------- PROGRAMMATIC INPUT --------
------------------------------------
local shootDirection = ButtonAction.ACTION_SHOOTUP
local moveDirection = ButtonAction.ACTION_LEFT

function onInputRequest(_, entity, inputHook, buttonAction)
  if modEnabled then
    if entity ~= nil then
      if inputHook == InputHook.GET_ACTION_VALUE then
        if buttonAction == moveDirection then
          return 1.0
        end
        if buttonAction == shootDirection then
          return 1.0
        end
        return nil
      elseif inputHook == InputHook.IS_ACTION_PRESSED then
        if buttonAction == shootDirection then
          return true
        end
      elseif inputHook == InputHook.IS_ACTION_TRIGGERED then
        -- do something here?
      end
      return nil
    end
  end
end

-- bind the MC_INPUT_ACTION callback to onInputRequest
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, onInputRequest)

-------------------------------
-------- DAMAGE EVENTS --------
-------------------------------
function onPlayerDamage(_,entity,_,_,source)
	Isaac.ConsoleOutput("onDamage Triggered:\n")
end

-- bind the MC_ENTITY_TAKE_DMG callback for the Player to onPlayerDamage
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onDamage, EntityType.ENTITY_PLAYER)

---------------------------------
-------- FREQUENT CHECKS --------
---------------------------------
function onRender()
  -- enable and disable the AI mod by pressing 'R' on your keyboard
  if Input.IsActionTriggered(ButtonAction.ACTION_RESTART, 0) then
    if modEnabled then
      modEnabled = false
      Isaac.ConsoleOutput("AI Mod Disabled\n")
    else
      modEnabled = true
      Isaac.ConsoleOutput("AI Mod Enabled\n")
    end
  end
end

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every frame, which is why we are using it to check the input
mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)

