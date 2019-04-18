import("qlearning")

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

function lockDoors(doors)
  for idx, door in pairs(doors) do
    door:Close(true)
  end
end

function spawnFly(x, y, spawner) 
  Isaac.Spawn(13,0,0,Vector(x,y),Vector(0,0), spawner)
end

function getEnemies() 
  entities = allEntities()
  enemies = {}
  i = 0
  n = entities:__len()
  while i < n do
    ent = entities:Get(i)
    if ent and ent:IsActiveEnemy() then
      enemies[i] = ent
    end
    i = i + 1
  end
  return enemies
end


function allEntities() 
  return Game():GetRoom():GetEntities()
end

function initRoomWithFlies() 
  entities = allEntities()
  Isaac.ExecuteCommand("spawn 13.0") -- spawn a fly as a ref.
  firstFly = entities:Get(entities:__len())
  spawnFly(0,0, firstFly)
  spawnFly(1000,1000, firstFly)
  spawnFly(1000,0, firstFly)
  spawnFly(0,1000, firstFly)
end

function startQTraining()
  CPrint("Q training started")
  Isaac.ExecuteCommand("debug 10") -- stop killing

  lockDoors(getAllDoorsInRoom(Game():GetRoom()))
  initRoomWithFlies()
  enemies = getEnemies()
end