require('mobdebug').start();         -- enable debugging checkpoints
StartDebug();                        -- enable debugging
mod = RegisterMod("AI Final", 1);    -- register mod in game

---------------------------
-------- TODO LIST --------
---------------------------
--[[
BFS Level Search :
-- store room properties like the adjacent rooms, along with whether it is a boss room, treasure room, and if it contains
--     hearts or any other collectibles in it and then allow the goal to be finding an unvisited room or the boss room
-- if there are multiple unvisited doors then just go to the closest one

TEST CASES (SEEDS)
-- N8ERWR90 (has unreachable pedestal item and mandatory button on first floor)

NAVIGATE:
-- if you can't get a pedestal item, then just move on
-- if the doors are already open, ignore the pressure plates
-- pick up items on floor
-- don't pick up item if it is a heart or battery you can't consume
-- go into angel rooms
-- don't consider the spike blocks as enemies


aStar Room Search :
-- add cost for spider webs, chests, etc.
-- also we need to let isaac know that he can break POOP and FIRE tiles if he wants to get through them
-- also we need to special case the on and off spikes, since isaac needs to go over them in some cases when they are off
-- TODO nextValidGridIndices needs to be updated to deal with diagonal movement blocking cases
-- TODO increase cost of moving diagonally in aStarRoomSearch (maybe just bring back smoothing?)
-- TODO he kinda just walks into the pedestal forever if his starting position was on the pedestal
-- if you're flying, change the search to rage through objects

-- IF THERE ARE MULTIPLE PEDESTAL ITEMS AND ONE IS BLOCKED, CHOOSE THE OTHER
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
import("data_structures.stack")
import("data_structures.queue")
import("data_structures.priority_queue")

-- utility functions
import("utils.lua_utils")
import("utils.print_utils")
import("utils.isaac_utils")
import("utils.isaac_types")
import("utils.pedestal_items")

-- callback hooks
import("callbacks.on_game_start")
import("callbacks.on_level_start")
import("callbacks.on_room_start")
import("callbacks.on_damage") -- doesn't do anything yet, might want to use this for scoring the agent
import("callbacks.on_input_request")
import("callbacks.on_step")

-- AI implementations and drivers
import("ai.agents")
import("ai.room_search")
import("ai.level_search")
import("ai.navigator")

--------------------------------
-------- PROJECT HEADER --------
--------------------------------
CPrint("----------------------------------")
CPrint("--- CS4100 Project Initialized ---")
CPrint("----------------------------------")
CPrint("")

modEnabled = true
