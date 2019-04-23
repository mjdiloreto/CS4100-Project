
function onLevelStart()
  visitedRooms = {}
  updateVisitedRooms()
  
  if qLearning then
    QIsaac.startQTraining()
  end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onLevelStart)
