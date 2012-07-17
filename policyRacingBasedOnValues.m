function [p,numOfRollout] = policyRacingBasedOnValues( policy, individuals, environment, delta, numOfSelected, numOfRollout )

N = size(individuals,1);
maxRollout = 10000;
alp=1.25;



%% copy parameters
policies(N) = policy;
for i1 = 1:N
    policies(i1) = policy;
    policies(i1).params(:) = individuals(i1,:);
end

V=zeros(numOfRollout,N);
ms = zeros(N,1);
cfs = zeros(N,2);
active = zeros(N,1); % 0 active, 1 selected, -1 discarded
T = zeros(N,1); 
% V(:,:)=NaN;

fprintf( 1, 'Number of rollout: %d\n', numOfRollout );
fprintf( 1, 'Rollout: %.10d\n', 0 );


for rolloutN = 1:numOfRollout
    parfor m = 1:N
        if ((rolloutN==1) || (active(m)==0))
            tmpValue = doRollout( policies(m), environment );
            V(rolloutN,m) = tmpValue;
            T(m) = T(m) + 1;
            ms(m) = ms(m)+tmpValue;            
        end
    end

    currcf = environment.maxminReward * sqrt( (log(2*N)-log(delta) ) ./ T);
    cfs(:,1) = ms./T-currcf;
    cfs(:,2) = ms./T+currcf;
    
    
    for m = 1:N
        if (active(m)==0)
            bind = N - numOfSelected - length(find(active==-1)); % ennyinel kell jobbnak lennie
            lowerBoundBigger = length(find( cfs(m,1) > cfs(active==0,2) ));
            if (lowerBoundBigger >= bind ) % select
                active(m)=1;
            end
            
            bind = numOfSelected - length(find(active==1)); % ennyit kellene meg kivalasztani
            upperBoundLower = length(find( cfs(m,2) < cfs(active==0,1) ));                
            if (bind <= upperBoundLower ) % do not select
                active(m)=-1;
            end                
        end        
    end
    
    if ( mod(rolloutN, 100 ) == 0 )
        fprintf( 1, '\b\b\b\b\b\b\b\b\b\b\b' );
        fprintf( 1, '%.10d\n', rolloutN );
    end
end

p = find(active==1);
if (length(p) < numOfSelected)
    [s2,p]=sort(sum(V), 'descend');
    %p = p(1:numOfSelected);    
    numOfRollout = round(min( alp*numOfRollout, maxRollout));    
else
    numOfRollout = round(max( alp^-1*numOfRollout, 3));
end

fprintf( 1, 'Current best: %g\n', max(ms./T) );



% ev=eig(nstat);
% [s,p] = sort(ev, 'descend');
% [s2,p2]=sort(sum(V), 'descend');
%p = topoorder(biograph(stat));
% p = randperm(N);

return;
