%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = getAvgTumorAndToxicityLevel( histories )

[N,M] = size(histories);

result.tumorsize=0;
result.toxicity=0;
result.month=0;
result.alive = 0;
for i1 = 1:N    
    for i2 = 1:M                    
        if ((i2 == M ) || isempty(histories{i1,i2+1}))
            break;
        end
    end
    
    lastState = histories{i1,i2};
    
    result.month = result.month + lastState.step;
    result.alive = result.alive + lastState.values(3);
    result.tumorsize = result.tumorsize + lastState.values(1);
    result.toxicity = result.toxicity + lastState.values(2);
end

result.alive = result.alive / N;
result.month = result.month / N;
result.tumorsize = result.tumorsize / N;
result.toxicity = result.toxicity / N;

return;
