require("stack")

--[[
  Perform Depth-First search on the tree, testing each node with goal test.
  If unsuccessful, call callback on the node, then use succ to get the 
  successor nodes of this one, continuing in a DFS manner.
--]]
function dfs(tree, succ, goalTest, callback)
  log("DFS started")
  
  frontier = Stack:new({tree})
  
  log("DFS ended")
end
