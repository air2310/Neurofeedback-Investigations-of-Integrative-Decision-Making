%% Neurofeedback, Attention and Decision making Experiment - Read Buffer
%             ______    ___    _________    ___    ___    _________     __________     
%            /\      \ /\  \  /\   _____\  /\  \  /\  \  /\   ___  \   /\   ____  \  
%            \ \  \\ \ \ \  \ \ \  \____/_ \ \  \ \ \  \ \ \  \__\   \ \ \  \__/\  \
%             \ \  \ \ \ \\  \ \ \   _____\ \ \  \ \ \  \ \ \   __   /  \ \  \ \ \  \ 
%              \ \  \  \ \    \ \ \  \____/_ \ \  \_\_\  \ \ \  \  \  \  \ \  \_\_\  \  
%               \ \_ \   \ \ __\ \ \________\ \ \_________\ \ \__\\  \__\ \ \_________\  
% 	             \/__/     \/__/  \/________/  \/_________/  \/__/  \/__/  \/_________/   
%
% This script reads the g.tec buffer using the settings and data
% directories associated with the AttDecNF Project
%
% Angela. I. Renton (April '18)

%% Start

input( 'Press enter to begin Read Amplifiers' )

%% Clean up before running script

direct.functions = 'Functions\'; addpath(genpath(direct.functions));
StopAmp % If amp is streaming, stop!

%% Setup Directories

SUB = 4;

SetupDirectories

%% Setup Settings

options.practice = 0; options.DisplayStream = 0;
SetupSettings
options.EyeTracking = 0;

%% setup triggering

SetupTriggers
io64(trig.ioObj, trig.address(1), 0);

%% Realtime Data Saving Saving

FNAME = [ observer.fname '.bin' ];
fileID = fopen( [ direct.data FNAME ], 'w');

%% channels 2 acquire
% check amplifer order for channel order (1:16 - amp1, 17:32 - amp2, 33:48 - amp3, 49:64 - amp4)

% idx.channels2acquire =  1:4 ;
% idx.channels2acquire =  1:16 ;
idx.channels2acquire =  1:20 ;
% idx.channels2acquire =  1:32 ;


%% amplifer options

% supported_fs = [32 64 128 256 512 600 1200 2400 4800 9600 19200 38400];
fs = 1200; % sampling_rate
options.NumberOfScans = 64; % if not == 0, override defaults - check user manual for recomendations

options.filter = 1; % 1 or 0

% options.CommonGround = logical( [0 0 0 0] ); % g.tec: Array of 4 bool elements to enable or disable common ground
% options.CommonReference = logical( [0 0 0 0] ); % g.tec: Array of 4 bool values to enable or disable common reference

options.CommonGround = logical( [1 1 1 1] ); % g.tec: Array of 4 bool elements to enable or disable common ground
options.CommonReference = logical( [1 1 1 1] ); % g.tec: Array of 4 bool values to enable or disable common reference

options.ShortCutEnabled = false; % g.tec: Bool enabling or disabling g.USBamp shortcut
options.CounterEnabled = false; % makes channel 16 a counter channel: Show a counter on first recorded channel which is incremented with every block transmitted to the PC. Overruns at 1000000.
options.TriggerEnabled = true; % appends recorded channels with new trigger channel g.tec: scan the digital trigger channel with the analog inputs

%% gUSBampInternalSignalGenerator (all amplifiers have the same generator when synchronized)

gusbamp_siggen = gUSBampInternalSignalGenerator();

gusbamp_siggen.Enabled = false; % g.tec: true or false
gusbamp_siggen.Frequency = 10;
gusbamp_siggen.WaveShape = 3; % Can be 1 (square), 2 (saw tooth), 3 (sine) 4 (DRL) or 5 (noise)
gusbamp_siggen.Amplitude = 10; % mV (max 250)
gusbamp_siggen.Offset = 0;

%% amplifer Filter settings

gtecFilterSettings

%% configure Amplifiers

gtecConfigureAmps

%% save observer & amp settings in .mat for sharing across threads

save( [direct.data 'currentObserver.mat'], 'observer', 'direct', 'fs', 'NumberOfScans', 'idx', 'N' )

%% EEG broadcast buffer!

% !taskkill /F /IM buffer.exe /T
% !taskkill /F /IM cmd.exe /T

% hdr = startBuffer2( direct, cfg, N.channels2acquire, NumberOfScans, fs, 9 ); % single precision
hdr = startBuffer( direct, cfg.stream_raw, N.channels2acquire, NumberOfScans, fs, cfg.dataType, cfg.host ); % single precision

%% start acquisition

disp('starting aquisition...')
tic; gds_interface.StartDataAcquisition(); toc
pause(.5)

%% ----- trig.startRecording
    
disp( 'Sending trig.startRecording to SSVEP Stream...' )
io64( trig.ioObj, trig.address(1), trig.startRecording)

disp('collecting, saving & transmitting data...');

%% record data

while true
    
    % ----- read data from amplifiers
    
    [scans_received, data] = gds_interface.GetData( NumberOfScans ); % size of data reflects the number of synchronized amplifiers
    
    data = data(:,1:N.channels2acquire);
    
	% ----- put data in ring buffer
    hdr.buf = data';
    buffer('put_dat', hdr, cfg.host, cfg.stream_raw )

    % ----- write data to file
    fwrite(fileID, data', 'float32');

    %% ----- trig.stopRecording
    
    TRIG = io64( trig.ioObj, trig.address(1) );
    if TRIG == trig.stopRecording % close if stop signal
        break
    elseif ismember(TRIG, trig.BLOCK)
        io64(trig.ioObj, trig.address(1), 0)
%         buffer('flush_dat', [], cfg.host, cfg.stream_raw )
    end
    
end

toc

%% stop acquisition

fclose(fileID); fclose('all');
StopAmp

%% open data

fid = fopen( [ direct.data FNAME ], 'rb');
DATA2 = fread(fid, [N.channels2acquire inf], 'float32')';
fclose(fid);

%% Get Best Electrodes
trigChan = 17;
if any(ismember(DATA2(:,trigChan), trig.staircase ))
   getBestElectrodes 
elseif any(ismember(DATA2(:,trigChan), trig.StripeAmp ))
    addpath('Analyses\')
   StripeTest
end

%% Plot
figure; hold on;

if size(DATA2,1) > fs*20
    datplot = DATA2(fs*3:fs*20,:);
else
    datplot = DATA2(fs*3:end,:);
end

space = 0;
chanexclude = [];
for CC = 1:N.channels2acquire
    space = space + 50;
    if ~ismember(CC,chanexclude)
        plot(datplot(:,CC) + space)
    end
end
% ylim([-100 +100])

%% Plot Trigger Chan

figure
plot(DATA2(:,17))

%% Save
close all;
if any(ismember(DATA2(:,trigChan), trig.staircase ))
    save([direct.data observer.fname '_EEG_DATA_STAIRCASE.mat'])
    return
elseif any(ismember(DATA2(:,trigChan), trig.StripeAmp ))
    save([direct.data observer.fname '_EEG_DATA_STRIPEAMP.mat'])
    return
else
    save([direct.data observer.fname '_EEG_DATA.mat'])
end

%% Figures

addpath('Analyses\')
MainAnalysis_RT