function mainMedicalTreatmentPlotResult()

pars = {0.1,0.15,1.2,1.2,-5,1,1,0.5,0.5};
episodeNum = 200;


environment = getEnvironment( 'medical_treatment','parameters', pars );


policy = getRandomPolicy();
[avgcumReward,histories] = evalPolicy( policy, environment, episodeNum, 'display', 0 );
resultRandom = getAvgTumorAndToxicityLevel( histories );

fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );
fprintf( 1, 'Month: %g\n', resultRandom.month );    

for i = 1:4
    policy = getConstantPolicy();
    policy.constantValue = i;
    [avgcumReward,histories] = evalPolicy( policy, environment, episodeNum, 'display', 0 );
    resultConstant(i) = getAvgTumorAndToxicityLevel( histories );
    

    fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );    
    fprintf( 1, 'Month: %g\n', resultConstant(i).month );    
end

%% SARSA

load( './policy/medical_sarsa.mat' );
[avgcumReward,histories] = evalPolicy( policy, environment, episodeNum, 'display', 0 );
resultSARSA = getAvgTumorAndToxicityLevel( histories );
fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );
fprintf( 1, 'Month: %g\n', resultSARSA.month );    


%% Hoeffding-race

load( './policy/medical_HoeffdingRace_discaction.mat' );
[avgcumReward,histories] = evalPolicy( policy, environment, episodeNum, 'display', 0 );
resultHDisc = getAvgTumorAndToxicityLevel( histories );
fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );
fprintf( 1, 'Month: %g\n', resultHDisc.month );    

load( './policy/medical_HoeffdingRace_nodiscaction.mat' );
[avgcumReward,histories] = evalPolicy( policy, environment, episodeNum, 'display', 0 );
resultHNoDisc = getAvgTumorAndToxicityLevel( histories );
fprintf( 1, 'Avg. Cum. Reward: %g\n', avgcumReward );
fprintf( 1, 'Month: %g\n', resultHNoDisc.month );    


%% plot
% hold('off');
le(1) = plot( resultRandom.tumorsize, resultRandom.toxicity, 'r*', 'MarkerSize', 10 );
grid( 'on' );
hold('on' );
for i1 = 1:4
    le(2) = plot( resultConstant(i1).tumorsize, resultConstant(i1).toxicity, 'k*', 'MarkerSize', 10 );
end

le(3) = plot( resultSARSA.tumorsize, resultSARSA.toxicity, 'md', 'MarkerSize', 10 );
le(4) = plot( resultHDisc.tumorsize, resultHDisc.toxicity, 'b+', 'MarkerSize', 10 );
le(5) = plot( resultHNoDisc.tumorsize, resultHNoDisc.toxicity, 'g+', 'MarkerSize', 10 );
legHandler = legend( le, 'Random', 'Constant', 'SARSA', 'Lin/H-race/Disc','Lin/H-race' );


lax(1)=xlabel( 'Tumor size' );
lax(2)=ylabel( 'Toxicity' );

set( legHandler, 'FontSize', 19 );
set( gca, 'FontSize', 16 );
set( lax, 'FontSize', 19 );



print( '-dpsc2', '-zbuffer', '-r300', './Figs/medical.eps' );

% xlim( [0,6] );
% ylim( [0,7] );
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
