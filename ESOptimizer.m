function solution = ESOptimizer(options, nVars, policies, environment )
% nvars is the dimension of input space
options.nVars = nVars;

%initialize population

if(isscalar(options.initObjectLB))
    options.initObjectLB = ones(1,options.nVars) * options.initObjectLB;
end
if(isscalar(options.initObjectUB))
    options.initObjectUB = ones(1,options.nVars) * options.initObjectUB;
end
spanO = options.initObjectUB - options.initObjectLB;
spanO = repmat(spanO, options.mu, 1);
object = repmat(options.initObjectLB, options.mu, 1) + rand(options.mu, options.nVars) .* spanO;

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


% ES LOOP
while(min(min(strategy)) > 0.0001)
    
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
    i = policyRacing( policies, environment );
    
    object = individuals(i(1:options.mu),:);
    strategy = strategyComponents(i(1:options.mu),:);
end

solution = object(1,:);

return;
