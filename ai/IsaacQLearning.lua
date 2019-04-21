QIsaac = {}
--shootDirection = ButtonAction.ACTION_SHOOTUP

--Duplicated functions
function getRoomWidth()
  return Game():GetRoom():GetGridWidth()
end

function modulo(a, b)
  return (a - math.floor(a/b)*b)
end

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
-- end duplicated functions

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

  lockDoors(getAllDoorsInRoom(Game():GetRoom()))
  initRoomWithFlies()
end

function getDist(entity1, entity2)
  X1 = entity1.Position.X
  X2 = entity2.Position.X
  Y1 = entity1.Position.Y
  Y2 = entity2.Position.Y
  return math.sqrt((X1 - X2) * (X1 - X2) + (Y1 - Y2) * (Y1 - Y2))
end
  

function getGridIndex(entity)
  return Game():GetRoom():GetClampedGridIndex(entity.Position)
end

function sameCol(e1, e2)
  return modulo(math.abs(getGridIndex(e1) - getGridIndex(e2)), getRoomWidth()) == 0
end
function sameRow(e1, e2)
  return math.abs(getGridIndex(e1) - getGridIndex(e2)) < getRoomWidth()
end
  
function setShootDirection(player, entity)
  IsaacX = player.Position.X
  IsaacY = player.Position.Y
  entityX = entity.Position.X
  entityY = entity.Position.Y
  
  if sameCol(player, entity) then
    if IsaacY < entityY then
      shootDirection = ButtonAction.ACTION_SHOOTDOWN
    else
      shootDirection = ButtonAction.ACTION_SHOOTUP
    end
  elseif sameRow(player, entity) then
    if IsaacX < entityX then
      shootDirection = ButtonAction.ACTION_SHOOTRIGHT
    else
      shootDirection = ButtonAction.ACTION_SHOOTLEFT
    end
  end
end

function attack(entity)
  setShootDirection(Game():GetPlayer(0), entity)
  
end

-- copy-pasta from main
function onInputRequest(_, entity, inputHook, buttonAction)
  if entity ~= nil then
    if inputHook == InputHook.GET_ACTION_VALUE then
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
  
function getClosestEnemy()
  enemies = getEnemies()
  closestEnemy = nil
  closestEnemyDist = 99999999
  IsaacEntity = Game():GetPlayer(0)
  
  --Todo find enemies hittable
  --Todo given hittable enemy, what dir to fire, and then fire
  for idx, enemy in pairs(enemies) do
    between = getDist(enemy, IsaacEntity)
    if enemy and (between < closestEnemyDist) then
      closestEnemy = enemy
      closestEnemyDist = between
    end
  end
  
  return closestEnemy
end

function onUpdate()
  --reevaluateEnvironment()
  attack(getClosestEnemy())
  --moveTo(nextQPosition())
end

QIsaac.onUpdate = onUpdate
QIsaac.onInputRequest = onInputRequest
QIsaac.startQTraining = startQTraining
