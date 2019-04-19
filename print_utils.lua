--[[
  print_utils.lua
 
  Utility functions for printing debug in formation to the screen.
 
]]


-------------------------------
------- PRINT TO SCREEN -------
-------------------------------
local isaacMessage = ""
local isaacMessageTimer = 0
local isaacMessageTimerInitValue = 0

function printCentered(str, x, y, r, g, b, opacity)
  Isaac.RenderText(str, x - string.len(str) * 3, y, r, g, b, opacity)
end

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
    printCentered(isaacMessage, screenPos.X, screenPos.Y, 1, 1, 1, opacity)
    isaacMessageTimer = isaacMessageTimer - 1
  end
end

function printAdjacentGridIndices()
  currentIndex = tostring(getPlayerGridIndex())
  
  for listIndex, gridIndex in pairs(getAllAdjacentGridIndices(getPlayerGridIndex())) do
    local gridIndexIsBlocked = isGridIndexBlocked(gridIndex)
    local gridPos = getScreenPosition(getGridPos(gridIndex))
    local r = 1
    local g = 1
    local b = 1
    if gridIndexIsBlocked then
      g = 0
      b = 0
    end
    printCentered(tostring(gridIndex), gridPos.X, gridPos.Y, r, g, b, 1)
  end
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
    local entityString = tostring(getEntityType(entity))
    printCentered(entityString, screenPos.X, screenPos.Y, 1, 1, 1, 1)
  end
end

function printNaiveDFS()
  local visitedRoomString = "Visited Rooms: "
  for room, hasVisited in pairs(visitedRooms) do
    visitedRoomString = visitedRoomString .. tostring(room) .. ", "
  end
  Isaac.RenderText(visitedRoomString, 10, 80, 1, 1, 1, 1)
end

function printDFS()
  local currentRoomIndex = "currentRoom = " .. tostring(getCurrentRoom())
  Isaac.RenderText("LEVEL SEARCH", 100, 70, 1, 1, 1, 1)
  Isaac.RenderText(currentRoomIndex, 100, 100, 1, 1, 1, 1)
  local topOfRoomStack = "top of RoomStack = " .. tostring(roomStack:peek()[1])
  Isaac.RenderText(topOfRoomStack, 100, 130, 1, 1, 1, 1)
end
