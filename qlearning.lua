from game import Directions, Agent, Actions

import random,util,time

function raiseNotDefined()
  error("not defined")
end

Agent = {}
Agent.__index = Agent
function Agent:getAction(state)
  raiseNotDefined()
end


ValueEstimationAgent = {}
setmetatable(ValueEstimationAgent, Agent)
ValueEstimationAgent.__index = ValueEstimationAgent

--[[Abstract agent which assigns values to (state,action)
Q-Values for an environment. As well as a value to a
state and a policy given respectively by,

V(s) = max_{a in actions} Q(s,a)
policy(s) = arg_max_{a in actions} Q(s,a)

Both ValueIterationAgent and QLearningAgent inherit
from this agent. While a ValueIterationAgent has
a model of the environment via a MarkovDecisionProcess
(see mdp.py) that is used to estimate Q-Values before
ever actually acting, the QLearningAgent estimates
Q-Values while acting in the environment.--]]

function ValueEstimationAgent:new(alpha, epsilon, gamma, numTraining)
  --[[
  Sets options, which can be passed in via the Pacman command line using -a alpha=0.5,...
  alpha    - learning rate
  epsilon  - exploration rate
  gamma    - discount factor
  numTraining - number of training episodes, i.e. no learning after these many episodes
  --]]
  
  self.alpha = alpha or 1.0
  self.epsilon = epsilon or 0.05
  self.discount = gamma or 0.8
  self.numTraining = numTraining or 10
end
  

function ValueEstimationAgent:getQValue(state, action)
  -- Should return Q(state,action)
  raiseNotDefined()
end

function ValueEstimationAgent:getValue(state)
  --[[
  What is the value of this state under the best action?
  Concretely, this is given by

  V(s) = max_{a in actions} Q(s,a)
  --]]
  
  raiseNotDefined()
end

function ValueEstimationAgent:getPolicy(state)
  --[[
  What is the best action to take in the state. Note that because
  we might want to explore, this might not coincide with getAction
  Concretely, this is given by

  policy(s) = arg_max_{a in actions} Q(s,a)

  If many actions achieve the maximal Q-value,
  it doesn't matter which is selected.
  --]]
  raiseNotDefined()
end

function ValueEstimationAgent:getAction(state)
  --[[
  state: can call state.getLegalActions()
  Choose an action and return it.
  --]]
  raiseNotDefined()
end


--[[
  Abstract Reinforcemnt Agent: A ValueEstimationAgent
  which estimates Q-Values (as well as policies) from experience
  rather than a model

  What you need to know:
  - The environment will call
  observeTransition(state,action,nextState,deltaReward),
  which will call update(state, action, nextState, deltaReward)
  which you should override.
  - Use self.getLegalActions(state) to know which actions
  are available in a state
  --]]
ReinforcementAgent = {}
setmetatable(ReinforcementAgent, ValueEstimationAgent)
ReinforcementAgent.__index = ReinforcementAgent
    
function ReinforcementAgent:update(state, action, nextState, reward)
  --[[  This class will call this function, which you write, after
        observing a transition and reward
  --]]
  raiseNotDefined()
end
  
function ReinforcementAgent:getLegalActions(state)
  --[[
    Get the actions available for a given
    state. This is what you should use to
    obtain legal actions for a state
  --]]
  return self.actionFn(state)
end
  
function ReinforcementAgent:observeTransition(state,action,nextState,deltaReward)
  --[[
    Called by environment to inform agent that a transition has
    been observed. This will result in a call to self.update
    on the same arguments

    NOTE: Do *not* override or call this function
  --]]
  self.episodeRewards += deltaReward
  self.update(state,action,nextState,deltaReward)
end

function ReinforcementAgent:startEpisode()
  --[[
    Called by environment when new episode is starting
  --]]
  self.lastState = nil
  self.lastAction = nil
  self.episodeRewards = 0.0
end

function ReinforcementAgent:stopEpisode()
  --[[
    Called by environment when episode is done
  --]]
  if self.episodesSoFar < self.numTraining then
    self.accumTrainRewards += self.episodeRewards
  else
    self.accumTestRewards += self.episodeRewards
  end
  self.episodesSoFar += 1
  if self.episodesSoFar >= self.numTraining then
    -- Take off the training wheels
    self.epsilon = 0.0    -- no exploration
    self.alpha = 0.0      -- no learning
  end
end
    

function ReinforcementAgent:isInTraining()
  return self.episodesSoFar < self.numTraining
end

function ReinforcementAgent:isInTesting()
  return not self.isInTraining()
end

function ReinforcementAgent:__init__(actionFn, numTraining, epsilon, alpha, gamma)
  --[[
  actionFn: Function which takes a state and returns the list of legal actions

  alpha    - learning rate
  epsilon  - exploration rate
  gamma    - discount factor
  numTraining - number of training episodes, i.e. no learning after these many episodes
  --]]
  if actionFn == nil then
    actionFn = function(state) state.getLegalActions() end
  end
  self.actionFn = actionFn
  self.episodesSoFar = 0
  self.accumTrainRewards = 0.0
  self.accumTestRewards = 0.0
  self.numTraining = numTraining or 100
  self.epsilon = epsilon or 0.5
  self.alpha = alpha or 0.5
  self.discount = gamma or 1
end

function ReinforcementAgent:setEpsilon(epsilon)
  self.epsilon = epsilon
end

function ReinforcementAgent:setLearningRate(alpha)
  self.alpha = alpha
end

function ReinforcementAgent:setDiscount(discount)
  self.discount = discount
end

function ReinforcementAgent:doAction(state,action)
  --[[
      Called by inherited class when
      an action is taken in a state
  --]]
  self.lastState = state
  self.lastAction = action
end

function ReinforcementAgent:observationFunction(state)
  --[[
      This is where we ended up after our last action.
      The simulation should somehow ensure this is called
  --]]
  if not (self.lastState == nil) then
    reward = state.getScore() - self.lastState.getScore()
    self.observeTransition(self.lastState, self.lastAction, state, reward)
  end
  
  return state
end

function ReinforcementAgent:registerInitialState(state)
  self.startEpisode()
  if self.episodesSoFar == 0 then
    Isaac.ConsoleOutput('Beginning %s episodes of Training', tostring(self.numTraining))
  end
end
