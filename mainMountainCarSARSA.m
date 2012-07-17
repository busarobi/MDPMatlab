function mainMountainCarSARSA()


trainEpisodeNum = 1;
testEpisodeNum = 1;


environment = getEnvironment( 'mountain_car' );

QFunction = getQFunctionLookUpTable( environment, 'discretization', [40,20], 'eligibilitytrace', 1 );

policy = getSARSAPolicy( QFunction, 'lambda', 0.95 );

for it = 1:100
    [avgcumRewardTrain(it), policy,histories] = trainPolicyEpsiodic(policy,...
                        environment,trainEpisodeNum,...
                        'counterstep',1,...
                        'rate', [1,1,0.99]...
                        );
    
    stepNumTrain(it) = getStepNumber( histories(1,: ) );
    
    [avgcumRewardTest(it),histories] = evalPolicy( policy, environment, testEpisodeNum, 'display', 0,'counterstep',1 );
    stepNumTest(it) = getStepNumber( histories(1,: ) );        
    
    plotResult( stepNumTrain, stepNumTest, histories(1,:) );
    
    fprintf( 1, 'Avg Reward: %f\n', avgcumRewardTest(it) );
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stepNum = getStepNumber( history )

for i1 = 1:length(history)
    if (isempty(history{i1})), break, end
end
stepNum = i1;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotResult( stepNumTrain, stepNumTest, history )

subplot(2,2,[3 4]);
subplot(2,2,1);
plot( stepNumTrain );
xlim([0,length(stepNumTrain)]);
title( sprintf( 'Train/Episode: %d', length(stepNumTrain)));
drawnow;


subplot(2,2,2);
plot( stepNumTest );
xlim([0,length(stepNumTest)]);
title( 'Test' );
drawnow;


if (length(stepNumTest)>98)
    for i1 = 1:length(history)
        if (isempty(history{i1})), break, end
        MountainCarPlot( history{i1}.values , history{i1}.action.actionIdx(1)-2 ,i1 )
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MountainCarPlot( x,a,steps )
subplot(2,1,2);
set(gco,'BackingStore','off')  % for realtime inverse kinematics
set(gco,'Units','data')
xplot =-1.6:0.05:0.6;
yplot =sin(3*xplot);
%Mountain
h = area(xplot,yplot,-1.1);
set(h,'FaceColor',[.1 .7 .1])
hold on
% Car  [1 .7 .1]
plot([x(1)-0.075 x(1)+0.075] ,[sin(3*(x(1)-0.075))+0.2  sin(3*(x(1)+0.075))+0.2 ],'-','LineWidth',10,'Color',[1 .7 .1]);
% wheels
plot(x(1)-0.05,sin(3*(x(1)-0.05))+0.06,'ok','markersize',12,'MarkerFaceColor',[.5 .5 .5]);
plot(x(1)+0.05,sin(3*(x(1)+0.05))+0.06,'ok','markersize',12,'MarkerFaceColor',[.5 .5 .5]);

%Goal
plot(0.45,sin(3*0.5)+0.1,'-pk','markersize',15,'MarkerFaceColor',[1 .7 .1]);
% direction of the force
if (a<0)
    plot(x(1)-0.08-0.05,sin(3*(x(1)-0.05))+0.2,'<k','MarkerFaceColor','g','markersize',10);
elseif (a>0)
    plot(x(1)+0.08+0.05,sin(3*(x(1)+0.05))+0.2,'>k','MarkerFaceColor','g','markersize',10);
end

title(strcat ('Step: ',int2str(steps)));
%-----------------------
axis([-1.6 0.6 -1.1 1.5]);
drawnow
hold off