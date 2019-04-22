QIsaac = {}
--shootDirection = ButtonAction.ACTION_SHOOTUP

--Duplicated functions
function getRoomWidth()
  return Game():GetRoom():GetGridWidth()
end

function getRoomHeight()
  return Game():GetRoom():GetGridHeight()
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

function getDistance(X1,X2,Y1,Y2)
  return math.sqrt((X1 - X2) * (X1 - X2) + (Y1 - Y2) * (Y1 - Y2))
end

function getDist(entity1, entity2)
  local X1 = entity1.Position.X
  local X2 = entity2.Position.X
  local Y1 = entity1.Position.Y
  local Y2 = entity2.Position.Y
  return getDistance(X1,X2,Y1,Y2)
end

function getEntityGridIndex(entity)
  return Game():GetRoom():GetClampedGridIndex(entity.Position)
end

function getPlayerIndex()
  return getEntityGridIndex(Game():GetPlayer(0))
end

function sameCol(e1, e2)
  return modulo(math.abs(getEntityGridIndex(e1) - getEntityGridIndex(e2)), getRoomWidth()) == 0
end
function sameRow(e1, e2)
  return math.abs(getEntityGridIndex(e1) - getEntityGridIndex(e2)) < getRoomWidth()
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
  
-- if line passes through P1 and P2, what is the dist to the point xy?
function distance(P1, P2, xy)
  x1 = P1.X
  y1 = P1.Y
  x2 = P2.X
  y2 = P2.Y
  x0 = xy.X
  y0 = xy.Y
  
  num = (y2-y1)*x0 - (x2-x1)*y0 + x2*y1 - y2*x1
  dem = (y2-y1)*(y2-y1) + (x2-x1)*(x2-x1)
  
  return math.abs(num) / math.sqrt(dem)
end

function getClosestEnemy()
  local enemies = getEnemies()
  local closestEnemy = nil
  local closestEnemyDist = 99999999
  local IsaacEntity = Game():GetPlayer(0)
  
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

function moveTo(index)
  directions = getDirectionsTo(getGridPos(index))
  directionIndex = 1
  goalTest = function () return false end
end

function legalActions()
  return {ButtonAction.ACTION_UP, ButtonAction.ACTION_DOWN, ButtonAction.ACTION_LEFT, ButtonAction.ACTION_RIGHT}
end

function getNextState(current, action)
  if action == ButtonAction.ACTION_UP then
    return current - getRoomWidth()
  elseif action == ButtonAction.ACTION_DOWN then
    return current + getRoomWidth()
  elseif action == ButtonAction.ACTION_LEFT then
    return current - 1
  elseif action == ButtonAction.ACTION_DOWN then
    return current + 1
  else  
    return current
  end
end

function getShootVectors(entity)
  local entityPosition = entity.Position
  local Xoffset = modulo(entityPosition.X, getRoomWidth())
  local leftmostX = entityPosition.X - Xoffset
  local rightmostX = leftmostX + getRoomWidth()
  local hShootVector = {{leftmostX, entity.Position.Y}, {rightmostX, entity.Position.Y}}
  
  local topmostY = 0 + Xoffset
  local bottommostY = (getRoomWidth() * getRoomHeight()) - getRoomWidth() + Xoffset
  local vShootVector = {{entityPosition.X, topmostY},{entityPosition.X, bottommostY}}
  
  return {hShootVector, vShootVector}
end

function printVectorLists(vectors)
  printVectors = {}
  for i, v in pairs(vectors) do
    for j, v0 in pairs(v) do
      printVectors = append(printVectors, Vector(v0[1], v0[2]))
    end
  end
  printAllGridIndices(printVectors)
end

function distanceEvaluation(current, action, nextState)
  local closenessThreshold = 100
  local currentPosn = getGridPos(current)
  local nextPosn = getGridPos(nextState)
  
  local enemies = getEnemies()
  local distToClosest = 9999999
  for idx, enemy in pairs(enemies) do
    local theDist = getDistance(nextPosn.X, enemy.Position.X, nextPosn.Y, enemy.Position.Y) 
    if theDist < distToClosest then
      distToClosest = theDist
    end
  end
  
  shootVectors = getShootVectors(Game():GetPlayer(0))
  printVectorLists(shootVectors)
  return (distToClosest - 10) 
end

function nextQPosition(thisState, evaluationFn) 
  local bestIndex = getPlayerIndex()
  local minVal = 999999999
  for idx, action in pairs(legalActions()) do
    local nextState = getNextState(thisState, action)
    local currVal = evaluationFn(thisState, action, nextState)
    if currVal < minVal then
      bestIndex = nextState
      minVal = currVal
    end
  end
  return bestIndex
end

function onUpdate()
  --reevaluateEnvironment()
  printAdjacentGridIndices()
  attack(getClosestEnemy())
  moveTo(nextQPosition(getPlayerIndex(), distanceEvaluation))
end

QIsaac.onUpdate = onUpdate
QIsaac.onInputRequest = onInputRequest
QIsaac.startQTraining = startQTraining
