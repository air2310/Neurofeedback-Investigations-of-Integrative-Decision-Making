clear
clc
close all

%% Options

options.trigger = 1;

%% directories

PCuse = 4; % 1 - LAB,  2 - LAPTOP, 3 - BioSemi, 4 - LABNEW

switch PCuse
    case 1        
        direct.main = 'E:\';
    case 2     
        direct.main = 'C:\Users\uqarento\Documents\';
    case 3        
        direct.main = 'C:\Users\cogneuro_admin\Documents\Angie\';
    case 4
        direct.main = 'C:\Users\labpc\Documents\';
end

direct.toolbox = [direct.main 'toolboxes\'];

% IP
direct.ip = [direct.toolbox 'GetIP\']; addpath(direct.ip)

% - buffer

direct.commonBCIfunctions = 'commonBCIfunctions\';
direct.buffer = [direct.toolbox direct.commonBCIfunctions 'bufferDRP\'];
direct.realtime_hack = [ direct.toolbox 'realtime_hack_07-12-2016\' ];

% - artificial Data
direct.data_artificialstream = [pwd '\Data\ArtificialStream\'];

addpath( direct.buffer )
addpath( direct.realtime_hack )


%% get artificial Data 

load( [ direct.data_artificialstream 'someDATA_6Hz_7.5Hz_Tags.mat' ],'EEG3', 'TYPE', 'LATENCY3', 'fs', 'trig', 'DATA2');
fs = fs/4;
DATA = DATA2;
DATA(~~(DATA(:,5)),5) = TYPE(find(ismember(TYPE, trig.trial)));

n.x = mean(diff(find(DATA(:,5))));
LATENCY_USE = find(DATA(:,5));

% LATENCY3(2) = [];
% TYPE(2) = [];
% 
% tmp = zeros(length(EEG3),1);
% tmp(LATENCY3) = TYPE;
% DATA = [EEG3 tmp];

% idx = length(DATA2)/2;
% DATA = DATA2(idx:end,:);



%% save "current Observer"
observer = 'artificial';

save( 'currentObserver.mat', 'observer', 'fs')


%% Buffer Settings
cfg.host = 'localhost';
cfg.stream = 1972;

cfg.fs = 512;
cfg.nsamples = 1;
cfg.nChannels = 5;
cfg.dataType = 9; % single precision

%% start buffer
hdr = startBuffer( direct, cfg.stream, cfg.nChannels, cfg.nsamples, cfg.fs, cfg.dataType ); % single precision


%% Start TCP Server
if options.trigger
    
    tcp.IP = getIP(direct.ip);
    
    tcp.networkRole = 'server';
    
    tcp.Ptr = tcpip(tcp.IP, 'NetworkRole', tcp.networkRole);
    fopen(tcp.Ptr)
    
    trig.stopTrial = 5;
end
%% ----- put data in ring buffer

if options.trigger
    
    for TRIAL = 1:inf
        % wait for trial start trigger
        while tcp.Ptr.BytesAvailable == 0
            %Wait for trial to start.
        end
        fread(tcp.Ptr, tcp.Ptr.BytesAvailable);
        disp(['TRIAL:' num2str(TRIAL)])
        % send one trials worth of data
        
        elapsed = 0;
        timer = tic;
        timer2 = tic;
        for IDX = LATENCY_USE(TRIAL) : LATENCY_USE(TRIAL) + n.x -1
            
            hdr.buf = single(DATA( IDX, :));
            buffer('put_dat', hdr, cfg.host, cfg.stream )
            
            %- timing things
            if IDX == LATENCY_USE(TRIAL) + 512
               disp('1 sec in?') 
               toc(timer2)

            end

            elapsed = toc(timer) ;
            while elapsed < 1/cfg.fs  %hang; 
                elapsed = toc(timer);
            end
            timer = tic;
            
            if tcp.Ptr.BytesAvailable > 0
                tmp = fread(tcp.Ptr, tcp.Ptr.BytesAvailable);
                if tmp == trig.stopTrial
                    disp('end trial trig')
                    
                    break;
                end
            end
        end
    end
else
    
    idx = 0;
    
    for ii = 1:floor(length(DATA)/cfg.nsamples)
        
        idx = idx + cfg.nsamples;
        
        hdr.buf = single(DATA(idx, :));
        
        buffer('put_dat', hdr, cfg.host, cfg.stream )
        
        pause(1/cfg.fs)
    end
end


