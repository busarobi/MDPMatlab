function mainMedicalTreatmentSARSA()

close all

pars = {0.1,0.15,1.2,1.2,-5,1,1,0.5,0.5};
trainEpisodeNum = 100;
testEpisodeNum = 100;


environment = getEnvironment( 'medical_treatment','parameters', pars );

QFunction = getQFunctionLookUpTable( environment, 'discretization', [20,20], 'eligibilitytrace', 1 );

policy = getSARSAPolicy( QFunction,...
                         'alpha', 0.1,...
                         'lambda', 0.95,...
                         'epsilon', 0.2 ...
                         );

maxAverageCumReward = -Inf;

for it = 1:2000
    [avgcumReward, policy, histories] = trainPolicyEpsiodic(policy,environment,trainEpisodeNum,...
                            'rate', [0.97,0.97,0.97]...
                            );
    resultSarsa(it) = getAvgTumorAndToxicityLevel( histories );
                        
    [avgcumReward,histories] = evalPolicy( policy, environment, testEpisodeNum, 'display', 0 );

    if (maxAverageCumReward<avgcumReward)
        maxAverageCumReward = avgcumReward;
        fprintf( 1, '!!!!!!! Policy has been saved!!!!!!!!!\n' );
        save( './policy/medical_sarsa.mat', 'policy' );
    end
    
    
    resultSarsa(it) = getAvgTumorAndToxicityLevel( histories );
    
    plotResult( resultSarsa );
    
    fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );
    fprintf( 1, 'Month: %g\n', resultSarsa(it).month );
    fprintf( 1, 'Alive: %g\n', resultSarsa(it).alive );
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotResult( result )

f = figure('Visible','off');

subplot(2,2,[3 4]);
%%
subplot(2,2,1);
cla;
hold('on' );
grid('on' );
arr = zeros(length(result),1);
for i1 = 1:length(result)
    arr(i1) = result(i1).('alive');
end
X = [ones(size(arr)) (1:length(arr))'];
b = regress(arr,X); 
fitY = b(1)+b(2)*(1:length(arr));


le(1)=plot(arr,'r-d');
le(2)=plot(fitY,'b');
legend( le, 'Survival', 'Lin. fit', 4 );
ylim([0,1]);
drawnow;

%%
subplot(2,2,2);
cla;
hold('on' );
grid('on' );
for i1 = 1:length(result)
    arr(i1) = result(i1).('month');
end
X = [ones(size(arr)) (1:length(arr))'];
b = regress(arr,X); 
fitY = b(1)+b(2)*(1:length(arr));


le(1)=plot(arr,'k-o');
le(2)=plot(fitY,'b');
ylim([0,7]);
legend( le, 'Month', 'Lin. fit', 4 );
drawnow;

%%
subplot(2,2,[3 4]);
grid( 'on' );
hold('on' );
for i1 = 1:length(result)
    le(2) = plot( result(i1).tumorsize, result(i1).toxicity, 'm*' );
end
xlabel( 'Tumor size' );
ylabel( 'Toxicity' );

xlim([0,7]);
ylim([0,7]);

drawnow;

print( '-dpsc2', '-r300', './Figs/medical_SARSA.eps' );

close(f);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
