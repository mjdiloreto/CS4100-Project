require('mobdebug').start();             -- enable debugging checkpoints
StartDebug();                            -- enable debugging
local mod = RegisterMod("AI Final", 1);  -- register mod in game

-----------------------------------
-------- UTILITY FUNCTIONS --------
-----------------------------------

function import(filename)
  local _, err = pcall(require, filename)
  err = tostring(err)
  if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
    if string.match(err, "true") then
        err = "Error: require passed in config"
    end
    CPrint(err)
  end
end

function CPrint(str) 
  Isaac.ConsoleOutput(str.."\n")
end

-- retrieves the player userdata
function getPlayer()
  return Isaac.GetPlayer(0)
end

-- get the position of the player in-game
-- these coordinates are used for doing stuff in-game
function getPlayerPosition()
  return getPlayer().Position
end

-- get the position of the player on the screen
-- these coordinates are used for drawing to the screen
function getPlayerScreenPosition()
  return Isaac.WorldToScreen(getPlayerPosition())
end
  
--------------------------------
-------- PROJECT HEADER --------
--------------------------------
Isaac.ConsoleOutput("----------------------------------\n")
Isaac.ConsoleOutput("--- CS4100 Project Initialized ---\n")
Isaac.ConsoleOutput("----------------------------------\n")
Isaac.ConsoleOutput("\n")

modEnabled = false

import("levelSearch")
  
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
local timer = 0
local moveLeftAndRightEvery = 100
local moveLeftAndRightAgent = true

local isaacMessage = ""
local isaacMessageTimer = 0
local isaacMessageTimerInitValue = 0

-- sets the message to print under the player sprite for the given number of frames (duration)
function setIsaacMessage(message, duration)
  isaacMessage = message
  isaacMessageTimer = duration
  isaacMessageTimerInitValue = duration -- used to fade the text out
end

-- prints the isaacMessage under the player sprite for isaacMessageTimer frames
function printIsaacMessage()
  if isaacMessageTimer > 0 then
    local opacity = isaacMessageTimer / isaacMessageTimerInitValue
    local screenPos = getPlayerScreenPosition()
    Isaac.RenderText(isaacMessage, screenPos.X - string.len(isaacMessage) * 3, screenPos.Y, 1, 1, 1, opacity)
    isaacMessageTimer = isaacMessageTimer - 1
  end
end

-- code to be run every frame
function onRender()
  -- enable and disable the AI mod by pressing 'R' on your keyboard
  if Input.IsActionTriggered(ButtonAction.ACTION_RESTART, 0) then
    if modEnabled then
      modEnabled = false
      Isaac.ConsoleOutput("AI Mod Disabled\n")
      setIsaacMessage("AI Mod Disabled", 100)
    else
      modEnabled = true
      timer = 0
      Isaac.ConsoleOutput("AI Mod Enabled\n")
      setIsaacMessage("AI Mod Enabled", 100)
    end
  end
  
  -- print the isaacMessage
  printIsaacMessage()
  
  -- this agent moves left and then right every moveLeftAndRightEvery tics
  if moveLeftAndRightAgent then
    if timer % moveLeftAndRightEvery == 0 then
      if moveDirection == ButtonAction.ACTION_LEFT then
        moveDirection = ButtonAction.ACTION_RIGHT
      else
        moveDirection = ButtonAction.ACTION_LEFT
      end
      timer = 0
    end
    timer = timer + 1
  end
end

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every frame, which is why we are using it to check the input
mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)


-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every kill, which is why we are using it to check the last kill
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onKill)
