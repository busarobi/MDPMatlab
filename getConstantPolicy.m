function policy = getConstantPolicy()
policy.constantValue = 1;
policy.getNextActionFunc = @getNextAction;

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getNextAction(state, policy, environment )
action.actionIdx = zeros(environment.adim,1);
for i1 = 1:environment.adim
    if ( environment.atype(i1) == 'c' )         
         action.actionIdx(i1) = policy.constantValue;
    elseif ( environment.atype(i1) == 'd' )
        action.actionIdx(i1) = policy.constantValue;
    else
        error( 'unknown action type' );
    end
end

return;