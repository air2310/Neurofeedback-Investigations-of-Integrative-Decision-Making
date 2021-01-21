%% Setup Dot Coordinates

n.fields = 2;

DOT_XY = NaN(2,dots.n,n.fields);

for FIELD = 1:n.fields
    DOT_XY(:,:,FIELD) = SetupDotCoords(dots)';
end


% DOT_XY = NaN(2,dots.n,n.fields,n.trials);
% for Trial = 1:n.trials
%     for FIELD = 1:n.fields
%         DOT_XY(:,:,FIELD,Trial) = SetupDotCoords(dots)';
%     end
% end

%% Setup dot direction of motion

% directions to show
directions = 0:22.5:337.5;
n.dir = length(directions);

% options for a second direction for each direction
Dother = NaN(1, n.dir);
for DD = 1:n.dir
    tmp =  wrapTo360(directions(DD)+AngDiff);
    if tmp == 360; tmp = 0; end
    Dother(DD) = find(ismember(directions, tmp));
end

% Build up vector of directions for each trial
n.trialsDir = n.trials/(n.dir-1);
tmpDirs = [];
for DD = 1:n.dir
    tmpDirs = [tmpDirs; ones(n.trialsDir,1).*DD];
end
% random order of directions
Dir1 = tmpDirs(randperm(n.trials));

% get the other direction
Dir2 = Dother(Dir1)';

%% Directions for rotation case

RotationAng = 45;
for DD = 1:n.dir
    DirectionsRot(DD) =  wrapTo360(directions(DD)-RotationAng);
    if tmp == 360; tmp = 0; end
end
%  [directions; DirectionsRot]
%% Counterbalance direction difference with frequency and colour trained. 
FIELDsTrain = DATA(:,D.idxHz_Trained);

DirectFields = NaN(n.trials,2);
for CC = 1:2
    % - Get trials for this freq condition (when Freq CC is trained)
    idx.cond = FIELDsTrain == CC;
    idx.cond = find(idx.cond);
    n.trialsCond = length(idx.cond);
    
    % arrange random split between trained and untrained going in Dir 1 and
    % Dir 2.
    tmpDirs2 = [];
    for ii = 0:1
        tmpDirs2 = [tmpDirs2; ones(n.trialsCond/2,1).*ii];
    end
    tmpDirs2 = tmpDirs2(randperm(n.trialsCond));
    
    
    % Fill DirectFields for this freq condition, such that half the time
    % Freq 1 gets Dir1 and hald the time Freq 2 gets Dir1.
    
    DirectFields(idx.cond(~~tmpDirs2), 1) = Dir1(idx.cond(~~tmpDirs2));
    DirectFields(idx.cond(~~tmpDirs2), 2) = Dir2(idx.cond(~~tmpDirs2));
    
    DirectFields(idx.cond(~tmpDirs2), 1) = Dir2(idx.cond(~tmpDirs2));
    DirectFields(idx.cond(~tmpDirs2), 2) = Dir1(idx.cond(~tmpDirs2));
    
end


%% Flicker Frequencies

n.Hz = length(Hz);
t = 0 : 1/mon.ref : s.dotsmove - 1/mon.ref;

%% Gen Flicker Sin Waves

options.flickType = 1; % 1 - sin, 2 - square

switch options.flickType
    case 1
        FLICK = NaN(f.dotsmove, n.Hz);
        for HH = 1 : n.Hz
            sig = 0.5 + 0.5*sin(2*pi*Hz(HH)*t ); %+ 2*pi*rand);
            sig = sig.*255;
            
            FLICK(:,HH) = sig;
        end
    case 2
        
        FLICK = NaN(f.dotsmove, n.Hz);
        for HH = 1 : n.Hz
            sig = 0.5 + 0.5*sin(2*pi*Hz(HH)*t ); %+ 2*pi*rand);
            
            sig = round(sig);
            sig = sig.*255;
            
            FLICK(:,HH) = sig;
        end
        
%         figure; plot(round(FLICK(:,1)/255))
%         sum(round(FLICK(:,1)/255)==0)
%         sum(round(FLICK(:,1)/255)==1)
        
end

F = 0 : 1/s.dotsmove : mon.ref - 1/s.dotsmove;
figure; plot(F, abs(fft(FLICK))./f.dotsmove)
legend({num2str(Hz(1)) num2str(Hz(2))})
%% Create Flicker Matrix out of multiple dots at each frequency
FLICKER = NaN(length(FLICK), dots.n, n.Hz);
colvect = NaN(3, dots.n, n.Hz);
FRAME = 1;

for HH = 1:n.Hz
    FLICKER(:,:,HH) = uint8(repmat(FLICK(:,HH), 1, dots.n));
    colvect(:,:,HH) = repmat(FLICKER(FRAME,:,HH),3,1);
end
