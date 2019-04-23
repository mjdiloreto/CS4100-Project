QIsaac = {}

function getRealRoomWidth()
  return Game():GetRoom():GetBottomRightPos().X
end

function getGridPosition(posn)
  return Game():GetRoom():GetGridPosition(posn)
end

function getRealRoomHeight()
  return Game():GetRoom():GetBottomRightPos().Y
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
  local fly = Isaac.Spawn(13,0,0,Vector(x,y),Vector(0,0), spawner)
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
  
  local function onFlyDamage(_, entity, damage)
    if entity and (damage >= entity.HitPoints) then
      spawnFly(0,0, firstFly)
    end
    return true
  end
  
  mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onFlyDamage, EntityType.ENTITY_FLY)
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

function getClosestEnemy(posn)
  local enemies = getEnemies()
  local closestEnemy = nil
  local closestEnemyDist = 99999999
  --local IsaacEntity = Game():GetPlayer(0)
  
  for idx, enemy in pairs(enemies) do
    between = getDistance(enemy.Position.X, posn.X, enemy.Position.Y, posn.Y)
    if between < closestEnemyDist then
      closestEnemy = enemy
      closestEnemyDist = between
    end
  end
  
  return closestEnemy, closestEnemyDist
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
  elseif action == ButtonAction.ACTION_RIGHT then
    return current + 1
  else  
    return current
  end
end

function getShootVectors(entity)
  local hShootVector = {{0, entity.Position.Y}, {getRealRoomWidth(), entity.Position.Y}}
  local vShootVector = {{entity.Position.X, 0},{entity.Position.X, getRealRoomHeight()}}
  
  return {hShootVector, vShootVector}
end

function printVectorLists(vectors)
  printVecs = {}
  for i, v in pairs(vectors) do
    for j, v0 in pairs(v) do
      printVecs = append(printVecs, Vector(v0[1], v0[2]))
    end
  end
  
  printAllGridIndices(printVecs)
end

function distanceEvaluation(current, action, nextState)
  local closenessThreshold = 100
  local currentPosn = getGridPos(current)
  local nextPosn = getGridPos(nextState)
  
  local _, distToClosest = getClosestEnemy(nextPosn)
  
  shootVectors = getShootVectors(Game():GetPlayer(0))
  
  return 999/distToClosest
end

function nextQPosition(thisState, evaluationFn) 
  local bestIndex = getPlayerIndex()
  local bestVal = 0
  for idx, action in pairs(legalActions()) do
    local nextState = getNextState(thisState, action)
    local currVal = evaluationFn(thisState, action, nextState)
    if currVal > bestVal then
      bestIndex = nextState
      bestVal = currVal
    end
  end
  return bestIndex
end

function onUpdate()
  --reevaluateEnvironment()
  attack(getClosestEnemy(Game():GetPlayer(0).Position))
  moveTo(nextQPosition(getPlayerIndex(), distanceEvaluation))
end

function onRender()
  shootVectors = getShootVectors(Game():GetPlayer(0))
  printVectorLists(shootVectors)
end

function onEnemyKilled() 
end

QIsaac.onUpdate = onUpdate
QIsaac.onInputRequest = onInputRequest
QIsaac.startQTraining = startQTraining
QIsaac.onRender = onRender
QIsaac.onEnemyKilled = onEnemyKilled