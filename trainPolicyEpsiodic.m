function [avgcumReward, policy, varargout] = trainPolicyEpsiodic(policy,environment,episodeNum,varargin)

dispFlag = 2;
rate = 0.99;
counterstep = 100;
for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            dispFlag = varargin{i + 1};
        case 'rate'
            rate = varargin{i + 1};
        case 'counterstep'
            counterstep = varargin{i + 1};
        otherwise
            disp(['Unknown parameter: ''' varargin{i} '''']);
    end
end

cumReward = 0;

if (dispFlag>0)
    fprintf( 1, 'episode: %.10d\n', 0 );
end

if (nargout>1)
    histories = cell( episodeNum, environment.episodeLength );
else
    histories = {};
end


for ep = 1:episodeNum
    currCumReward = 0;
    state = feval(environment.initialState);    
    action = feval( policy.getEpsilonGreedyActionFunc, state, policy, environment );
    
    if (~isempty(histories))
        histories{ep,1} = state;
        histories{ep,1}.action = action;
    end
    
    policy = feval( policy.clearTraceFunc, policy );
    
    for i1 = 2:environment.episodeLength+1
        %fprintf( 1, '%d\n', i1);
        %do the selected action and get the next state
        nextstate = feval(environment.transitionFunc, state, action, environment );
        nextaction = feval( policy.getEpsilonGreedyActionFunc, nextstate, policy, environment );
        
        
        % observe the reward at state newstate and the final state flag
        reward = feval(environment.rewardFunc, state, nextstate, environment );
        currCumReward = currCumReward + reward;
        
        
        % Update the Qtable, that is,  learn from the experience
        policy = feval( policy.updateQFunctionFunc, state, action, nextstate, nextaction, reward, policy );        
        
        
        state = nextstate;
        action = nextaction;
        
        if (~isempty(histories))            
            histories{ep,i1} = state;            
            histories{ep,i1}.action = action;
        end
        
        
        if (state.terminal)            
            break;
        end
    end
    cumReward = cumReward + currCumReward;
    
%     policy.epsilon = policy.epsilon * rate(3);
%     policy.alpha = policy.alpha * rate(1);
%     policy.lambda = policy.lambda * rate(2);
    
    if ((dispFlag>0)&&( mod(ep, counterstep ) == 0 ))
        fprintf( 1, '\b\b\b\b\b\b\b\b\b\b\b' );
        fprintf( 1, '%.10d\n', ep );
    end        
end

policy.epsilon = policy.epsilon * rate(3);
policy.alpha = policy.alpha * rate(1);
policy.lambda = policy.lambda * rate(2);

fprintf( 1, '---> Alpha   : %g\n', policy.alpha );
fprintf( 1, '---> Lambda  : %g\n', policy.lambda );
fprintf( 1, '---> Epsilon : %g\n', policy.epsilon );

avgcumReward = cumReward/episodeNum;

if (dispFlag>0)
    fprintf( 1, '...Done.\n' );
end

if (nargout>1)    
    varargout{1}=histories;
end
return;