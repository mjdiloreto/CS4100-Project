require('mobdebug').start();              -- enable debugging checkpoints
StartDebug();                             -- enable debugging
local mod = RegisterMod("AI Final", 1);   -- register mod in game

PriorityQueue = require("priority_queue") -- import priority queues

-- ENITY STUFF, we need to make sure to walk around slot machines, bums, and pickups
-- also we need to special case trap doors because the simplifyDirections method just ignores them as obstacles
-- also we need to let isaac know that he can break POOP and FIRE tiles if he wants to get through them
-- also we need to special case the on and off spikes, since isaac needs to go over them in some cases when they are off

-----------------------------------
-------- GLOBAL VARIABLES ---------
-----------------------------------
-- Level search. Instantiated by gameStart
local dfsIterator = nil

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

-- get the length of a table
function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Write str to the Isaac Console
function CPrint(str) 
  Isaac.ConsoleOutput(str.."\n")
end

-- Write str to file specified by config (or hardcoded)
function log(str)
  -- TODO change this to write to a log file.
  CPrint(str)
end

-- Utility method for testing
function equal(expected, result)
  -- TODO make this smart?
  return expected == result
end

-- Check membership of val in list
function contains(list, val)
    for index, value in ipairs(list) do
        if value == val then
            return true
        end
    end

    return false
end

-- Basic functional mapping
function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

-- return a new array equal to old plus one new element elt
function append(array, elt)
  newArr = {}
  for k, v in ipairs(array) do
    newArr[k] = v
  end
  newArr[#array+1] = elt
  return newArr
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

function getScreenPosition(pos)
  return Isaac.WorldToScreen(pos)
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
import("priority_queue")

--------------------------------
-------- DEBUG COMMANDS --------
--------------------------------
-- Define debug variables
local makeIsaacInvincible = true
local killAllEnemiesOnRoomStart = true

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
  
  dfsIterator = DfsIterator:new()
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


--------------------------
--- Using Level Search ---
--------------------------
local shouldDoLevelSearch = true

function searchLevel()
  if dfsIterator:hasNext() then
    levelSearchDoorPosition = dfsIterator:doNext()
    directions = getDirectionsTo(levelSearchDoorPosition)
  end
end

-- mod:AddCallback(ModCallbacks.MC_POST_UPDATE, searchLevel)

mod:AddCallback(ModCallbacks.MC_LAST_ENEMY_KILLED, searchLevel)


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

local AgentType = { MoveLeftAndRight = 0, SnakeAgent = 1,  DumbPointAndClick = 2, SmartPointAndClick = 3, SmartBoiAgent = 4 }
local agentType = AgentType.SmartBoiAgent
local agentTypeString = "SmartBoiAgent"
local directions = nil

local isaacMessage = ""
local isaacMessageTimer = 0
local isaacMessageTimerInitValue = 0

local pointAndClickPos = nil
local pointAndClickThreshold = 20

 -- position to go to returned from DFS level search
local levelSearchDoorPosition = nil


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

-- returns whether there is an unobstructed line of movement between
-- the given two grid indices
function isDirectPath(pos1, pos2)
  return Game():GetRoom():CheckLine(getGridPos(pos1), getGridPos(pos2), 0, 0, true, true)
end

function getPlayerGridIndex()
   return getGridIndex(getPlayerPosition())
end

function getGridIndex(pos)
   return Game():GetRoom():GetClampedGridIndex(pos)
end

function getGridPos(index)
   return Game():GetRoom():GetGridPosition(index)
end

function manhattanDist(gridIndex1, gridIndex2)
  local xPos1 = modulo(gridIndex1, getRoomWidth())
  local yPos1 = math.floor(gridIndex1 / getRoomWidth())
  local xPos2 = modulo(gridIndex2, getRoomWidth())
  local yPos2 = math.floor(gridIndex2 / getRoomWidth())
  return math.abs(xPos1 - xPos2) + math.abs(yPos1 - yPos2)
end

function modulo(a, b)
  return (a - math.floor(a/b)*b)
end

function getRoomWidth()
  return Game():GetRoom():GetGridWidth()
end

function getRoomHeight()
  return Game():GetRoom():GetGridHeight()
end

function getAdjacentGridIndices(gridIndex)
  local roomWidth = getRoomWidth()
  local roomHeight = getRoomHeight()
  local nextIndices = {}
  nextIndices[0] = gridIndex - roomWidth -- UP
  nextIndices[1] = gridIndex + roomWidth -- DOWN
  nextIndices[2] = gridIndex - 1         -- LEFT
  nextIndices[3] = gridIndex + 1         -- RIGHT
  return nextIndices
end

-- verify how this works with all entities
function isGridIndexBlocked(gridIndex)
  -- restrict out of bounds indices
  if (gridIndex > Game():GetRoom():GetGridSize() or gridIndex < 0) then return true end
  
  local gridEntity = Game():GetRoom():GetGridEntity(gridIndex)
  if (gridEntity ~= nil) then
    local t = gridEntity:GetType()
    return not (t == nil or t == 0 or t == 1 or t == 16 or t == 20)
  else
    return false
  end
end

 -- returns a string representing the enum type of the grid entity at the given index
function getGridType(gridIndex)
  local gridEntityType = Game():GetRoom():GetGridEntity(gridIndex):GetType()
  if gridEntityType == 0  then return "GRID_NULL" end
  if gridEntityType == 1  then return "GRID_DECORATION" end
  if gridEntityType == 2  then return "GRID_ROCK" end
  if gridEntityType == 3  then return "GRID_ROCKB" end
  if gridEntityType == 4  then return "GRID_ROCKT" end
  if gridEntityType == 5  then return "GRID_ROCK_BOMB" end
  if gridEntityType == 6  then return "GRID_ROCK_ALT" end
  if gridEntityType == 7  then return "GRID_PIT" end
  if gridEntityType == 8  then return "GRID_SPIKES" end
  if gridEntityType == 9  then return "GRID_SPIKES_ONOFF" end
  if gridEntityType == 10 then return "GRID_SPIDERWEB" end
  if gridEntityType == 11 then return "GRID_LOCK" end
  if gridEntityType == 12 then return "GRID_TNT" end
  if gridEntityType == 13 then return "GRID_FIREPLACE" end
  if gridEntityType == 14 then return "GRID_POOP" end
  if gridEntityType == 15 then return "GRID_WALL" end
  if gridEntityType == 16 then return "GRID_DOOR" end
  if gridEntityType == 17 then return "GRID_TRAPDOOR" end
  if gridEntityType == 18 then return "GRID_STAIRS" end
  if gridEntityType == 19 then return "GRID_GRAVITY" end
  if gridEntityType == 20 then return "GRID_PRESSURE_PLATE" end
  if gridEntityType == 21 then return "GRID_STATUE" end
  if gridEntityType == 22 then return "GRID_ROCK_SS" end
  return nil -- returns nil if it doesn't match a type
end

-- gets all entities in the room and puts them in a table list
function getAllRoomEntities()
  local entityList = Game():GetRoom():GetEntities()
  
  local entityGridList = {}
  local listIndex = 1
  local i = 0
  local iterating = true
  while iterating do
    local entity = entityList:Get(i)
    entityGridList[listIndex] = entity
    listIndex = listIndex + 1
    i = i + 1
    if (i >= entityList:__len()) then
      iterating = false
    end
  end
  return entityGridList
end

-- get a list of all game entities (not GRID entities) at the given grid index
function getAllRoomEntitiesAtIndex(gridIndex)
  local entityList = Game():GetRoom():GetEntities()
  
  local entityGridList = {}
  local listIndex = 1
  local i = 0
  local iterating = true
  while iterating do
    local entity = entityList:Get(i)
    if (getGridIndex(entity.Position)) == gridIndex then
      entityGridList[listIndex] = entity
      listIndex = listIndex + 1
    end
    i = i + 1
    if (i >= entityList:__len()) then
      iterating = false
    end
  end
  return entityGridList
end

-- returns whether an entity blocks your movement or not
-- should avoid these ones in the roomSearch problem
function entityBlocksMovement(entity)
  return (entity.Type == 5 and entity.Variant == 100) -- pedestal items
  or (entity.Type == 6) -- slot machines and bums
end
  
-- returns a string representing the enum type of the given game entity
function getEntityType(entity)
  
  local entityType = entity.Type
  local entityVariant = entity.Variant
  
  -- weird misc type that the game uses for random entities
  if entityType == 1000 then return "ENTITY_MISC" end
  
  -- filter bogus input
  if entityType < 0 or entityType > 225 then return nil end
  
  -- match type
  if entityType == 0   then return "ENTITY_NULL" end
  if entityType == 1   then return "ENTITY_PLAYER" end
  if entityType == 2   then return "ENTITY_TEAR" end
  if entityType == 3   then return "ENTITY_FAMILIAR" end
  if entityType == 4   then return "ENTITY_BOMBDROP" end
  
  -- there's a lot of different pickups lol
  if entityType == 5 then
    local pickupString = "ENTITY_PICKUP"
    local variantString = ""
    
    -- define variants
    if entityVariant == 20 then
      variantString = "COIN"
    elseif entityVariant == 40 then
      variantString = "BOMB"
    elseif entityVariant == 60 then
      variantString = "CHEST"
    elseif entityVariant == 69 then
      variantString = "BAG"
    elseif entityVariant == 30 then
      variantString = "KEY"
    elseif entityVariant == 100 then
      variantString = "PEDESTAL_ITEM"
    elseif entityVariant == 10 then
      variantString = "HEART"
    elseif entityVariant == 10 then
      variantString = "BUM"
    elseif entityVariant == 10 then
      variantString = "LOTTERY"
    end
    
    -- return string
    if variantString == "" then
      return pickupString
    else
      return pickupString .. "_" .. variantString
    end
  end
  
  if entityType == 6   then return "ENTITY_SLOT" end
  if entityType == 7   then return "ENTITY_LASER" end
  if entityType == 8   then return "ENTITY_KNIFE" end
  if entityType == 9   then return "ENTITY_PROJECTILE" end
  if entityType == 10  then return "ENTITY_GAPER" end
  if entityType == 11  then return "ENTITY_GUSHER" end
  if entityType == 12  then return "ENTITY_HORF" end
  if entityType == 13  then return "ENTITY_FLY" end
  if entityType == 14  then return "ENTITY_POOTER" end
  if entityType == 15  then return "ENTITY_CLOTTY" end
  if entityType == 16  then return "ENTITY_MULLIGAN" end
  if entityType == 17  then return "ENTITY_SHOPKEEPER" end
  if entityType == 18  then return "ENTITY_ATTACKFLY" end
  if entityType == 19  then return "ENTITY_LARRYJR" end
  if entityType == 20  then return "ENTITY_MONSTRO" end
  if entityType == 21  then return "ENTITY_MAGGOT" end
  if entityType == 22  then return "ENTITY_HIVE" end
  if entityType == 23  then return "ENTITY_CHARGER" end
  if entityType == 24  then return "ENTITY_GLOBIN" end
  if entityType == 25  then return "ENTITY_BOOMFLY" end
  if entityType == 26  then return "ENTITY_MAW" end
  if entityType == 27  then return "ENTITY_HOST" end
  if entityType == 28  then return "ENTITY_CHUB" end
  if entityType == 29  then return "ENTITY_HOPPER" end
  if entityType == 30  then return "ENTITY_BOIL" end
  if entityType == 31  then return "ENTITY_SPITY" end
  if entityType == 32  then return "ENTITY_BRAIN" end
  if entityType == 33  then return "ENTITY_FIREPLACE" end
  if entityType == 34  then return "ENTITY_LEAPER" end
  if entityType == 35  then return "ENTITY_MRMAW" end
  if entityType == 36  then return "ENTITY_GURDY" end
  if entityType == 37  then return "ENTITY_BABY" end
  if entityType == 38  then return "ENTITY_VIS" end
  if entityType == 39  then return "ENTITY_GUTS" end
  if entityType == 40  then return "ENTITY_KNIGHT" end
  if entityType == 41  then return "ENTITY_STONEHEAD" end
  if entityType == 42  then return "ENTITY_MONSTRO2" end
  if entityType == 43  then return "ENTITY_POKY" end
  if entityType == 44  then return "ENTITY_MOM" end
  if entityType == 45  then return "ENTITY_SLOTH" end
  if entityType == 46  then return "ENTITY_LUST" end
  if entityType == 47  then return "ENTITY_WRATH" end
  if entityType == 48  then return "ENTITY_GLUTTONY" end
  if entityType == 49  then return "ENTITY_GREED" end
  if entityType == 50  then return "ENTITY_ENVY" end
  if entityType == 51  then return "ENTITY_PRIDE" end
  if entityType == 52  then return "ENTITY_DOPLE" end
  if entityType == 53  then return "ENTITY_FLAMINGHOPPER" end
  if entityType == 54  then return "ENTITY_LEECH" end
  if entityType == 55  then return "ENTITY_LUMP" end
  if entityType == 56  then return "ENTITY_MEMBRAIN" end
  if entityType == 57  then return "ENTITY_PARA_BITE" end
  if entityType == 58  then return "ENTITY_FRED" end
  if entityType == 59  then return "ENTITY_EYE" end
  if entityType == 60  then return "ENTITY_SUCKER" end
  if entityType == 61  then return "ENTITY_PIN" end
  if entityType == 62  then return "ENTITY_FAMINE" end
  if entityType == 63  then return "ENTITY_PESTILENCE" end
  if entityType == 64  then return "ENTITY_WAR" end
  if entityType == 65  then return "ENTITY_DEATH" end
  if entityType == 66  then return "ENTITY_DUKE" end
  if entityType == 67  then return "ENTITY_PEEP" end
  if entityType == 68  then return "ENTITY_LOKI" end
  if entityType == 69  then return "ENTITY_FISTULA_BIG" end
  if entityType == 70  then return "ENTITY_FISTULA_MEDIUM" end
  if entityType == 71  then return "ENTITY_FISTULA_SMALL" end
  if entityType == 72  then return "ENTITY_BLASTOCYST_BIG" end
  if entityType == 73  then return "ENTITY_BLASTOCYST_MEDIUM" end
  if entityType == 74  then return "ENTITY_BLASTOCYST_SMALL" end
  if entityType == 75  then return "ENTITY_EMBRYO" end
  if entityType == 76  then return "ENTITY_MOMS_HEART" end
  if entityType == 77  then return "ENTITY_GEMINI" end
  if entityType == 78  then return "ENTITY_MOTER" end
  if entityType == 79  then return "ENTITY_FALLEN" end
  if entityType == 80  then return "ENTITY_HEADLESS_HORSEMAN" end
  if entityType == 81  then return "ENTITY_HORSEMAN_HEAD" end
  if entityType == 82  then return "ENTITY_SATAN" end
  if entityType == 83  then return "ENTITY_SPIDER" end
  if entityType == 84  then return "ENTITY_KEEPER" end
  if entityType == 85  then return "ENTITY_GURGLE" end
  if entityType == 86  then return "ENTITY_WALKINGBOIL" end
  if entityType == 87  then return "ENTITY_BUTTLICKER" end
  if entityType == 88  then return "ENTITY_HANGER" end
  if entityType == 89  then return "ENTITY_SWARMER" end
  if entityType == 90  then return "ENTITY_HEART" end
  if entityType == 91  then return "ENTITY_MASK" end
  if entityType == 92  then return "ENTITY_BIGSPIDER" end
  if entityType == 93  then return "ENTITY_ETERNALFLY" end
  if entityType == 94  then return "ENTITY_MASK_OF_INFAMY" end
  if entityType == 95  then return "ENTITY_HEART_OF_INFAMY" end
  if entityType == 96  then return "ENTITY_GURDY_JR" end
  if entityType == 97  then return "ENTITY_WIDOW" end
  if entityType == 98  then return "ENTITY_DADDYLONGLEGS" end
  if entityType == 99  then return "ENTITY_ISAAC" end
  if entityType == 100 then return "ENTITY_STONE_EYE" end
  if entityType == 101 then return "ENTITY_CONSTANT_STONE_SHOOTER" end
  if entityType == 102 then return "ENTITY_BRIMSTONE_HEAD" end
  if entityType == 103 then return "ENTITY_MOBILE_HOST" end
  if entityType == 104 then return "ENTITY_NEST" end
  if entityType == 105 then return "ENTITY_BABY_LONG_LEGS" end
  if entityType == 106 then return "ENTITY_CRAZY_LONG_LEGS" end
  if entityType == 107 then return "ENTITY_FATTY" end
  if entityType == 108 then return "ENTITY_FAT_SACK" end
  if entityType == 109 then return "ENTITY_BLUBBER" end
  if entityType == 110 then return "ENTITY_HALF_SACK" end
  if entityType == 111 then return "ENTITY_DEATHS_HEAD" end
  if entityType == 112 then return "ENTITY_MOMS_HAND" end
  if entityType == 113 then return "ENTITY_FLY_L2" end
  if entityType == 114 then return "ENTITY_SPIDER_L2" end
  if entityType == 115 then return "ENTITY_SWINGER" end
  if entityType == 116 then return "ENTITY_DIP" end
  if entityType == 117 then return "ENTITY_WALL_HUGGER" end
  if entityType == 118 then return "ENTITY_WIZOOB" end
  if entityType == 119 then return "ENTITY_SQUIRT" end
  if entityType == 120 then return "ENTITY_COD_WORM" end
  if entityType == 121 then return "ENTITY_RING_OF_FLIES" end
  if entityType == 122 then return "ENTITY_DINGA" end
  if entityType == 123 then return "ENTITY_OOB" end
  if entityType == 124 then return "ENTITY_BLACK_MAW" end
  if entityType == 125 then return "ENTITY_SKINNY" end
  if entityType == 126 then return "ENTITY_BONY" end
  if entityType == 127 then return "ENTITY_HOMUNCULUS" end
  if entityType == 128 then return "ENTITY_TUMOR" end
  if entityType == 129 then return "ENTITY_CAMILLO_JR" end
  if entityType == 130 then return "ENTITY_NERVE_ENDING" end
  if entityType == 131 then return "ENTITY_SKINBALL" end
  if entityType == 132 then return "ENTITY_MOM_HEAD" end
  if entityType == 133 then return "ENTITY_ONE_TOOTH" end
  if entityType == 134 then return "ENTITY_GAPING_MAW" end
  if entityType == 135 then return "ENTITY_BROKEN_GAPING_MAW" end
  if entityType == 136 then return "ENTITY_GURGLING" end
  if entityType == 137 then return "ENTITY_SPLASHER" end
  if entityType == 138 then return "ENTITY_GRUB" end
  if entityType == 139 then return "ENTITY_WALL_CREEP" end
  if entityType == 140 then return "ENTITY_RAGE_CREEP" end
  if entityType == 141 then return "ENTITY_BLIND_CREEP" end
  if entityType == 142 then return "ENTITY_CONJOINED_SPITTY" end
  if entityType == 143 then return "ENTITY_ROUND_WORM" end
  if entityType == 144 then return "ENTITY_POOP" end
  if entityType == 145 then return "ENTITY_RAGLING" end
  if entityType == 146 then return "ENTITY_FLESH_MOBILE_HOST" end
  if entityType == 147 then return "ENTITY_PSY_HORF" end
  if entityType == 148 then return "ENTITY_FULL_FLY" end
  if entityType == 149 then return "ENTITY_TICKING_SPIDER" end
  if entityType == 150 then return "ENTITY_BEGOTTEN" end
  if entityType == 151 then return "ENTITY_NULLS" end
  if entityType == 152 then return "ENTITY_PSY_TUMOR" end
  if entityType == 153 then return "ENTITY_FLOATING_KNIGHT" end
  if entityType == 154 then return "ENTITY_NIGHT_CRAWLER" end
  if entityType == 155 then return "ENTITY_DART_FLY" end
  if entityType == 156 then return "ENTITY_CONJOINED_FATTY" end
  if entityType == 157 then return "ENTITY_FAT_BAT" end
  if entityType == 158 then return "ENTITY_IMP" end
  if entityType == 159 then return "ENTITY_THE_HAUNT" end
  if entityType == 160 then return "ENTITY_DINGLE" end
  if entityType == 161 then return "ENTITY_MEGA_MAW" end
  if entityType == 162 then return "ENTITY_GATE" end
  if entityType == 163 then return "ENTITY_MEGA_FATTY" end
  if entityType == 164 then return "ENTITY_CAGE" end
  if entityType == 165 then return "ENTITY_MAMA_GURDY" end
  if entityType == 166 then return "ENTITY_DARK_ONE" end
  if entityType == 167 then return "ENTITY_ADVERSARY" end
  if entityType == 168 then return "ENTITY_POLYCEPHALUS" end
  if entityType == 169 then return "ENTITY_MR_FRED" end
  if entityType == 170 then return "ENTITY_URIEL" end
  if entityType == 171 then return "ENTITY_GABRIEL" end
  if entityType == 172 then return "ENTITY_THE_LAMB" end
  if entityType == 173 then return "ENTITY_MEGA_SATAN" end
  if entityType == 174 then return "ENTITY_MEGA_SATAN_2" end
  if entityType == 175 then return "ENTITY_ROUNDY" end
  if entityType == 176 then return "ENTITY_BLACK_BONY" end
  if entityType == 177 then return "ENTITY_BLACK_GLOBIN" end
  if entityType == 178 then return "ENTITY_BLACK_GLOBIN_HEAD" end
  if entityType == 179 then return "ENTITY_BLACK_GLOBIN_BODY" end
  if entityType == 180 then return "ENTITY_SWARM" end
  if entityType == 181 then return "ENTITY_MEGA_CLOTTY" end
  if entityType == 182 then return "ENTITY_BONE_KNIGHT" end
  if entityType == 183 then return "ENTITY_CYCLOPIA" end
  if entityType == 184 then return "ENTITY_RED_GHOST" end
  if entityType == 185 then return "ENTITY_FLESH_DEATHS_HEAD" end
  if entityType == 186 then return "ENTITY_MOMS_DEAD_HAND" end
  if entityType == 187 then return "ENTITY_DUKIE" end
  if entityType == 188 then return "ENTITY_ULCER" end
  if entityType == 189 then return "ENTITY_MEATBALL" end
  if entityType == 190 then return "ENTITY_PITFALL" end
  if entityType == 191 then return "ENTITY_MOVABLE_TNT" end
  if entityType == 192 then return "ENTITY_ULTRA_COIN" end
  if entityType == 193 then return "ENTITY_ULTRA_DOOR" end
  if entityType == 194 then return "ENTITY_CORN_MINE" end
  if entityType == 195 then return "ENTITY_HUSH_FLY" end
  if entityType == 196 then return "ENTITY_HUSH_GAPER" end
  if entityType == 197 then return "ENTITY_HUSH_BOIL" end
  if entityType == 198 then return "ENTITY_GREED_GAPER" end
  if entityType == 199 then return "ENTITY_MUSHROOM" end
  if entityType == 200 then return "ENTITY_POISON_MIND" end
  if entityType == 201 then return "ENTITY_STONEY" end
  if entityType == 202 then return "ENTITY_BLISTER" end
  if entityType == 203 then return "ENTITY_THE_THING" end
  if entityType == 204 then return "ENTITY_MINISTRO" end
  if entityType == 205 then return "ENTITY_PORTAL" end
  if entityType == 206 then return "ENTITY_TARBOY" end
  if entityType == 207 then return "ENTITY_FISTULOID" end
  if entityType == 208 then return "ENTITY_GUSH" end
  if entityType == 209 then return "ENTITY_LEPER" end
  if entityType == 210 then return "ENTITY_STAIN" end
  if entityType == 211 then return "ENTITY_BROWNIE" end
  if entityType == 212 then return "ENTITY_FORSAKEN" end
  if entityType == 213 then return "ENTITY_LITTLE_HORN" end
  if entityType == 214 then return "ENTITY_RAG_MAN" end
  if entityType == 215 then return "ENTITY_ULTRA_GREED" end
  if entityType == 216 then return "ENTITY_HUSH" end
  if entityType == 217 then return "ENTITY_HUSH_SKINLESS" end
  if entityType == 218 then return "ENTITY_RAG_MEGA" end
  if entityType == 219 then return "ENTITY_SISTERS_VIS" end
  if entityType == 220 then return "ENTITY_BIG_HORN" end
  if entityType == 221 then return "ENTITY_DELIRIUM" end
  if entityType == 222 then return "ENTITY_MATRIARCH" end
  if entityType == 223 then return "ENTITY_EFFECT" end
  if entityType == 224 then return "ENTITY_TEXT" end
  return nil -- returns nil if it doesn't match a type
end

function printAdjacentGridIndices()
  local yOffset = 10
  local n = getAdjacentGridIndices(getPlayerGridIndex())
  local screenPos = getPlayerScreenPosition()
  currentIndex = tostring(getPlayerGridIndex())
  upIndex = tostring(n[0])
  downIndex = tostring(n[1])
  leftIndex = tostring(n[2])
  rightIndex = tostring(n[3])
  upIsBlocked = isGridIndexBlocked(n[0])
  downIsBlocked = isGridIndexBlocked(n[1])
  leftIsBlocked = isGridIndexBlocked(n[2])
  rightIsBlocked = isGridIndexBlocked(n[3])
  Isaac.RenderText(currentIndex, screenPos.X - string.len(currentIndex) * 3, screenPos.Y - yOffset, 1, 1, 1, 1)
  if (upIsBlocked) then
    Isaac.RenderText(upIndex .. ": " .. getGridType(n[0]), screenPos.X - string.len(upIndex) * 3, screenPos.Y - yOffset - 30, 1, 0, 0, 1)
  else
    Isaac.RenderText(upIndex, screenPos.X - string.len(upIndex) * 3, screenPos.Y - yOffset - 30, 1, 1, 1, 1)
  end
  if (downIsBlocked) then
    Isaac.RenderText(downIndex .. ": " .. getGridType(n[1]), screenPos.X - string.len(downIndex) * 3, screenPos.Y - yOffset + 30, 1, 0, 0, 1)
  else
    Isaac.RenderText(downIndex, screenPos.X - string.len(downIndex) * 3, screenPos.Y - yOffset + 30, 1, 1, 1, 1)
  end
  if (leftIsBlocked) then
    Isaac.RenderText(getGridType(n[2]) .. ": " .. leftIndex, screenPos.X - string.len(getGridType(n[2]) .. ": " .. leftIndex) * 5 - 30, screenPos.Y - yOffset, 1, 0, 0, 1)
  else
    Isaac.RenderText(leftIndex, screenPos.X - string.len(leftIndex) * 3 - 30, screenPos.Y - yOffset, 1, 1, 1, 1)
  end
  if (rightIsBlocked) then
    Isaac.RenderText(rightIndex .. ": " .. getGridType(n[3]), screenPos.X - string.len(rightIndex) * 3 + 30, screenPos.Y - yOffset, 1, 0, 0, 1)
  else
    Isaac.RenderText(rightIndex, screenPos.X - string.len(rightIndex) * 3 + 30, screenPos.Y - yOffset, 1, 1, 1, 1)
  end
end

function aStarRoomSearch(index1, index2)
  local cost = 1
  local goalIndex = index2 -- our goal is to get from pos1 to pos2
  local openNodes = {}
  local closedNodes = {}
  local g = {}
  local pq  = PriorityQueue()
  
  local initialNode = {index1, {}} -- a tuple of value and path
  pq:put(initialNode, 0)
  g[index1] = 0
  
  while (not pq:empty()) do
    local topOfQueue = pq:pop()
    local currentIndex = topOfQueue[1]
    local pathToIndex = topOfQueue[2]
    -- goal test
    if (currentIndex == goalIndex) then
      return pathToIndex
    end
    if (not closedNodes[currentIndex] == true) then
      closedNodes[currentIndex] = true
      if (not isGridIndexBlocked(currentIndex)) then
        for indexInList, nextIndex in pairs(getAdjacentGridIndices(currentIndex)) do
          costToNextIndex = g[currentIndex] + cost + manhattanDist(nextIndex, goalIndex)
          if (not closedNodes[nextIndex] == true) then
            if (not openNodes[nextIndex] == true) then
               openNodes[nextIndex] = true
               pq:put({nextIndex, append(pathToIndex, nextIndex)}, costToNextIndex)
               g[nextIndex] = g[currentIndex] + cost
            end
          else
            if (costToNextIndex < g[nextIndex]) then
              -- pq:put({nextIndex, append(pathToIndex, nextIndex)}, costToNextIndex) -- update, not put
              g[nextIndex] = g[currentIndex] + cost
              openNodes[nextIndex] = false
            end
          end
        end
      end
    end
  end
  -- if there is no path between them, then return nil
  return nil
end

function aStarToPos(pos)
  return aStarRoomSearch(getGridIndex(getPlayerPosition()), getGridIndex(pos))
end

function convertListOfIndexToPos(indexList)
  local convertedList = {}
  for indexInList, nextIndex in pairs(indexList) do
    convertedList[indexInList] = getGridPos(nextIndex)
  end
  return convertedList
end

 -- reduce list of directions to only the directions that navigate around obstacles
function simplifyDirections(directionList)
  local simplifiedList = {}
  local currListIndex = 1
  local prevIndex = getGridIndex(getPlayerPosition())
  for indexInList, nextIndex in pairs(directionList) do
    if (not isDirectPath(prevIndex, nextIndex)) then
      -- set next valid move as the last one we could go to
      local lastValidMove = directionList[indexInList - 1]
      simplifiedList[currListIndex] = lastValidMove
      currListIndex = currListIndex + 1
      prevIndex = lastValidMove
    end
  end
  -- add last grid index in case the last move was valid
  simplifiedList[currListIndex] = directionList[tableLength(directionList)]
  return simplifiedList
end

-- returns a list of Vector indicating the simplest set of directions to get to the given pos
function getDirectionsTo(pos)
  return convertListOfIndexToPos(simplifyDirections(aStarToPos(pos)))
end

function printAllGridIndices(listOfDirections)
  for indexInList, nextPos in pairs(listOfDirections) do
    local screenPos = getScreenPosition(nextPos)
    Isaac.RenderText(tostring(getGridIndex(nextPos)), screenPos.X, screenPos.Y, 1, 1, 1, 1)
  end
end

function printAllGameEntities(listOfEntities)
  for indexInList, entity in pairs(listOfEntities) do
    local screenPos = getScreenPosition(entity.Position)
    Isaac.RenderText(tostring(getEntityType(entity)) .. " - " .. tostring(entity.Variant), screenPos.X, screenPos.Y, 1, 1, 1, 1)
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
        shootDirection = ButtonAction.ACTION_SHOOTRIGHT
      elseif Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, 0) then
        moveDirectionX = ButtonAction.ACTION_RIGHT
        moveDirectionY = nil
        shootDirection = ButtonAction.ACTION_SHOOTLEFT
      elseif Input.IsActionTriggered(ButtonAction.ACTION_UP, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, 0) then
        moveDirectionX = nil
        moveDirectionY = ButtonAction.ACTION_UP
        shootDirection = ButtonAction.ACTION_SHOOTDOWN
      elseif Input.IsActionTriggered(ButtonAction.ACTION_DOWN, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, 0) then
        moveDirectionX = nil
        moveDirectionY = ButtonAction.ACTION_DOWN
        shootDirection = ButtonAction.ACTION_SHOOTUP
      end
    end
    
    -- this agent moves directly to the point on the screen that you click!
    if agentType == AgentType.DumbPointAndClick then
      shootDirection = nil
      moveDirectionX = nil
      moveDirectionY = nil
      if Input.IsMouseBtnPressed(0) then
        pointAndClickPos = Input.GetMousePosition(true)
      end
      if pointAndClickPos ~= nil then
        -- setIsaacMessage("Path to Pos Clear? " .. tostring(checkLineToPointAndClickPos()) .. ", dist: " .. tostring(manhattanDist(getPlayerGridIndex(), getGridIndex(pointAndClickPos))), 100)
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
    
    -- this agent moves directly to the point on the screen that you click!
    if agentType == AgentType.SmartPointAndClick then
      shootDirection = nil
      moveDirectionX = nil
      moveDirectionY = nil
      if Input.IsMouseBtnPressed(0) then
        pointAndClickPos = Input.GetMousePosition(true)
        directions = getDirectionsTo(pointAndClickPos)
        directionIndex = 1
      end
      if pointAndClickPos ~= nil and directions ~= nil and directionIndex <= tableLength(directions) then
        local mousePosScreen = Isaac.WorldToScreen(pointAndClickPos)
        Isaac.RenderText("X", mousePosScreen.X - 3, mousePosScreen.Y - 6, 1, 0, 0, 1)
        
        -- print all of the grid indexes at their positions
        printAllGridIndices(directions)
        
        local playerPos =  getPlayerPosition()
        
        local xDistToNextPos = directions[directionIndex].X - playerPos.X
        local yDistToNextPos = directions[directionIndex].Y - playerPos.Y
        
        if math.abs(xDistToNextPos) > pointAndClickThreshold then
          if xDistToNextPos > 0 then
            moveDirectionX = ButtonAction.ACTION_RIGHT
            
          elseif xDistToNextPos < 0 then
            moveDirectionX = ButtonAction.ACTION_LEFT
          end
        end
        
        if math.abs(yDistToNextPos) > pointAndClickThreshold then
          if yDistToNextPos < 0 then
            moveDirectionY = ButtonAction.ACTION_UP
            
          elseif yDistToNextPos > 0 then
            moveDirectionY = ButtonAction.ACTION_DOWN
          end
        end
        
        if math.abs(xDistToNextPos) < pointAndClickThreshold and math.abs(yDistToNextPos) < pointAndClickThreshold then
          directionIndex = directionIndex + 1
        end
      end
    end
    
    --------------------------------------------------
    ------------------ SMART BOI ---------------------
    --------------------------------------------------
    if agentType == AgentType.SmartBoiAgent then
      shootDirection = nil
      moveDirectionX = nil
      moveDirectionY = nil
      if levelSearchDoorPosition ~= nil and directions ~= nil and directionIndex <= tableLength(directions) then
        local mousePosScreen = Isaac.WorldToScreen(pointAndClickPos)
        Isaac.RenderText("X", mousePosScreen.X - 3, mousePosScreen.Y - 6, 1, 0, 0, 1)
        
        -- print all of the grid indexes at their positions
        printAllGridIndices(directions)
        
        local playerPos =  getPlayerPosition()
        
        local xDistToNextPos = directions[directionIndex].X - playerPos.X
        local yDistToNextPos = directions[directionIndex].Y - playerPos.Y
        
        if math.abs(xDistToNextPos) > pointAndClickThreshold then
          if xDistToNextPos > 0 then
            moveDirectionX = ButtonAction.ACTION_RIGHT
            
          elseif xDistToNextPos < 0 then
            moveDirectionX = ButtonAction.ACTION_LEFT
          end
        end
        
        if math.abs(yDistToNextPos) > pointAndClickThreshold then
          if yDistToNextPos < 0 then
            moveDirectionY = ButtonAction.ACTION_UP
            
          elseif yDistToNextPos > 0 then
            moveDirectionY = ButtonAction.ACTION_DOWN
          end
        end
        
        if math.abs(xDistToNextPos) < pointAndClickThreshold and math.abs(yDistToNextPos) < pointAndClickThreshold then
          directionIndex = directionIndex + 1
        end
      end
    end
  end
  printAdjacentGridIndices()
  printAllGameEntities(getAllRoomEntities())
end

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every frame, which is why we are using it to check the input
mod:AddCallback(ModCallbacks.MC_POST_RENDER, onStep)

-- called whenever you enter a room
function onRoomStart()
  pointAndClickPos = nil
  directions = nil
  directionIndex = 1
end

-- bind the MC_POST_NEW_ROOM callback to onRender
-- this event is triggered every time you enter a room
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomStart)

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every kill, which is why we are using it to check the last kill
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onKill)
