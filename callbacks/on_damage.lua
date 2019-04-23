-------------------------------
-------- DAMAGE EVENTS --------
-------------------------------
function onPlayerDamage(_,entity,_,_,source)

end

function onEnemyKilled(_, entity, _, source)
  if qLearning and not entity == Entity.ENTITY_PLAYER then
    return QIsaac.onEnemyKilled()
  end
end

-- bind the MC_ENTITY_TAKE_DMG callback for the Player to onPlayerDamage
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerDamage, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerDamage, EntityType.ENTITY_NPC)
