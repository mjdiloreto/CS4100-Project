require('mobdebug').start();              -- enable debugging checkpoints
StartDebug();                             -- enable debugging
mod = RegisterMod("AI Final", 1);   -- register mod in game

---------------------------
-------- TODO LIST --------
---------------------------
--[[
aStar Room Search :
-- add cost for spider webs, chests, etc.
-- also we need to let isaac know that he can break POOP and FIRE tiles if he wants to get through them
-- also we need to special case the on and off spikes, since isaac needs to go over them in some cases when they are off
-- TODO nextValidGridIndices needs to be updated to deal with diagonal movement blocking cases
-- TODO increase cost of moving diagonally in aStarRoomSearch
]]

-------------------------
-------- IMPORTS --------
-------------------------

-- Write str to the Isaac Console
function CPrint(str) 
  Isaac.ConsoleOutput(str.."\n")
end

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

-- data structures
import("stack")
import("priority_queue")

-- utility functions
import("lua_utils")
import("print_utils")
import("isaac_utils")
import("isaac_types")
import("pedestal_items")

-- callback hooks
import("on_game_start")
import("on_level_start")
import("on_room_start")
import("on_damage") -- doesn't do anything yet, might want to use this for scoring the agent
import("on_input_request")
import("on_step")

-- AI implementations and drivers
import("agents")
import("room_search")
import("navigator")

-----------------------------------
-------- GLOBAL VARIABLES ---------
-----------------------------------

-- Level search. Instantiated by gameStart
local directions = nil
local goalTest = nil

--------------------------------
-------- PROJECT HEADER --------
--------------------------------
CPrint("----------------------------------")
CPrint("--- CS4100 Project Initialized ---")
CPrint("----------------------------------")
CPrint("")

modEnabled = true

visitedRooms = {}
roomStack = Stack:new()
initialRoom = nil -- a triple of roomIndex, door, and path
currentPath = Stack:new()

function dfsToNextRoom()
  while not roomStack:isEmpty() do
    local topOfStack = roomStack:pop()
    local currentRoom = topOfStack[1]
    local pathToRoom = topOfStack[2]
    if (not visitedRooms[currentRoom]) then
      visitedRooms[currentRoom] = true
      for _, nextDoor in pairs(getGoodDoors()) do
        local nextRoomIndex = getTargetRoomIndex(nextDoor)
        if (not visitedRooms[nextRoomIndex]) then
          roomStack:push({nextRoomIndex, append(pathToRoom, nextRoomIndex)})
        end
      end
    end
    -- return the door to go to, accounting for the fact that
    -- this room must be the previous room on the backtracking path
    -- if we are not exploring a new node here
    return getDoorTo(roomStack:peek()[1]).Position
  end
end