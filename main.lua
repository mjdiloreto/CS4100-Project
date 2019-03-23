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

--[[ Write str to the Isaac Console --]]
function CPrint(str) 
  Isaac.ConsoleOutput(str.."\n")
end

--[[ Write str to file specified by config (or hardcoded) --]]
function log(str)
  -- TODO change this to write to a log file.
  CPrint(str)
end

--[[ Utility method for testing --]]
function equal(expected, result)
  -- TODO make this smart?
  return expected == result
end

--[[ Check membership of val in list --]]
function contains(list, val)
    for index, value in ipairs(list) do
        if value == val then
            return true
        end
    end

    return false
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
local moveDirectionX = ButtonAction.ACTION_LEFT
local moveDirectionY = nil

function onInputRequest(_, entity, inputHook, buttonAction)
  if modEnabled then
    if entity ~= nil then
      if inputHook == InputHook.GET_ACTION_VALUE then
        if buttonAction == moveDirectionX or buttonAction == moveDirectionY then
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
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerDamage, EntityType.ENTITY_PLAYER)

---------------------------------
-------- FREQUENT CHECKS --------
---------------------------------
local timer = 0
local moveLeftAndRightEvery = 100

local AgentType = { MoveLeftAndRight = 0, SnakeAgent = 1,  PointAndClick = 2 }
local agentType = AgentType.PointAndClick
local agentTypeString = "PointAndClick"

local isaacMessage = ""
local isaacMessageTimer = 0
local isaacMessageTimerInitValue = 0

local pointAndClickPos = nil
local pointAndClickThreshold = 10

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
function onStep()
  -- enable and disable the AI mod by pressing 'R' on your keyboard
  if Input.IsActionTriggered(ButtonAction.ACTION_RESTART, 0) then
    if modEnabled then
      modEnabled = false
      Isaac.ConsoleOutput("AI Mod Disabled\n")
      setIsaacMessage("AI Disabled (" .. agentTypeString .. ")", 100)
    else
      modEnabled = true
      timer = 0
      Isaac.ConsoleOutput("AI Mod Enabled\n")
      setIsaacMessage("AI Enabled (" .. agentTypeString .. ")", 100)
    end
  end
  
  -- print the isaacMessage
  printIsaacMessage()
  
  if modEnabled then
    -- this agent moves left and then right every moveLeftAndRightEvery tics
    if agentType == AgentType.MoveLeftAndRight then
      if timer % moveLeftAndRightEvery == 0 then
        if moveDirectionX == ButtonAction.ACTION_LEFT then
          moveDirectionX = ButtonAction.ACTION_RIGHT
        else
          moveDirectionX = ButtonAction.ACTION_LEFT
        end
        timer = 0
      end
      timer = timer + 1
    end
    
    -- this agent moves and shoots in the last move / shoot direction
    if agentType == AgentType.SnakeAgent then
      if Input.IsActionTriggered(ButtonAction.ACTION_LEFT, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, 0) then
        moveDirectionX = ButtonAction.ACTION_LEFT
        moveDirectionY = nil
        shootDirection = ButtonAction.ACTION_SHOOTLEFT
      elseif Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, 0) then
        moveDirectionX = ButtonAction.ACTION_RIGHT
        moveDirectionY = nil
        shootDirection = ButtonAction.ACTION_SHOOTRIGHT
      elseif Input.IsActionTriggered(ButtonAction.ACTION_UP, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, 0) then
        moveDirectionX = nil
        moveDirectionY = ButtonAction.ACTION_UP
        shootDirection = ButtonAction.ACTION_SHOOTUP
      elseif Input.IsActionTriggered(ButtonAction.ACTION_DOWN, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, 0) then
        moveDirectionX = nil
        moveDirectionY = ButtonAction.ACTION_DOWN
        shootDirection = ButtonAction.ACTION_SHOOTDOWN
      end
    end
    
    -- this agent moves to the point on the screen that you click!
    if agentType == AgentType.PointAndClick then
      shootDirection = nil
      moveDirectionX = nil
      moveDirectionY = nil
      if Input.IsMouseBtnPressed(0) then
        pointAndClickPos = Input.GetMousePosition(true)
      end
      if pointAndClickPos ~= nil then
        local mousePosScreen = Isaac.WorldToScreen(pointAndClickPos)
        Isaac.RenderText("X", mousePosScreen.X - 3, mousePosScreen.Y - 6, 1, 0, 0, 1)
        
        local playerPos =  getPlayerPosition()
        
        local xDistToClickPos = pointAndClickPos.X - playerPos.X
        local yDistToClickPos = pointAndClickPos.Y - playerPos.Y
        
        if math.abs(xDistToClickPos) > pointAndClickThreshold then
          if xDistToClickPos > 0 then
            moveDirectionX = ButtonAction.ACTION_RIGHT
            
          elseif xDistToClickPos < 0 then
            moveDirectionX = ButtonAction.ACTION_LEFT
          end
        end
        
        if math.abs(yDistToClickPos) > pointAndClickThreshold then
          if yDistToClickPos < 0 then
            moveDirectionY = ButtonAction.ACTION_UP
            
          elseif yDistToClickPos > 0 then
            moveDirectionY = ButtonAction.ACTION_DOWN
          end
        end
      end
    end
  end
end

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every frame, which is why we are using it to check the input
mod:AddCallback(ModCallbacks.MC_POST_RENDER, onStep)

-- called whenever you enter a room
function onRoomStart()
  pointAndClickPos = nil
end

-- bind the MC_POST_NEW_ROOM callback to onRender
-- this event is triggered every time you enter a room
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomStart)

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every kill, which is why we are using it to check the last kill
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onKill)
