function mainMedicalTreatmentPreferenceBasedParametric()

close all

pars = {0.1,0.15,1.2,1.2,-5,1,1,0.5,0.5};
trainEpisodeNum = 1;
testEpisodeNum = 100;


environment = getEnvironment( 'medical_treatment','parameters', pars );

optimizerParams = setOptionsESOptimizer();
for i1 = 1:optimizerParams.mu
    policySet(i1) = getPreferenceBasedParametricPolicy( environment, 'discrete_action', 0 );
end

maxAverageCumReward = -Inf;

for it = 1:1000
    [policySet,optimizerParams] = trainParametricPolicyEpsiodicBasedES(policySet,...
                        environment,trainEpisodeNum, optimizerParams,...
                        'counterstep',1,...
                        'racing', 'preference' );
                        
                        
    policy = policySet(1);
                        
    [avgcumReward,histories] = evalPolicy( policy, environment, testEpisodeNum, 'display', 0 );

    if (maxAverageCumReward<avgcumReward)
        maxAverageCumReward = avgcumReward;
        fprintf( 1, '!!!!!!! Policy has been saved!!!!!!!!!\n' );
        %save( './policy/medical_pbpol_discaction.mat', 'policy' );
        save( './policy/medical_pbpol_nodiscaction.mat', 'policy' );
    end
    
    
    result(it) = getAvgTumorAndToxicityLevel( histories );
    
    plotResult( result );
    
    fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );
    fprintf( 1, 'Month: %g\n', result(it).month );
    fprintf( 1, 'Alive: %g\n', result(it).alive );
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotResult( result )

f=figure('Visible', 'off' );

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

print( '-dpsc2', '-r300', './Figs/medical_pb.eps' );

close(f);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
