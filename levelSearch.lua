require("stack")

function roomIndexToDoorPosition(goalIdx)
  room = Game():GetRoom()
  possibles = getAllDoorsInRoom(room)
  for slot, idx in pairs(DoorSlot) do
    door = room:GetDoor(idx)
    if door and door.TargetRoomIndex == goalIdx then
      return door.Position
    end
  end
end

--[[ Room -> List(GridEntityDoor)
  Find all the doors in the current room,
--]]
function getAllDoorsInRoom(room)
  doors = {}
  for slot, idx in pairs(DoorSlot) do
    door = room:GetDoor(idx)
    if door and
    (door.TargetRoomType == RoomType.ROOM_DEFAULT
      or door.TargetRoomType == RoomType.ROOM_BOSS
      or door.TargetRoomType == RoomType.ROOM_TREASURE) then
      table.insert(doors, door)
    end
  end
  return doors
end

--[[ int -> List(int)
  What are all the rooms we can get to in one step, starting from this one? 
  roomIdx - ignored input since we can assume the current room has that idx.
--]]
function levelSucc(roomIdx)
  -- succDoors: List(GridEntityDoor)
  succDoors = getAllDoorsInRoom(Game():GetRoom())
  
  local function doorToRoom(door)
    return Game():GetLevel():GetRoomByIdx(door.TargetRoomIndex)
  end
  
  local function doorToGridIndex(door)
    return door.TargetRoomIndex
  end
  
  succRooms = map(doorToGridIndex, succDoors)
  
  return succRooms
end

--[[ int -> Boolean
  Is this room the boss room? 
--]]
function bossTest(roomIdx)
  return Game():GetRoom():GetType() == RoomType.ROOM_BOSS
end

--[[ int int List(int) (int -> nil) -> nil
  Move player from start to next, given that he took path to get from next to start.
  
  Params
  ------
  startRoom: int - the room Isaac is in now.
  nextRoom: int - the GridIndex of the room Isaac should end up in
  pathToStart: List(int) - The indexes of the rooms Isaac visited in order to get from next to start.
  moveToAdjacent: int -> nil - Given the room index of a room adjacent to the current one, move Isaac to that room.
--]]
function interRoomTransition(state, moveToAdjacent)
  
  if not state.backupPath then return nil end
  
  local function roomDescToInt(roomDesc)
    return roomDesc.GridIndex
  end
  
  lvl = Game():GetLevel()
  
  if state.current[1] ~= state.nextRoom then
    successors = levelSucc(state.current[1])
    
    if contains(successors, state.nextRoom[1]) then
      state:resetMovePath()
      state.current = state.nextRoom
      return moveToAdjacent(state.nextRoom[1])
    else
      temp = table.remove(state.backupPath)
      state.current = {temp, append(state.current[2], state.current[1])}
      return moveToAdjacent(state.current[1])
    end
  else
    state:resetMovePath()
  end
end

-- int -> nil
function teleportToRoom(idx)
  Game():GetLevel():ChangeRoom(idx)
end

function identity(x)
  return x
end

-- int itn List(int) -> nil
function roomTransition(state)
  return interRoomTransition(state, identity)
end


--[[ A (A -> List(A)) (A -> Boolean) () -> nil
  Perform Depth-First search on the tree, testing each node with goal test.
  If unsuccessful, use succ to get the successor nodes of this one, 
  then call the transition function update state with how to get from current 
  to next room, continuing in a DFS manner. Return the path taken to get to goal, if found.
  
  Params
  ------
  tree: A - The starting node of search.
  succ: A -> List(A) - where can I go from my current node?
  goalTest: A -> Boolean - is the current node the goal?
  transition: A A -> nil - potentially use side-effects to make the transition between nodes _actually_ occur.
--]]
function dfs(tree, succ, goalTest, transition, state)
  if state.current then
    if goalTest(state.current[1]) then
      log("DFS ended")
      
      -- we made it to the end, so there's nowhere else to go.
      return nil
    end
    
    for i, nextNode in ipairs(succ(state.current[1])) do
      if not contains(map(function (state) return state[1] end, state.visited), nextNode) then
        nextPath = append(state.current[2], state.current[1])
        state.frontier:push({nextNode, nextPath})
      end
    end
  
    state.nextRoom = state.frontier:pop()
    
    doorPos = nil
    -- How do I _really_ get from this room to the next?
    if state.nextRoom then 
      state.backupPath = state.current[2]
      doorPos = transition(state)
    end
  
    -- You got visited son
    state.visited[#state.visited+1] = state.nextRoom
    return roomIndexToDoorPosition(doorPos)
  end
  
  return nil
end

function getIsaacToBossRoom(state)
  return dfs(Game():GetLevel():GetCurrentRoomIndex(), levelSucc, bossTest, roomTransition, state)
end

-----------------------------------
------------ ITERATOR -------------
-----------------------------------
DfsIterator = {}
DfsIterator.__index = DfsIterator

function DfsIterator:new()
  iterObj = {}
  setmetatable(iterObj, DfsIterator)
  
  iterObj.frontier = Stack:new()
  -- Nodes are (int, path) tuples, where path represents the path taken so far to get there (For backtracking).
  iterObj.current = {Game():GetLevel():GetCurrentRoomIndex(), {}}
  iterObj.visited = {current}
  
  -- If backtracking will take many steps, we need to iterate it.
  iterObj.backupPath = nil
  
  iterObj.transition = roomTransition
  
  return iterObj 
end

function DfsIterator:hasNext()
  return not bossTest()
end

function DfsIterator:doNext()
  self.currentRoom = Game():GetLevel():GetCurrentRoomIndex()
  intermediate = self.transition(self)
  if intermediate then return intermediate end
  return getIsaacToBossRoom(self)
end

function DfsIterator:resetMovePath()
  self.backupPath = nil
end

--TODO change signature of room transition, mutate strx
-- mod compatability thing. Required by Isaac API
Vector:ForceError()
