%% Neurofeedback, Attention and Decision making Experiment - Realtime Analysis
%  _________    _________    _________    ________      ________       ______      ________    ___	  ___
% /\   _____\  /\   _____\  /\   _____\  /\   ____ \   /\   ___  \	  /  ____ \   /\   ____\  /\  \  /  /
% \ \  \____/_ \ \  \____/_ \ \  \____/_ \ \  \__/\  \ \ \  \__\  /  /\  \___\  \ \ \  \___/  \ \  \/  /
%  \ \   _____\ \ \   _____\ \ \   _____\ \ \  \ \ \  \ \ \   ___ \  \ \   ____  \ \ \  \      \ \     \
%   \ \  \____/  \ \  \____/_ \ \  \____/_ \ \  \_\_\  \ \ \  \__\  \ \ \  \__/\  \ \ \  \____  \ \  \\  \
%    \ \__\       \ \________\ \ \________\ \ \________/  \ \_______/  \ \__\ \ \__\ \ \_______\ \ \__\ \__\
%     \/__/        \/________/  \/________/  \/_______/    \/______/    \/__/  \/__/  \/_______/  \/__/\/__/
%
% This scipt reads the EEG data from a memory buffer created in
% % readAmplifiers_AttnDecNF and calculates the Measure of selectivity used
% to generate neurofeedback in the script DotFields_V8
%
% Angela. I. Renton (April '18)

%% Directories

SUB = 4;

direct.functions = 'Functions\'; addpath(direct.functions);
SetupDirectories


%% load current observer

load( [direct.data 'currentObserver.mat'], 'fs' )

%% setup Settings

options.practice = 0; options.DisplayStream = 0;
SetupSettings
options.EyeTracking = 0;

%% setup triggering

SetupTriggers

%% start fieldtrip buffer

hdr = startBuffer( direct, cfg.stream, cfg.nChannels, cfg.nsamples, cfg.fs, cfg.dataType, cfg.host ); % single precision

%% timing variables

lim.s = [-1 0];
lim.s_trial = [0 3];
lim.s_zeropad = [0 2];

lim.x = lim.s.*fs;
lim.x(1) = lim.x(1) + 1;

n.s = lim.s(2)-lim.s(1);
n.x = (lim.x(2)-lim.x(1)) +1;

n.x_trial = (lim.s_trial(2) - lim.s_trial(1)).*fs;

t = lim.s(1):1/fs:lim.s(2)-1/fs;

f = 0 : 1/n.s : fs - 1/n.s; % f = 0 : 1/n.s : fs;

%% Zeropad timing

lim.s_ZP = [0 2];

lim.x_ZP= lim.s_ZP.*fs;
lim.x_ZP(1) = lim.x_ZP(1) + 1;

n.s_ZP = lim.s_ZP(2)-lim.s_ZP(1);
n.x_ZP = (lim.x_ZP(2)-lim.x_ZP(1)) +1;

t_ZP = lim.s_ZP(1):1/fs:lim.s_ZP(2)-1/fs;

f_ZP = 0 : 1/n.s_ZP : fs - 1/n.s_ZP; % f = 0 : 1/n.s : fs;


%% Hz indices

n.Hz = length(Hz);

for HH = 1:n.Hz
    [~,idx.Hz(HH)] = min(abs(f-Hz(HH)));
end

%% Hz indices

n.Hz = length(Hz);

for HH = 1:n.Hz
    [~,idx.Hz_ZP(HH)] = min(abs(f_ZP-Hz(HH)));
end

%% Channel Settings

chanlocs_gtec_20

n.chan = length(str.chan);
idx.trig = find(strcmp('trig', str.chan));

if exist([direct.data str.sub 'BEST_ELECTRODES.mat'])
    load([direct.data str.sub 'BEST_ELECTRODES.mat'])
    BEST(BEST>=idx.trig) = BEST(BEST>=idx.trig) +1;
else
    chan2use = {'Iz' 'Oz' 'O1' 'O2' };
    n.chan2use = length(chan2use);
    
    for CC = 1:n.chan2use
        idx.chan2use(CC) = find(strcmp(chan2use{CC}, str.chan));
    end
    
    BEST = [idx.chan2use; idx.chan2use];
end

%% Baseline values

fname = dir([direct.data  '*SSVEPStreamSTAIRCASE.mat']);
if ~isempty(fname)
    load([direct.data fname.name], 'BaselineM', 'BaselineSD');
    UseBaseline = 1;
else
    UseBaseline = 0;
end
%  UseBaseline = 0;
%% Set up the big variables

DATA = NaN(fs*60*120, n.chan);
LATENCY = NaN(fs*60*120, 1);

%% Wait for buffer to be set up by readAmplifiers

while io64( trig.ioObj, trig.address(1)) ~= trig.startRecording
    % Wait
end
io64( trig.ioObj, trig.address(1), 0 )
disp('Connected to Buffer Stream!')

%% Initialise variables

% initialise stream counting
idx.epoch = lim.x;

% initialise data reading variables

idx.samplesRead = readBufferSamples( cfg.stream_raw ) -1;

while idx.samplesRead < 0
    idx.samplesRead = readBufferSamples( cfg.stream_raw ) -1;
end

idx.sampleAlpha = idx.samplesRead;
% DATA = [];
% LATENCY = [];


data = zeros(1, n.chan);

% initialise trial tracking
TrialRunning = false; % is there a trial in progress.
TRIAL = 0;

% initialise timers
WriteTimer = tic;
ReadTimer = tic;
readTiming = [];


% initialise AMP tracking
AMP_exp = NaN(n.Hz, n.x_trial + 1, n.trials);

% AMP_ALL = NaN(fs/2, n.x_trial + 1,  n.trials); % spectrum

% initialise Selectivity Variables
Z.Mean = NaN(n.Hz, n.x_trial + 1, n.trials);
Z.SD = NaN(n.Hz, n.x_trial + 1, n.trials);
Z.Z = NaN(n.Hz, n.x_trial + 1, n.trials);
Z.Diff = NaN(n.x_trial + 1, n.trials);
Z.TrigUsed =  NaN(n.x_trial + 1, n.trials);

% initialise data to write
datstream = 0;
calctime = [];

Z.M_start = 2.5;
Z.SD_start = 1;


%% Stream!
% figure;
while true
    %% ----- read from the ring buffer
    nSamples = readBufferSamples( cfg.stream_raw ); % how much data is available?
    
%     % When buffer is flushed!
%     if (nSamples - idx.samplesRead) < -fs 
%         idx.samplesRead = readBufferSamples( cfg.stream_raw ) -1;
%         
%         while idx.samplesRead < 0
%             idx.samplesRead = readBufferSamples( cfg.stream_raw ) -1;
%         end
%         
%         idx.sampleAlpha = -LATENCY(end);
%         
%     end

    if nSamples > idx.samplesRead % update if new information available
        %       disp('Reading Data')
        % read data
        latencyRead = idx.samplesRead    :   nSamples-1; % latency of this chunk
        data = readBufferData( [latencyRead(1) latencyRead(end)], cfg.stream_raw );
        latency = latencyRead - idx.sampleAlpha +1; % reading started after writing - we don't want to keep a bunch of useless data in memory twice though - so just rereference to data read here.
        
        % update next datapoint to read first.
        idx.samplesRead = nSamples;
        
        % add data to collection
%         DATA = [DATA; data];
%         LATENCY = [LATENCY; latency'];
        
        DATA(latency,:) = data;
        LATENCY(latency) = latency;
        
        % update read timing vector
        readTiming = [readTiming; toc(ReadTimer)];
        
        %% Wait for triggers
        
        if latency(1) > 1
            idx.tmp = find(diff([DATA(latency(1)-1,idx.trig); data(:,idx.trig)]));
            idx.tmp = idx.tmp(ismember(data(idx.tmp,idx.trig), trig.StartTrial));
        else
            idx.tmp = 0;
        end
        
        if any(idx.tmp)
%             if any(ismember(data(idx.tmp,idx.trig), trig.StartTrial))
                % where is the trigger?
                idx.lastTrialTrig = idx.tmp;
                idx.LatencyLastTrialTrig = latency(idx.lastTrialTrig);
                
                % update trial variables
                LastTrig = data(idx.lastTrialTrig,idx.trig);
                TrialRunning = true;
                TRIAL = TRIAL + 1;
                disp(['TRIAL: ' num2str(TRIAL)])
                a = tic;
%             end
        end
        
        %% start streaming
        
        if TrialRunning
            
            idx.epoch = lim.x + latency(end) ; % epoch to analyse - idx in DATA
            idx.amp = idx.epoch(2) - idx.LatencyLastTrialTrig +1; % when in the trial will these FFT amps represent
            
            if  (idx.amp > n.x) && (idx.amp <= n.x_trial) % wait till appropriate time has elapsed so that SSVEPs represent trial time!
                
%                 if idx.amp == n.x + 1
%                     disp('sending Data')
%                 end
                
                %% EPOCH
                
                epoch = DATA(idx.epoch(1) : idx.epoch(2),:);
                epoch = detrend(epoch, 'linear');
                
                %% ZEROPADDING!
%                 
%                 epoch2 = [zeros(fs/2, n.chan); epoch; zeros(fs/2, n.chan)];
%                 
%                  %% Get FFT AMP
%                  
%                 amp = abs( fft( epoch2 ) )/n.x_ZP;
%                 amp(2:end-1,:) = amp(2:end-1,:)*2;
%                 
%                 %% Calculate Z scores
%                 
%                 for HH = 1:n.Hz
%                     
%                     AMP_exp(HH,idx.amp, TRIAL) = mean(amp(idx.Hz_ZP(HH), BEST(HH,:)),2); % average AMP
%                     
%                     dat = AMP_exp(HH, :,:);
%                     dat(dat==0) = NaN;
%                     
%                     if TRIAL < 20 && UseBaseline % When population hasn't built up much, use baseline values
%                         Z.Mean(HH,idx.amp, TRIAL) = BaselineM(HH);
%                         Z.SD(HH,idx.amp, TRIAL) = BaselineSD(HH);
%                     else
%                         Z.Mean(HH,idx.amp, TRIAL) = nanmean(dat(:));
%                         Z.SD(HH,idx.amp, TRIAL) = nanstd(dat(:));
%                     end
%                     
%                     if Z.SD(HH,idx.amp, TRIAL) == 0
%                         Z.Z(HH,idx.amp, TRIAL) = 0;
%                     else
%                         Z.Z(HH,idx.amp, TRIAL) = (AMP_exp(HH, idx.amp, TRIAL) - Z.Mean(HH,idx.amp, TRIAL)) / Z.SD(HH,idx.amp, TRIAL);
%                         
%                     end
%                 end
                
                
                %% Get FFT AMP
                amp = abs( fft( epoch ) )/n.x;
                amp(2:end-1,:) = amp(2:end-1,:)*2;
                
                %                 AMP_ALL(:, idx.amp, TRIAL) =  mean(amp(1:fs/2, unique(BEST(HH,:))),2);
                
                %% Plot Live?
                %  plot(f(1:21), amp(1:21)); drawnow;
                
                %% Calculate Z scores
                
                for HH = 1:n.Hz
                    
                    AMP_exp(HH,idx.amp, TRIAL) = mean(amp(idx.Hz(HH), BEST(HH,:)),2); % average AMP
                    
                    dat = AMP_exp(HH, :,:);
                    dat(dat==0) = NaN;
                    
                    if TRIAL < 20 && UseBaseline % When population hasn't built up much, use baseline values
                        Z.Mean(HH,idx.amp, TRIAL) = BaselineM(HH);
                        Z.SD(HH,idx.amp, TRIAL) = BaselineSD(HH);
                    else
                        Z.Mean(HH,idx.amp, TRIAL) = nanmean(dat(:));
                        Z.SD(HH,idx.amp, TRIAL) = nanstd(dat(:));
                    end
                    
                    if Z.SD(HH,idx.amp, TRIAL) == 0
                        Z.Z(HH,idx.amp, TRIAL) = 0;
                    else
                        Z.Z(HH,idx.amp, TRIAL) = (AMP_exp(HH, idx.amp, TRIAL) - Z.Mean(HH,idx.amp, TRIAL)) / Z.SD(HH,idx.amp, TRIAL);
                        
                    end
                end
                
                %% Selectivity!
                
                % trig.StartTrial = [
                %     1 3
                %     2 4];
                
                % FTRAIN(1) - trained frequency: [1 2] or [2 1]
                % CTRAIN(1) - orientation trained: [1 2] or [2 1]
                
                % SendTrig(trig, trig.StartTrial(FTRAIN(1),CTRAIN(1)), options)
                
                TrigUse =  io64(trig.ioObj, trig.address(2));
                Z.TrigUsed(idx.amp, TRIAL) = TrigUse;
                switch TrigUse
                    case {1,3}
                        Z.Diff(idx.amp, TRIAL) = Z.Z(1,idx.amp, TRIAL) - Z.Z(2,idx.amp, TRIAL);
                    case {2,4}
                        Z.Diff(idx.amp, TRIAL) = Z.Z(2,idx.amp, TRIAL) - Z.Z(1,idx.amp, TRIAL);
                end
                
                
                %% position of frequency
                datstream = Z.Diff(idx.amp, TRIAL);
                %             disp(datstream)
                
                %% Write Datastream
                
                hdr.buf = single(datstream);
                
                elapsedTime = toc(WriteTimer);
                
                buffer('put_dat', hdr, cfg.host, cfg.stream )
                
                WriteTimer = tic;
                calctime = [calctime elapsedTime];
                
            else
                if idx.amp > n.x_trial
                    TrialRunning = false;
                end
            end
            
        end
    end
    %% ----- trig.stopRecording
    if io64( trig.ioObj, trig.address(1) ) == trig.stopRecording % close if stop signal
        break
    end
    
end

%% SAVE!


if any(DATA(:,idx.trig)==trig.staircase)
    tmp = Z.Mean(:,:,TRIAL);
    tmp(:,isnan(tmp(1,:))) = [];
    BaselineM = tmp(:,end);
    
    tmp = Z.SD(:,:,TRIAL);
    tmp(:,isnan(tmp(1,:))) = [];
    BaselineSD = tmp(:,end);
    
    save([direct.data observer.fname 'SSVEPStreamSTAIRCASE.mat']);
else
    save([direct.data observer.fname 'SSVEPStream.mat']);
end

%% Analyse
% pause(30)
% PreliminaryAnalysis_SSVEPStream

%% Trigger things
TTRIG = ( Z.TrigUsed(:, 1:TRIAL));
TTRIG(TTRIG == trig.stopTrial) = NaN;

figure; stem(nanmean(TTRIG))

%% 
figure;
plot(diff(readTiming))
