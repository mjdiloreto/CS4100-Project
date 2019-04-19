------------------------------------------------------------------------
-- THIS IS WHERE WE CHOOSE WHERE TO GO NEXT AND UPDATE OUR DIRECTIONS --
------------------------------------------------------------------------
directions = nil
goalTest = nil

function navigate()
  -- if we haven't tried to find the path yet
  if directions == nil then
    
    -- obviously prioritize beating the game
    local trophy = getTrophy()
    if (trophy) then
      directions = getDirectionsTo(trophy.Position)
      directionIndex = 1
      goalTest = function () return false end
    end
    
    -- if there are enemies in the room fight them
    if (not noEnemies()) then
      return
    end
     
    local pressurePlates = getUnpressedPressurePlates()
    if (#pressurePlates > 0) then
      directions = getDirectionsTo(getGridPos(getClosestFromIndices(pressurePlates)))
      directionIndex = 1
      
      -- we have reached our button when there is one less button
      goalTest = function () return #getUnpressedPressurePlates() == #pressurePlates - 1 end
      return
    end
    
    -- if there are pedestal items in the room, get those first
    local pedestalItems = getPassivePedestalItems()
    if (#pedestalItems > 0) then
      directions = getDirectionsTo(pedestalItems[1].Position)
      directionIndex = 1
      goalTest = function () return #getPassivePedestalItems() == 0 end
      return
    end
    
    -- if there are no enemies then advance to the next room
    if (not isBossRoom() and noEnemies()) then
      directions = getDirectionsTo(getNextUnvisitedDoor().Position)
      directionIndex = 1
      goalTest = function () return false end
      return
    end
    
    -- if there are normal items in the room, get them next
    
    -- if there is a trapdoor to the next floor, go there next
    local trapDoor = getTrapDoor()
    if (trapDoor) then
      -- if trap door is closed, wait until it is open in another position
      if trapDoor:GetSaveState().State == 0 then
        directions = getDirectionsTo(getGridPos(getGridIndex(getTrapDoor().Position) - 1 - getRoomWidth()))
        directionIndex = 1
        goalTest = function () return getTrapDoor():GetSaveState().State == 1 end
        return
      end
      if trapDoor:GetSaveState().State == 1 then
        directions = getDirectionsTo(getTrapDoor().Position)
        directionIndex = 1
        goalTest = function () return false end
        return
      end
    end
  end
end

-- callback function, happens every three frames or so
function onUpdate()
  navigate()
end

-- set callback in game
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)