function policy = getSARSAPolicy( QFunction, varargin )

policy.QFunction = QFunction;

policy.epsilon = 0.01; % epsilon for epsilon greedy policy
policy.alpha = 0.5; % learning rate
policy.gamma = 1.0; % discount factor
policy.lambda = 0.95; % eligibility trace
policy.dispFlag = 0;

for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            policy.dispFlag = varargin{i + 1};
        case 'alpha'
            policy.alpha = varargin{i + 1};
        case 'gamma'
            policy.gamma = varargin{i + 1};
        case 'lambda'
            policy.lambda = varargin{i + 1};
        case 'epsilon'
            policy.epsilon = varargin{i + 1};
        otherwise
            disp(['Unknown parameter: ''' varargin{i} '''']);
    end
end



policy.getNextActionFunc = @getNextAction;
policy.updateQFunctionFunc = @ updateQFunction;
policy.getEpsilonGreedyActionFunc = @ getEpsilonGreedyAction;
policy.clearTraceFunc = @ clearEligibilityTrace;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function policy = clearEligibilityTrace( policy )
policy.QFunction = feval( policy.QFunction.clearEligibilityTraceFunc, policy.QFunction );
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function policy = updateQFunction( state, action, nextstate, nextaction, reward, policy )
%delta  =  ( r + gamma * Q(sp,ap) ) - Q(s,a);
value = feval( policy.QFunction.getQValueFunc, state, action, policy.QFunction);
nextvalue = feval( policy.QFunction.getQValueFunc, nextstate, nextaction, policy.QFunction);
delta = ( reward + policy.gamma * nextvalue ) - value;
% fprintf( 1, '%f\n', delta );
policy.QFunction = feval( policy.QFunction.updateFunc, state, action, policy.alpha, delta, policy.gamma, policy.lambda, policy.QFunction );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getEpsilonGreedyAction(state, policy, environment )
if (rand()<policy.epsilon) 
    anum = policy.QFunction.anum;
    action.actionIdx(1) = randi(anum);
else
    action = feval( policy.QFunction.getBestActionFunc, state, policy.QFunction );
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getNextAction(state, policy, environment )

action = feval( policy.QFunction.getBestActionFunc, state, policy.QFunction );

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

