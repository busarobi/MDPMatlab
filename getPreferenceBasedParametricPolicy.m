function policy = getPreferenceBasedParametricPolicy( environment, varargin )

policy.dispFlag = 0;
policy.epsilon = 0.01;
actionFuncName = 'linear';
policy.discreteAction = 0;
for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            policy.dispFlag = varargin{i + 1};
        case 'action_function'
            actionFuncName = varargin{i + 1};
        case 'epsilon'
            policy.epsilon = varargin{i + 1};
        case 'discrete_action'
            policy.discreteAction = varargin{i + 1};            
        otherwise
            disp(['Unknown parameter: ''' varargin{i} '''']);
    end
end




policy.params = rand( environment.sdim,1);

policy.getNextActionFunc = @getNextAction;
policy.getEpsilonGreedyActionFunc = @ getEpsilonGreedyAction;


switch (actionFuncName)
    case 'linear'
        policy.actionFunc = @ getLinearAction;
    case 'sigmoid'
        policy.actionFunc = @ getSigmoidAction;
    otherwise
        error( 'unknown action function' );
end


return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getSigmoidAction( policy, state, environment )

action.value = state.values(1:state.sdim) * policy.params;
action.value = 1/(1+exp(-action.value));

scale = environment.aUpperBound(1) - environment.aLowerBound(1);
action.value = action.value(1) * scale + environment.aLowerBound(1);

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getLinearAction( policy, state, environment )

action.value = state.values(1:state.sdim) * policy.params;

for i1 = 1:environment.adim
    action.value(i1) = min(environment.aUpperBound(i1),action.value(i1));
    action.value(i1) = max(environment.aLowerBound(i1),action.value(i1));
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getEpsilonGreedyAction(state, policy, environment )
if (rand()<policy.epsilon) 
    anum = policy.QFunction.anum;
    action.actionIdx = randi(anum);
else
    action = feval( policy.getNextActionFunc, state, policy, environment );
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getNextAction(state, policy, environment )
action = feval( policy.actionFunc, policy, state, environment );
[d, actionIdx] = min(sqrt( (action.value-environment.avalues).^2 ));
action.actionIdx = actionIdx;
if (policy.discreteAction)
    action.value = d;
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


