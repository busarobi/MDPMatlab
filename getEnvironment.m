function environment = getEnvironment( id, varargin )

dispFlag = 2;
pars = {};
for i = 1:2:length(varargin) - 1
    switch varargin{i}
        case 'display'
            dispFlag = varargin{i + 1};
        case 'parameters'
            pars = varargin{i + 1};
        otherwise
            disp(['Unknown parameter: ''' varargin{i} '''']);
    end
end

if (dispFlag > 0)
    fprintf( 1, 'Generating model...' );
end

if (dispFlag > 1)
    fprintf( 1, '\n---> Model : %s', id );
end

environment.id =             id;
environment.sdim    =        0;
environment.auxsdim =        0;
environment.adim    =        0;
environment.parameters =     pars;
environment.parameterNames = {};
environment.funcs =          {};



%% generating model
switch id
    case 'medical_treatment'
        environment.sdim = 2;
        environment.stype = 'cc';        
        environment.sLowerBound = [0, 0 ];
        environment.sUpperBound = [10,10];
        
        environment.adim = 1;                        
        environment.atype = 'd';
        environment.anum = 4;
        environment.avalues = [0.1,0.4,0.7,1.0];
        environment.aLowerBound = [0];
        environment.aUpperBound = [1];
        
        environment.episodeLength = 6;
        environment.initialState = @ getInitialStateForMedicalTreatMent;
        environment.transitionFunc = @ getNextStateForMedicalTreatMent;
        environment.rewardFunc = @ getRewardMedicalTreatMent;
        environment.parameterNames = {'a1','a2','b1','b2','c0','c1','c2','d1','d2'};
        environment.funcs = {@ getDeathProb};
        environment.funcsName = {'getDeathProb' };
        environment.preferenceFunc = @getPreferenceForMedicalTreatment;
        
        environment.rewardOfDeath = -60;
        environment.tolerance = 1E-5;
        environment.maxminReward = 100;
    case 'mountain_car'
        environment.sdim = 2;
        environment.stype = 'cc';        
        environment.sLowerBound = [-1.5,-0.07];
        environment.sUpperBound = [0.45,0.07 ];
        
        environment.adim = 1;                        
        environment.atype = 'd';
        environment.anum = 3;
        environment.avalues = [-1.0,0.0,1.0];
        
        environment.episodeLength = 1000;
        environment.initialState = @ getInitialStateForMountainCar;
        environment.transitionFunc = @ getNextStateForMountainCar;
        environment.rewardFunc = @ getRewardMountainCar;
        environment.parameterNames = {''};
        environment.funcs = {@ getDeatchProb};
        environment.funcsName = {'getDeatchProb' };        
        
        environment.iReward = -1;
        environment.successReward = 100;
    case 'cart_pole'
        environment.sdim = 4;
        environment.stype = 'cccc';        
        environment.sLowerBound = [-2,-2, deg2rad(-12),deg2rad(-10)];
        environment.sUpperBound = [ 2, 2, deg2rad( 12),deg2rad( 10)];
        
        environment.adim = 1;                        
        environment.atype = 'd';
        environment.anum = 21;
        environment.avalues = -1.0:0.1:1.0;
        
        environment.episodeLength = 1000;
        environment.initialState = @ getInitialStateForCartPole;
        environment.transitionFunc = @ getNextStateForCartPole;
        environment.rewardFunc = @ getRewardCartPole;
        environment.parameterNames = {''};
        environment.funcs = {};
        environment.funcsName = {};
        
    otherwise
        error( 'Unknown environment' );
end

if (dispFlag > 0)
    fprintf( 1, '...Done.\n' );
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions  for 'cart_pole'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state = getInitialStateForCartPole()

% position
% speed

state.values = [0 0 0 0.01];

state.initStateValues = state.values;
state.terminal = 0;
state.sdim = 4;
state.step = 1;
return;


function newState = getNextStateForCartPole( state, action, environment )
%  Cart_Pole:  Takes an action (0 or 1) and the current values of the
%  four state variables and updates their values by estimating the state
%  TAU seconds later.

% Parameters for simulation
x          = state.values(1);
x_dot      = state.values(2);
theta      = state.values(3);
theta_dot  = state.values(4);


g               = 9.8;      %Gravity
Mass_Cart       = 1.0;      %Mass of the cart is assumed to be 1Kg
Mass_Pole       = 0.1;      %Mass of the pole is assumed to be 0.1Kg
Total_Mass      = Mass_Cart + Mass_Pole;
Length          = 0.5;      %Half of the length of the pole 
PoleMass_Length = Mass_Pole * Length;
Force_Mag       = 10.0;
Tau             = 0.02;     %Time interval for updating the values
Fourthirds      = 4.0/3.0;

force = environment.avalues(action.actionIdx(1)) * Force_Mag;

temp     = (force + PoleMass_Length * theta_dot * theta_dot * sin(theta)) / Total_Mass;
thetaacc = (g * sin(theta) - cos(theta) * temp) / (Length * (Fourthirds - Mass_Pole * cos(theta) * cos(theta) / Total_Mass));
xacc     = temp - PoleMass_Length * thetaacc * cos(theta) / Total_Mass;
 
% Update the four state variables, using Euler's method.
x         = x + Tau * x_dot;
x_dot     = x_dot + Tau * xacc;
theta     = theta + Tau * theta_dot;
theta_dot = theta_dot+Tau*thetaacc;

newState = state;
newState.values = [x x_dot theta theta_dot];
newState.step = newState.step + 1;
twelve_degrees     = deg2rad(12); % 12
fourtyfive_degrees = deg2rad(45); % 45
%if (x < -4.0 | x > 4.0  | theta < -twelve_degrees | theta > twelve_degrees)          
if ((x < -4.0) || (x > 4.0)  || (theta < -fourtyfive_degrees) || (theta > fourtyfive_degrees)) 
    newState.terminal = 1;
end


return;

function reward = getRewardCartPole( oldState, newState, environment )
% r: the returned reward.
% f: true if the car reached the goal, otherwise f is false
    
x         = newState.values(1);
x_dot     = newState.values(3);
theta     = newState.values(3);
theta_dot = newState.values(4);

if (newState.terminal==0)
    reward = 10 - 10*abs(10*theta)^2 - 5*abs(x) - 10*theta_dot;
else
    reward = -10000 - 50*abs(x) - 100*abs(theta);         
end

return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions  for 'mountain_car'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state = getInitialStateForMountainCar()

% position
% speed

state.values = [-0.5,0];

state.initStateValues = state.values;
state.terminal = 0;
state.sdim = 2;
state.step = 1;
return;


function newState = getNextStateForMountainCar( state, action, environment )
%MountainCarDoAction: executes the action (a) into the mountain car
%environment
% a: is the force to be applied to the car
% x: is the vector containning the position and speed of the car
% xp: is the vector containing the new position and velocity of the car

force = environment.avalues(action.actionIdx(1));

position = state.values(1);
speed    = state.values(2); 

% bounds for position
bpleft=environment.sLowerBound(1); 
bpright=environment.sUpperBound(1);

% bounds for speed
bsleft=environment.sLowerBound(2); 
bsright=environment.sUpperBound(2);

 
speedt1= speed + (0.001*force) + (-0.0025 * cos( 3.0*position) );	 
%speedt1= speedt1 * 0.999; % thermodynamic law, for a more real system with friction.

if(speedt1<bsleft) 
    speedt1=bsleft; 
end
if(speedt1>bsright)
    speedt1=bsright; 
end

post1 = position + speedt1; 

if(post1<=bpleft)
    post1=bpleft;
    speedt1=0.0;
end

if(post1>=bpright)
    post1=bpright;
    speedt1=0.0;
end

newState = state;
newState.values(1) = post1;
newState.values(2) = speedt1;
newState.step = newState.step+1;

% bound for position; the goal is to reach position = 0.45
if ( position >= bpright )
    newState.terminal = 1;
end

if (newState.step>=environment.episodeLength)
    newState.terminal = 1;
end


return;

function reward = getRewardMountainCar( oldState, newState, environment )
% MountainCarGetReward returns the reward at the current state
% x: a vector of position and velocity of the car
% r: the returned reward.
% f: true if the car reached the goal, otherwise f is false
    
if ( newState.terminal == 0)
    reward = environment.iReward;
else
	reward = environment.successReward;    
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions  for 'medical_treatment'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getPreferenceForMedicalTreatment( state1, state2 )

ret = 1;
vec1 = state1.values(1:state1.sdim);
vec2 = state2.values(1:state2.sdim);

for i1 = 1:length(ret)
    
end

return;


function state = getInitialStateForMedicalTreatMent()

% tumor size
% toxicity
% time
% alive


state.values = [0,0,1];
state.values(1) = rand() * 2.0;
state.values(2) = rand() * 2.0;

state.initStateValues = state.values;
state.terminal = 0;
state.sdim = 2;
state.step = 1;
return;

function newState = getNextStateForMedicalTreatMent( state, action, environment )

newState = state;

if (isfield(action,'value'))
    Dt = action.value;
else
    Dt = environment.avalues(action.actionIdx(1));
end

% tumor size
term1 = environment.parameters{1} * max( state.initStateValues(2), state.values(2) );
term2 = environment.parameters{3} * ( Dt - environment.parameters{8});
deltaS = state.values(1)>0;
deltaS = deltaS * (term1 - term2);
newState.values(1) = newState.values(1) + deltaS;

% toxicity
term1 = environment.parameters{2} * max( state.initStateValues(1), state.values(1) );
term2 = environment.parameters{4} * ( Dt - environment.parameters{9});
deltaX = term1 + term2;
newState.values(2) = newState.values(2) + deltaX;


% time
newState.step = newState.step + 1;
if (newState.step>=environment.episodeLength)
    newState.terminal = 1;
end

% death
probDeath = feval( environment.funcs{1}, newState, environment.parameters(5:7) );
newState.values(3) = rand() <= probDeath;
if (newState.values(3)==0)
    newState.terminal = 1;
end


return;

function reward = getRewardMedicalTreatMent( oldState, newState, environment )


% tumor size
% toxicity
% alive


if(newState.values(3)==0) % isDeath
    reward = environment.rewardOfDeath;
    return;
end

if (newState.values(2)-oldState.values(2) <= -0.5)
    r2 = 5;
elseif(newState.values(2)-oldState.values(2) >= 0.5)
    r2 = -5;
else
    r2 = 0;
end

if(abs(newState.values(1))<environment.tolerance)
    r3 = 15;    
elseif(newState.values(1)-oldState.values(1) <= -0.5)
    r3 = 5;
elseif (newState.values(1)-oldState.values(1) >= 0.5)
    r3 = -5;
else
    r3 = 0;
end

reward = r2+r3;

return;

function prob = getDeathProb(state, pars)
prob = exp(-exp(pars{1} + pars{2} * state.values(2) + pars{3} * state.values(1)));
%prob=1;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
