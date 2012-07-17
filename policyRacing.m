function [p,numOfRollout] = policyRacing( policy, individuals, environment, delta, numOfSelected, numOfRollout )

N = size(individuals,1);
maxRollout = 5000;
alp=1.25;


%% copy parameters
policies(N) = policy;
for i1 = 1:N
    policies(i1) = policy;
    policies(i1).params(:) = individuals(i1,:);
end

M = zeros(N,N);
Mnum = zeros(N,N);

V=zeros(numOfRollout,N);
cfs = zeros(N,N);
active = zeros(N,1); % 0 active, 1 selected, -1 discarded
T = zeros(N,1);
lastStates = cell(numOfRollout,N);

fprintf( 1, 'Number of rollout: %d\n', numOfRollout );
fprintf( 1, 'Rollout: %.10d\n', 0 );


for rolloutN = 1:maxRollout
    for m = 1:N
        if (active(m)==0)
            [V(rolloutN,m),lastStates{rolloutN,m}] = doRollout( policies(m), environment );
            T(m) = T(m) + 1;
        end
    end
    
    indActive = find(active==0);
    for mi1 = 1:length(indActive)
        for mi2 = 1:length(indActive)
            m1 = indActive(mi1);
            m2 = indActive(mi2);
            
            M(m1,m2) = M(m1,m2) + sign(V(rolloutN,m1)-V(rolloutN,m2));
            Mnum(m1,m2) = Mnum(m1,m2) + 1;
        end
    end
    
    for r = 1:rolloutN-1
        for mi1 = 1:length(indActive)
            for mi2 = 1:length(indActive)
                m1 = indActive(mi1);
                m2 = indActive(mi2);
                
                M(m1,m2) = M(m1,m2) + sign(V(r,m1)-V(rolloutN,m2));
                Mnum(m1,m2) = Mnum(m1,m2) + 1;
            end
        end
    end
    
    for mi1 = 1:length(indActive)
        for mi2 = 1:length(indActive)
            m1 = indActive(mi1);
            m2 = indActive(mi2);
            
            sampleSize = min(T(m1),T(m2))-1;
            cfs(m1,m2) = sqrt( (1/sampleSize) * ( log(2*N) - log(delta)));
        end
    end
                
    stat = M ./ Mnum;
    upperBound = stat+cfs;
    lowerBound = stat-cfs;
    
    
    for mi1 = 1:length(indActive)
        m1 = indActive(mi1);
        numOfBetter(m1) = length(find(lowerBound(m1,:)>0)); % number of instances which are preatty sure better
        numOfWorse(m1) = length(find(upperBound(m1,:)<0)); % number of instances which are preatty sure better        
    end
    
    canditatesForSelecting = [];    
    canditatesForDiscarding = [];    
    bindSelect = N - numOfSelected - length(find(active==-1));
    bindDiscard = numOfSelected - length(find(active==1));
    for m = 1:N
        if (active(m)==0)                        
            if (numOfWorse(m) >= bindSelect ) % select
                canditatesForSelecting(end+1)=m;                
            end
                                    
            if (bindDiscard <= numOfBetter(m)) % do not select
                canditatesForDiscarding(end+1)=m;
            end                
        end        
    end
    
    
    
    if ( mod(rolloutN, 10 ) == 0 )
        fprintf( 1, '\b\b\b\b\b\b\b\b\b\b\b' );
        fprintf( 1, '%.10d\n', rolloutN );
    end
end
nstat = -stat;
%nstat = (nstat+nstat') ./ 2;
for m = 1:N
    nstat(m,:) = nstat(m,:) - min(nstat(m,:));
    nstat(m,:) = nstat(m,:) ./ sum(nstat(m,:));
end

% p = getPerm( nstat );
[s2,p]=sort(sum(V), 'descend');
fprintf( 1, 'Current best: %g\n', s2(1)/maxRollout );

% ev=eig(nstat);
% [s,p] = sort(ev, 'descend');
% [s2,p2]=sort(sum(V), 'descend');
%p = topoorder(biograph(stat));
% p = randperm(N);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = getPerm( M )
n=size(M,1);
v=zeros(n,1);
v(:)=1/n;
i = 0;
while (1)
    vv = M' * v;
    if (sqrt(sum((vv-v).^2))<0.001), break, end
    v = vv;
    v = v ./ sum(v);
    i = i + 1;
    if (i>100)
        warning( 'pagerank does not converge' );
        break
    end
end
[s,p]=sort(v, 'descend');
return;
