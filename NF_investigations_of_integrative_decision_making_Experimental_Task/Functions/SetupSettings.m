
%% Monitor Settings

mon.use = 2;
mon.ref = 120;

%% Computer settings

options.hideCursor = true;

%% Triggers

options.triggertype = 1; % 1 = PCI, 2 = tcp

%% Staircase

options.staircase = 0;

%% Eye Tracking

options.EyeTracking = 1;

%% Trial Settings

if ~options.practice
    n.blocks = 12;
    n.trialsBlock = 60;
else
    n.blocks = 1;
    n.trialsBlock = 120;
end
n.trials = n.trialsBlock*n.blocks;

CatchTrialRatio = 0.1; % Percentage of "Catch Trials" with no neurofeedback;

%% Dot Coherence Settings

if exist([direct.data 'SD_THRESHOLD.mat'],'file')
    load([direct.data 'SD_THRESHOLD.mat'])
    
    sc.newRange = THRESHOLD_mean*0.80;
    sc.CatchTrialSD = THRESHOLD_mean*0.5;

else
    if options.DisplayStream
        warning('No SD threshold available yet! Press [ENTER] to continue anyway:')
        input('[ENTER]?')
    end
    sc.newRange = 50; % size of one tail
    sc.CatchTrialSD = sc.newRange/2;
end

% sc.oldRange = 10/2; % size of one tail in Z score Diff
sc.oldRange = 5/2; % size of one tail in Z score Diff

%% Timing Settings

s.trial = 5;
s.dotsmove = 3;
s.feedback = 1;
s.BlockBreakEnforce = 10;

s.exp = s.trial*n.trials;

tmp = fields(s);
for ii = 1:length(tmp)
    f.(tmp{ii}) = s.(tmp{ii})*mon.ref;
end

%% Frequency settings

Hz = [13 15]; 
% Hz = [12 15]; 
% Hz = [15 17.1429]; 
% Hz = [15 17]; 
% Hz = [14 17]; 
% Hz = [15 19]; 
% Hz = [16 18]; 
% Hz = [20 24]; 
% Hz = [15 20]; 
% Hz = [5 6];

%% Dot settings

AngDiff = 67.5; % difference between directions

fix_r       = 6; % radius of fixation point (deg)

dots.speed   = 80;    % dot speed (pixels/sec)
dots.speed_frame = dots.speed / mon.ref;  % dot speed (pixels/frame)

dots.n       = 400; % number of dots

dots.max_d       = 300;%310;   % maximum radius of  annulus (pixels)
dots.width       = 20;%12; %pixels - larger dots is slower!

FieldOffset = [-1 1].*0;  % left right firld offset from centre.


lineWidthPix = 6; % for response

%% Colours/ Dot Type

dotType = 2;
options.rotate = 1;
freq.A = 1; freq.B = 2;
coord.x = 1; coord.y = 2;

switch dotType
    case 1
        str.cond = {'red' 'blue'};
        
        dots.cols = [
            1 0 0;
            0 0.5 1];
        
        % - load colour matching
        if exist([direct.threshold 'colourTHRESHOLD.mat'],'file')
            disp('loading threshold')
            load([direct.threshold 'colourTHRESHOLD.mat'])
            
            THRESHOLD2 = THRESHOLD(4)/255;
            dots.cols(2,:) = [0 0.5 1].*THRESHOLD2;
        else
            warning('No colour threshold available yet! Press [ENTER] to continue anyway:')
            input('[ENTER]?')
        end
        
    case 2
        str.cond = {'Horizontal' 'Vertical'};
        
        dots.cols = [
            1 1 1;
            1 1 1];
        
        W = 12;
        H = 4;
        
end

%% Escape key

key.esc = 27;
key.enter = 13;

%% Buffer Settings
% IP = getIP(direct.ip);
% cfg.host = IP;
cfg.host = 'localhost';
cfg.stream = 1314;
cfg.stream_raw = 1982;

cfg.fs = mon.ref;
cfg.StreamChunk_size = 1/cfg.fs;
cfg.nsamples = 1;
cfg.nChannels = 1;
cfg.dataType = 9; % single precision

