function [policySet, options, varargout] = trainParametricPolicyEpsiodicBasedES(policySet,environment,iterationNumber, options,varargin)

dispFlag = 2;
counterstep = 100;
delta = 0.05;
numOfRollout = 1000;
racingMethod = 'Hoeffding';
for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            dispFlag = varargin{i + 1};
        case 'counterstep'
            counterstep = varargin{i + 1};
        case 'delta'
            delta = varargin{i + 1};
        case 'numOfRollout'
            numOfRollout = varargin{i + 1};
        case 'racing'
            racingMethod = varargin{i + 1};
        otherwise
            disp(['Unknown parameter: ''' varargin{i} '''']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for parallel computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matlabpool('close');
if (  ~(matlabpool( 'size' ) > 0) )
    matlabpool('open', 'FileDependencies', ...
        {'policyRacing.m'});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for parallel computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% solution = ESOptimizer(options,4, policySet, environment );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize population
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (options.nVars==0)
    
    options.nVars = length(policySet(1).params);
    if(isscalar(options.initObjectLB))
        options.initObjectLB = ones(1,options.nVars) * options.initObjectLB;
    end
    if(isscalar(options.initObjectUB))
        options.initObjectUB = ones(1,options.nVars) * options.initObjectUB;
    end
    spanO = options.initObjectUB - options.initObjectLB;
    spanO = repmat(spanO, options.mu, 1);
    %object = repmat(options.initObjectLB, options.mu, 1) + rand(options.mu, options.nVars) .* spanO;
    object = zeros(options.mu, options.nVars );
    for i1 = 1:options.mu
        object(i1,:) = policySet(i1).params;
    end
    
    if(options.nStepsizes)
        if(isscalar(options.initStrategyLB))
            options.initStrategyLB = ones(1,options.nVars) * options.initStrategyLB;
        end
        if(isscalar(options.initStrategyUB))
            options.initStrategyUB = ones(1,options.nVars) * options.initStrategyUB;
        end
        spanS = options.initStrategyUB - options.initStrategyLB;
        spanS = repmat(spanS, options.mu, 1);
        strategy = repmat(options.initStrategyLB, options.mu, 1) + rand(options.mu, options.nVars) .* spanS;
    else
        strategy = repmat(options.initStrategyLB, options.mu, 1) + rand(options.mu, 1) .* (options.initStrategyUB - options.initStrategyLB);
    end
    age = ones(options.mu, 1);
else
    strategy = options.strategy;
    object = options.object;
    age = options.age;
    numOfRollout = options.numOfRollout;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% main loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ES LOOP
for esLoop = 1:iterationNumber
%while(min(min(strategy)) > 0.0001)
    
    % generate lambda offsprings
    offsprings = zeros(options.mu,options.nVars);
    if options.nStepsizes
        offspringsStrategy = zeros(options.mu,options.nVars);
    else
        offspringsStrategy = zeros(options.mu,1);
    end
    
    for offs = 1: options.nu * options.mu
        
        % mating selection
        indices = randi(options.mu, options.rho, 1);
        newObject = object(indices, :);
        newStrategy = strategy(indices, :);
        
        % recombination
        if(strcmp(options.recombObject, 'intermediate'))
            newObject = mean(newObject);
        else
            pool = randi(options.rho, 1, options.nVars);
            pool = pool + options.rho * (0:(options.nVars-1));
            newObject = newObject(pool);
        end
        if(strcmp(options.recombStrategy, 'intermediate'))
            newStrategy = mean(newStrategy);
        elseif(strcmp(options.recombStrategy, 'discrete') && options.nStepsizes)
            pool = randi(options.rho, 1, options.nVars);
            pool = pool + options.rho * (0:(options.nVars-1));
            newStrategy = newStrategy(pool);
        else
            pool = randi(options.rho, 1, 1);
            newStrategy = newStrategy(pool);
        end
        
        % mutation
        tau = options.cTau / sqrt(2*sqrt(options.nVars));
        tau = tau * randn(1, options.nVars);
        tau0 = exp(randn(1,1)) * options.cTau / sqrt(options.nVars);
        tau0 = repmat(tau0, 1, options.nVars);
        newStrategy = tau0 .* (newStrategy .* tau);
        newObject = newObject + newStrategy .* randn(1, options.nVars);
        
        offsprings(offs, :) = newObject;
        offspringsStrategy(offs, :) = newStrategy;
    end
    
    % selection
    if options.kappa == Inf
        individuals = [object;offsprings];
        strategyComponents = [strategy; offspringsStrategy];
    else
        individuals = offsprings;
        strategyComponents = offspringsStrategy;
    end    
        
    %GENERATE RANKING OF INDIVIDUALS i = (3,5,6,...)
    switch racingMethod
        case 'Hoeffding'
            [i,numOfRollout] = policyRacingBasedOnValues( policySet(1), individuals, environment, delta, round(size(individuals,1)/4),numOfRollout );
        case 'preference'
            [i,numOfRollout] = policyRacing( policySet(1), individuals, environment, delta, round(size(individuals,1)/4),numOfRollout );
    end
    
    object = individuals(i(1:options.mu),:);
    strategy = strategyComponents(i(1:options.mu),:);
    
end

options.strategy = strategy;
options.object = object;
options.age = age;
options.numOfRollout=numOfRollout;
for i1 = 1:options.mu
    policySet(i1).params(:) = object(i1,:);
end

% solution = object(1,:);




return;