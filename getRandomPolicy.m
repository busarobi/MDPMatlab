function policy = getRandomPolicy()

policy.getNextActionFunc = @getNextAction;

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getNextAction(state, policy, environment )
action.actionIdx = zeros(environment.adim,1);
for i1 = 1:environment.adim
    if ( environment.atype(i1) == 'c' )
         bds = environment.aMax(i1) - environment.aMin(i1);
         action.actionIdx(i1) = environment.aMin(i1) + rand() / bds;
    elseif ( environment.atype(i1) == 'd' )
        action.actionIdx(i1) = randi( environment.anum );
    else
        error( 'unknown action type' );
    end
end

return;