function setInitialLevelSearchParams()
  visitedRooms = {}
  roomStack = Stack:new()
  initialRoom = {getCurrentRoom(), {}}
  roomStack:push(initialRoom)
end

function onLevelStart()
  setInitialLevelSearchParams()
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onLevelStart)
