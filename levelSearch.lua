require("stack")

--[[ Room -> List(GridEntityDoor)
  Find all the doors in the current room,
--]]
function getAllDoorsInRoom(room)
  doors = {}
  for slot, idx in pairs(DoorSlot) do
    door = room:GetDoor(idx)
    if door then
      table.insert(doors, door)
    end
  end
  return doors
end

--[[ Room -> List(RoomDescriptor)
  What are all the rooms we can get to in one step, starting from this one? 
--]]
function levelSucc(room)
  -- succDoors: List(GridEntityDoor)
  succDoors = getAllDoorsInRoom(room)
  
  local function doorToRoom(door)
    return Game():GetLevel():GetRoomByIdx(door.TargetRoomIndex)
  end
  
  succRooms = map(doorToRoom, succDoors)
  
  return succRooms
end

--[[ Room -> Boolean
  Is this room the boss room? 
--]]
function bossTest(room)
  return room:GetType() == RoomType.ROOM_BOSS
end

--[[ Room RoomDescriptor List(RoomDescriptor) (int -> nil) -> nil
  Move player from start to next, given that he took path to get from next to start.
  
  Params
  ------
  startRoom: Room - the room Isaac is in
  nextRoom: RoomDescriptor - important to note this is a different object, describing the Room Isaac should end in.
  pathToStart: List(RoomDescription) - The descriptions of the rooms Isaac visited in order to get from next to start.
  moveToAdjacent: int -> nil - Given the room index of a room adjacent to the current one, move Isaac to that room.
--]]
function interRoomTransition(startRoom, nextRoom, pathToStart, moveToAdjacent)
  -- TODO use the room navigation algorithm to get to the door
  local function roomDescToInt(roomDesc)
    return roomDesc.GridIndex -- might be GridIndex
  end
  
  lvl = Game():GetLevel()
  currentRoomIdx = lvl:GetCurrentRoomIndex()
  nextRoomIdx = roomDescToInt(nextRoom)
  path = map(roomDescToInt, pathToStart)
    
  while currentRoomIdx ~= nextRoomIdx do 
    successors = map(roomDescToInt, levelSucc(lvl:GetRoomByIdx(currentRoomIdx)))
    
    if contains(successors, nextRoomIdx) then
      currentRoomIdx = nextRoomIdx
    else
      currentRoomIdx = path.remove()
    end
      
    moveToAdjacent(currentRoomIdx)
  end
end

-- int -> nil
function teleportToRoom(idx)
  Game():GetLevel():ChangeRoom(idx)
end

-- Room RoomDescriptor List(RoomDescriptor) -> nil
function roomTransition(startRoom, nextRoom, pathToStart)
  -- TODO change teleport with whatever Kris makes to get Isaac to a room
  return interRoomTransition(startRoom, nextRoom, pathToStart, teleportToRoom)
end

--[[ Room (Room -> List(RoomDescriptor)) (Room -> Boolean) () -> nil
  Perform Depth-First search on the tree, testing each node with goal test.
  If unsuccessful, use succ to get the successor nodes of this one, 
  then call the transition function update state with how to get from current 
  to next room, continuing in a DFS manner. Return the path taken to get to goal, if found.
  
  Params
  ------
  tree: Room - The current room Isaac is in.
  succ: Room -> List(RoomDescriptor)
--]]
function dfs(tree, succ, goalTest, transition)
  log("DFS started")
  
  frontier = Stack:new()
  visited = {}
  
  -- Nodes are (room, path) tuples, where path represents the path taken so far to get there (For backtracking).
  current = {tree, {}}
  while current do
    if goalTest(current[1]) then
      log("DFS ended")
      return current[2]
    end
    
    for nextNode in succ(current[1]) do
      if not contains(visited, nextNode) then
        nextPath = append(current[2], current[1])
        frontier:push({nextNode, nextPath})
      end
    end
  
    temp = current
    current = frontier.pop()
    -- How do I _really_ get from this room to the next?
    transition(temp[1], current[1], current[2])
  end
  
  log("DFS ended")
  return {}
end

function getIsaacToBossRoom()
  return dfs(Game():GetRoom(), levelSucc, bossTest, roomTransition)
end

function sanity() 
  CPrint("yes yes no please")
end

-- mod compatability thing. Required by Isaac API
Vector:ForceError()
