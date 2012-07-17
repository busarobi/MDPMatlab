%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function options = setOptionsESOptimizer()
options.mu = 4;
options.nu = 2; % mu*nu is the number of offsprings, \lambda
options.rho = 2; % number of individuals used for recombination
options.cTau = 1.3; % step size of adaptation, the larger is the faster
options.kappa = Inf; % sleection strategy, (Inf=never loose solution) OK!
options.recombObject = 'intermediate'; 
options.recombStrategy = 'discrete'; % for strategy componenent
options.nStepsizes = 1; % 
options.initObjectLB = -10; % initialization domain
options.initObjectUB = 10; % initialization domain
options.initStrategyLB = 3;
options.initStrategyUB = 4;
% options.stallGenerations = 50; 
% options.reqiredFitness = -Inf;
% options.maxGenerations = 100;
options.nVars = 0; % number of parameters

return;