%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [avgcumReward, varargout] = evalPolicy( policy, environment, episodeNum, varargin )

dispFlag = 2;
crit = {};
counterstep = 100;
for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            dispFlag = varargin{i + 1};
        case 'parameters'
            crit = varargin{i + 1};
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
    action = feval( policy.getNextActionFunc, state, policy, environment );
    if (~isempty(histories))
        histories{ep,1} = state;
        histories{ep,1}.action = action;
    end
    
    for i1 = 2:environment.episodeLength
        
        newstate = feval(environment.transitionFunc, state, action, environment );
        action = feval( policy.getNextActionFunc, newstate, policy, environment );
        reward = feval(environment.rewardFunc, state, newstate, environment );
        currCumReward = currCumReward + reward;
        
        state = newstate;
        
        if (~isempty(histories))
            histories{ep,i1} = state;
            histories{ep,i1}.action = action;
        end
        
        
        if (state.terminal)            
            break;
        end
    end
    cumReward = cumReward + currCumReward;
    
    if ((dispFlag>0)&&( mod(ep, counterstep ) == 0 ))
        fprintf( 1, '\b\b\b\b\b\b\b\b\b\b\b' );
        fprintf( 1, '%.10d\n', ep );
    end        
end
avgcumReward = cumReward/episodeNum;

if (dispFlag>0)
    fprintf( 1, '...Done.\n' );
end

if (nargout>1)    
    varargout{1}=histories;
end


return;