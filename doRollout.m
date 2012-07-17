%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cumReward, varargout] = doRollout( policy, environment )

state = feval(environment.initialState);
action = feval( policy.getNextActionFunc, state, policy, environment );

if (nargout>2)
    histories = cell(environment.episodeLength, 1 );
    histories{1} = state;
    histories{1}.action = action;    
else
    histories = {};
end

cumReward = 0;
for i1 = 2:environment.episodeLength+1
    %fprintf( 1, '%d\n', i1);
    %do the selected action and get the next state
    nextstate = feval(environment.transitionFunc, state, action, environment );
    nextaction = feval( policy.getNextActionFunc, nextstate, policy, environment );
    
    
    % observe the reward at state newstate and the final state flag
    reward = feval(environment.rewardFunc, state, nextstate, environment );
    cumReward = cumReward + reward;
    
    
    state = nextstate;
    action = nextaction;
    
    if (~isempty(histories))
        histories{i1} = state;
        histories{i1}.action = action;
    end    
    
    if (state.terminal)
        break;
    end
end

if (nargout>1)
    varargout{1}=state; % last state
end

if (nargout>2)
    varargout{2}=histories;
end


return;

