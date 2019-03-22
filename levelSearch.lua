require("stack")

function levelSucc(room)
end

function bossTest(room)
end

--[[
  Perform Depth-First search on the tree, testing each node with goal test.
  If unsuccessful, use succ to get the successor nodes of this one, 
  then call the transition function update state with how to get from current 
  to next room, continuing in a DFS manner. Return the path taken to get to goal, if found.
--]]
function dfs(tree, succ, goalTest, transition)
  log("DFS started")
  
  frontier = Stack:new()
  visited = {}
  
  -- Nodes are (room, path) tuples, where path represents the path taken so far to get there (For backtracking).
  current = {tree, {}}
  while current do
    if goalTest(current[0]) then
      log("DFS ended")
      return current[1]
    end
    
    for nextNode in succ(current[0]) do
      if not contains(visited, nextNode) then
        nextPath = current[1] + current[0]
        frontier:push({nextNode, nextPath})
      end
    end
  
    temp = current
    current = frontier.pop()
    -- How do I _really_ get from this room to the next?
    transition(temp[0], current[0], current[1])
  end
  
  log("DFS ended")
  return {}
end

-- mod compatability thing. Required by Isaac API
Vector:ForceError()