function QFunction = getQFunctionLookUpTable( environment, varargin )

dispFlag = 2;
discretization = 10;
eligibilityTraceFlag = 0;
for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            dispFlag = varargin{i + 1};
        case 'discretization'
            discretization = varargin{i + 1};
        case 'eligibilitytrace'
            eligibilityTraceFlag = varargin{i + 1};
        otherwise
            disp(['Unknown parameter: ''' varargin{i} '''']);
    end
end




if ( ( environment.adim == 1 ) && ( environment.atype(1) == 'd' ) )
    QFunction.QTable = cell(environment.anum,1);
    
    dims = cell(environment.adim+length(discretization),1);
    i=1;
    for i1 = 1:environment.adim
        dims{i}=environment.anum;        
        i=i+1;
    end
    for i1 = 1:environment.sdim
        dims{i}=discretization(i1)+2;        
        i=i+1;
    end
    if (dispFlag>1)
        fprintf( 1, 'Allocating Q table...' );
    end    
    QFunction.QTable = zeros( dims{:} );    
    if (dispFlag>1)
        fprintf( 1, 'Done.\n' );
    end
        
    if ( eligibilityTraceFlag )
        if (dispFlag>1)
            fprintf( 1, 'Allocating eligibility trace...' );
        end    
        QFunction.eligibilityTrace = zeros( dims{:} );        
%         QFunction.eligibilityTraceMaxLength = environment.episodeLength+2;
%         QFunction.eligibilityTrace = cell(QFunction.eligibilityTraceMaxLength+2,3);
%         QFunction.eligibilityTraceValues = zeros(QFunction.eligibilityTraceMaxLength+2,1);
%         QFunction.eligibilityTraceLength = 0;                
        if (dispFlag>1)
            fprintf( 1, 'Done.\n' );
        end
    end
    QFunction.eligibilityTraceFlag = eligibilityTraceFlag;
    
    QFunction.sdim = environment.sdim;
    QFunction.sLowerBound = environment.sLowerBound;
    QFunction.sUpperBound = environment.sUpperBound;
    QFunction.stype = environment.stype;    
    QFunction.divs = cell(environment.sdim,1);

    for i = 1:environment.sdim
        width = environment.sUpperBound(i) - environment.sLowerBound(i);
        step = width / discretization(i);
        QFunction.divs{i} = environment.sLowerBound(i):step:environment.sUpperBound(i);
    end    
    QFunction.discretization = discretization;
    
    QFunction.adim = environment.adim;
    QFunction.anum = environment.anum;
    environment.atype = environment.atype;
    
    
    
    QFunction.getIndexFunc = @ getIndexForDiscretizedStateAndDiscretizedAction;            
    QFunction.getBestActionFunc = @ getBestActionQTable;
    QFunction.getQValueFunc = @ getQValue;
    QFunction.updateFunc = @ updateQFunction;
    QFunction.clearEligibilityTraceFunc = @ clearEligibilityTrace;
end



return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function QTable = clearEligibilityTrace( QTable )
if (QTable.eligibilityTraceFlag)
    QTable.eligibilityTrace(:)=0;
%     QTable.eligibilityTraceLength = 0;
end
    
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function QTable = updateQFunction( state, action, alpha, delta, gamma, lambda, QTable )
if ((lambda~=0) && (QTable.eligibilityTraceFlag))    
    indexArray = feval( QTable.getIndexFunc, action, state, QTable );
    
    % matrix form
    QTable.eligibilityTrace(indexArray{:}) = 1.0;    
    QTable.QTable = QTable.QTable + alpha * delta * QTable.eligibilityTrace;
    QTable.eligibilityTrace = gamma * lambda * QTable.eligibilityTrace;
    
%     QTable.eligibilityTraceLength = QTable.eligibilityTraceLength + 1;
%     L = QTable.eligibilityTraceLength;
%     QTable.eligibilityTrace(L,:) = indexArray(:);
%     QTable.eligibilityTraceValues(L) = 1.0;
%     
%     for i1 = 1:L
%         currIndex = QTable.eligibilityTrace(i1,:);
%         QTable.QTable(currIndex{:}) = QTable.QTable(currIndex{:}) + alpha * delta * QTable.eligibilityTraceValues(i1);        
%     end
%     for i1 = 1:L
%         QTable.eligibilityTraceValues(i1) = gamma * lambda * QTable.eligibilityTraceValues(i1);
%     end
else
    indexArray = feval( QTable.getIndexFunc, action, state, QTable );
    QTable.QTable(indexArray{:}) = QTable.QTable(indexArray{:}) + alpha * delta;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value = getQValue( state, action, QTable )
indexArray = feval( QTable.getIndexFunc, action, state, QTable );
value = QTable.QTable(indexArray{:});
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function action = getBestActionQTable( state, QTable )

action.actionIdx(1)=1;
indexArray = feval( QTable.getIndexFunc, action, state, QTable );

action.actionIdx = zeros(QTable.adim,1);
maxVal = -Inf;
for i1 = 1:QTable.anum
    indexArray{1} = i1;
    val = QTable.QTable(indexArray{:});
    if (val>maxVal)
        maxVal = val;
        action.actionIdx(1) = i1;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function indexArray = getIndexForDiscretizedStateAndDiscretizedActionL2( action, state, QTable )
persistent stateSpacePoints;
persistent stateSpacePointsIndices;

if (isempty(stateSpacePoints))
    i=1;
    stateSpacePoints = zeros( prod(QTable.discretization+1),2 );
    stateSpacePointsIndices = zeros( prod(QTable.discretization+1),2 );
    for i1 = 1:length(QTable.divs{1})
        for i2 = 1:length(QTable.divs{2})
            stateSpacePoints(i,1) = QTable.divs{1}(i1);
            stateSpacePoints(i,2) = QTable.divs{2}(i2);
            
            stateSpacePointsIndices(i,1)=i1;
            stateSpacePointsIndices(i,2)=i2;
            
            i=i+1;
        end
    end
end

x = repmat(state.values(1:state.sdim),size(stateSpacePoints,1),1);
d = sqrt( sum( (x-stateSpacePoints).^2,2 ) );

indexArray = cell(QTable.adim+QTable.sdim,1);

for i1 = 1:QTable.adim
    indexArray{i1} = action.actionIdx(i1);
end


[val, ind ] = min(d);
for i = 1:state.sdim
    indexArray{QTable.adim+i} = stateSpacePointsIndices(ind,i);
end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function indexArray = getIndexForDiscretizedStateAndDiscretizedAction( action, state, QTable )

indexArray = cell(QTable.adim+QTable.sdim,1);

for i1 = 1:QTable.adim
    indexArray{i1} = action.actionIdx(i1);
end

for i = 1:state.sdim
    %si(i) = bsearch( QTable.divs{i}, state.values(i) ); 
    ind = find( QTable.divs{i} > state.values(i), 1, 'first' ); % might be sub-optimal
    if (isempty(ind))
        % bigger than the upper limit
        indexArray{QTable.adim+i} = QTable.discretization(i)+2;
    else        
        indexArray{QTable.adim+i} = ind;
    end    
end

% for i1 = 1:length(indexArray)
%     fprintf( 1, '%d ', indexArray{i1} );
% end
% fprintf(1, '\n' );

return;

