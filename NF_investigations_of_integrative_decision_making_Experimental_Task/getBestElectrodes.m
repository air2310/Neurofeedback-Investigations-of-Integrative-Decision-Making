
%% Load Chanlocs

load('gtecChanlocs20.mat');

%% Sort out data

chanlocs_gtec_20 % includes trigger channel to be removed.
idx.trig = strcmp(str.chan, 'trig');
idx.chan = ~idx.trig;

n.chan = length(chanlocs);

EEG = DATA2(:,idx.chan);
TRIGGERS = DATA2(:,idx.trig);

% - Get triggers
tmp = [0; diff(TRIGGERS)];
LATENCY = find(tmp);
TYPE = TRIGGERS(LATENCY);

figure; stem(LATENCY, TYPE);

%% Timing Settings

lim.s = [0 2];
lim.x = lim.s.*fs;

n.s = lim.s(2) - lim.s(1);
n.x = lim.x(2) - lim.x(1);

lim.x(1) = lim.x(1) + 1;

t = lim.s(1) : 1/fs : lim.s(2) - 1/fs;
f = 0 : 1/n.s : fs - 1/n.s;


%% Frequency Settings

n.Hz = length(Hz);

for HH = 1:n.Hz
    str.COND{HH} = ['BEST ELEC ' num2str(Hz(HH)) 'Hz'];
    str.Hz{HH} = [num2str(Hz(HH)) 'Hz'];
    [~, idx.Hz(HH)] = min(abs(f-Hz(HH)));
end

%% Channels

str.chanBlinkless = {chanlocs.labels};
n.chanBlinkless = length(str.chanBlinkless);

idx.chanBlinkless = NaN(n.chanBlinkless,1);
for CC = 1:n.chanBlinkless
    idx.chanBlinkless(CC) = find(strcmp({chanlocs.labels}, str.chanBlinkless{CC}));
end

n.best = 4;

%% get trials

n.COND = 1;
n.trialsCond = sum(ismember(TYPE, trig.StartTrial));

EPOCHs = NaN(n.x, n.chan, n.trialsCond, n.COND);
ampST = NaN(n.x, n.chan, n.trialsCond, n.COND);

ERP    = NaN(n.x, n.chan, n.COND);
AMP    = NaN(n.x, n.chan, n.COND);

trialCount = zeros(1, n.COND);

for COND = 1:n.COND
    idx.trials = find(ismember(TYPE, trig.StartTrial));
    
    idx.start = LATENCY(idx.trials) + lim.x(1);
    idx.stop  = LATENCY(idx.trials) + lim.x(2);
    
    for TT = 1:length(idx.start)
        %         tmp = EEG(idx.start(TT) : idx.stop(TT), idx.chan2use);
        tmp = EEG(idx.start(TT) : idx.stop(TT), :);
        tmp = detrend(tmp, 'linear');
        tmp = tmp - repmat(tmp(1,:), n.x, 1);
        
        check = tmp(:,[n.chanBlinkless ]);
        if ~any(abs(check(:))>150)
            trialCount(COND) = trialCount(COND)+1;
            EPOCHs(:,:,TT, COND) = tmp;
            
            tmp2 = abs( fft(tmp  ))/n.x;
            tmp2(2:end-1,:) = tmp2(2:end-1,:)*2;
            ampST(:,:,TT, COND) = tmp2;
            
        end
    end
    
    ERP(:,:,COND) = nanmean(EPOCHs(:,:,:,COND),3);
    
    tmp = abs( fft( ERP(:,:,COND) ) )/n.x;
    tmp(2:end-1,:) = tmp(2:end-1,:)*2;
    AMP(:,:,COND) = tmp;
    
end

%% Get Best
BEST = NaN(n.Hz, n.best);
for HH = 1:n.Hz
    tmp = mean(AMP(idx.Hz(HH), idx.chanBlinkless, :),3);
    
    [j, i] = sort(tmp, 'descend');
    BEST(HH,:) = idx.chanBlinkless(i(1:n.best));
    
    %     BEST(1,3)=16;
    %     BEST(2,4)=16;
    str_best{HH} = {chanlocs(BEST(HH,:)).labels};
    
end

save([direct.data str.sub 'BEST_ELECTRODES.mat'], 'BEST', 'str_best')

%%
disp(str_best{HH})
bar( mean(AMP(idx.Hz(HH), idx.chanBlinkless, :),3))
set(gca, 'xTick', 1:length(idx.chanBlinkless), 'xTickLabel', {chanlocs(idx.chanBlinkless).labels})
%% Plot ERPs


h = figure; hold on;
for HH = 1:n.Hz
    dat = squeeze(nanmean(ERP(:,BEST(HH,:)),2));
    plot(t, dat)
end

legend(str.COND)
xlabel('Time (s)')
ylabel('EEG Amp (µV)')

tit = ['ERPs Staricase'];
title(tit)

saveas(h, [direct.results str.sub tit '.png'])

%% Plot AMPss

h = figure; hold on;
for HH = 1:n.Hz
    dat = squeeze(nanmean(AMP(:,BEST(HH,:)),2));
    plot(f, dat)
end

xlim([1 28])
legend(str.COND)
xlabel('Frequency (Hz)')
ylabel('FFT Amp (µV)')

tit = ['FFT Spectrum staircase' ];
title(tit)

saveas(h, [direct.results str.sub tit '.png'])

%% Topoplot 
addpath([direct.toolbox 'topoplot\'])
h = figure;
for HH = 1:2
    HEAD = squeeze(AMP(idx.Hz(HH),:));
    % HEAD(strcmp({chanlocs.labels}, 'T8')) = mean(HEAD([20 19 24]));
    % HEAD(strcmp({chanlocs.labels}, 'F3')) = mean(HEAD([1 3]));
    
    lims = [min(HEAD(:)) max(HEAD(:))];
    % lims = [0 1.5];
    
    subplot(1,2,HH)
    topoplot(HEAD, chanlocs, 'maplimits', lims, 'electrodes',  'on', 'emarker2', {BEST(HH,:) 'o' 'w' 5 1});
    colorbar
    title([str.Hz{HH}])
end
colormap(jet)

tit = ['Topoplot Staircase'];
suptitle(tit)
saveas(h, [direct.results str.sub tit '.png'])
