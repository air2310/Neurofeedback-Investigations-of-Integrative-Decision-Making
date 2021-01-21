
%% Triggers

trig.StartTrial = [1 2 3 4];
trig.stopTrial = 5;

%% Load Data

% load([direct.data 'S' num2str(SUB) 'SSVEPStream.mat'], 'AMP_exp', 'Z','readTiming', 'calctime', 'TRIAL', 'Hz' );
% n.trials = TRIAL;
% n.trials = 600;

%% Load Cond
switch SystemUsed
    case 'gTec'
        FNAME = dir([direct.data 'S' num2str(SUB) '*DATA.mat']);
        load([direct.data FNAME.name], 'DATA2', 'channelNames', 'fs');
        TRIGGERS = DATA2(:,17);
        tmp = [0; diff(TRIGGERS)];
        LATENCY = find(tmp);
        TYPE = TRIGGERS(LATENCY);
        
        if SUB ==9
            TYPE(1) = [];
            LATENCY(1) = [];
        end

    case 'BioSemi'
        load([direct.data 'S' num2str(SUB) 'EEG.mat'], 'TYPE', 'LATENCY');
        clear idx
end



%% Get triggers

tmp = find(ismember(TYPE, trig.StartTrial));
TYPE2 = TYPE(tmp);

idx.trialsRTSEL{1} = find(ismember(TYPE2, trig.StartTrial(1)));
idx.trialsRTSEL{2} = find(ismember(TYPE2, trig.StartTrial(2)));

%% Check

FNAME = dir([direct.data 'S' num2str(SUB) '*DisplayStream.mat']);
load([direct.data FNAME.name], 'DATA', 'D');

checkType = DATA(1:n.trials,D.idxHz_Trained);
checkType2 = [checkType TYPE2];

if sum(abs(diff(checkType2'))) == 0
   disp('Triggers check out') 
else
   disp('Oh No! something is wrong wrong with the triggers! they dont align with those sent')
end

%% Hz

n.Hz = length(Hz.use);

for HH = 1:n.Hz
    str.Hz{HH} = [num2str(Hz.use(HH)) 'Hz'];
    str.COND{HH} = ['Attend ' num2str(Hz.use(HH)) 'Hz'];
end

%% Read timing

h = figure;
plot(diff(readTiming))
xlabel('reads')

tit = 'Read Timing';
title(tit)
saveas(h, [direct.results str.sub tit '.png'])


%% SSVEP Amps
h = figure; 

for HH = 1:2
    subplot(1,2,HH)
    
    tmp = AMP_exp(HH,:, 1:n.trials);
    tmp = tmp(:);
    tmp(isnan(tmp)) = [];
    
    hist(tmp, 30);
    
    xlim([0 14])
    
    xlabel('SSVEP Amp (µV)')
    ylabel('Frequency (count)')
    title(str.Hz{HH})
    
end

tit = 'SSVEP Amp by Freq';
suptitle(tit);
saveas(h, [direct.results str.sub tit '.png'])

%% SSVEP Amps by COND
h = figure; 
colors2use = [
    1 0 0;
    0 0 1];

for CC = 1:2
    clear H
    for HH = 1:2
        subplot(1,2,HH); hold on;
        
        tmp = AMP_exp(HH,:, idx.trialsRTSEL{CC});
        tmp = tmp(:);
        tmp(isnan(tmp)) = [];
        
        a = hist(tmp, 30);
        histogram(tmp, 'FaceAlpha',0.5, 'FaceColor', colors2use(CC,:));

        xlim([0 6])
        
        xlabel('SSVEP Amp (µV)')
        ylabel('Frequency (count)')
        title(str.Hz{HH})
        legend(str.COND)
    end
    
end

tit = 'SSVEP Amp by Freq and Cond';
suptitle(tit);
saveas(h, [direct.results str.sub tit '.png'])


%% Z Scores by COND
h = figure; hold on;
colors2use = [
    1 0 0;
    0 0 1];

for CC = 1:2
        tmp = Z.Diff(:, idx.trialsRTSEL{CC});
        tmp = tmp(:);
        tmp(isnan(tmp)) = [];

        H(CC) = histogram(tmp, 20, 'FaceAlpha',0.5, 'FaceColor', colors2use(CC,:), 'Normalization', 'pdf');
        
        line([1 1].*mean(tmp) , get(gca, 'ylim'), 'color', colors2use(CC,:),'LineWidth',2)
        xlabel('Selectivity Score')
        ylabel('Frequency (count)')
        
end

line([0 0] , get(gca, 'ylim'), 'color', 'k','LineWidth',2)
legend(H, str.COND)

tit = 'Z Selectivity by Cond';
suptitle(tit);
saveas(h, [direct.results str.sub tit '.png'])

%% Calculate Selectivity using all available data

clear M SD

AMP_exp(AMP_exp==0) = NaN;

for HH = 1:2 % Get Mean and SD
    dat = AMP_exp(HH, :,1:n.trials);
    M(HH) = nanmean(dat(:));
    SD(HH) = nanstd(dat(:));
    
end


datE = (Z.Z(:,:,2:n.trials+1));
datE = squeeze(nanmean(datE,2));


for TT = 1:n.trials % Calculate the new Z Scores
    for HH = 1:2
        dat = AMP_exp(HH,:,TT+1);
        dat = nanmean(dat);
        Z2(HH,TT) = (dat - M(HH))/SD(HH);
    end
    
     switch TYPE2(TT) % make sure the correct difference is taken
            case 1 
                ZDiff2(TT) = Z2(1,TT) - Z2(2,TT);
                SELECT_TRIAL(TT) = datE(1,TT) - datE(2,TT);
            case 2
                ZDiff2(TT) = Z2(2,TT) - Z2(1,TT);
                SELECT_TRIAL(TT) = datE(2,TT) - datE(1,TT);
            case 3
                ZDiff2(TT) = Z2(1,TT) - Z2(2,TT);
                SELECT_TRIAL(TT) = datE(1,TT) - datE(2,TT);
            case 4
                ZDiff2(TT) = Z2(2,TT) - Z2(1,TT);
                SELECT_TRIAL(TT) = datE(2,TT) - datE(1,TT);
    end
end

% get the origional Z Diff over time
for TT = 2:n.trials+1
   tmp = Z.Diff(:,TT);
   tmp(tmp==0) = NaN;
   SELECT_TRIAL(TT-1) = nanmean(tmp);
end

%% plot selectivity over time. 

h = figure; hold on;
dat1 = smooth(SELECT_TRIAL,30);
plot(dat1);

dat2 = smooth(ZDiff2,30);
plot(dat2);

line(get(gca, 'xlim'), [0 0], 'color', 'k')

xlim([0 600])
xlabel('Trial in Experiment')
ylabel('Selectivity for trained colour')

legend({'Experimental Data' 'Grand Mean Data'})

tit = 'Selectivity over time';
title(tit)
saveas(h, [direct.results str.sub tit '.png'])

%% plot selectivity over time. - by COND

h = figure; hold on;
dat1 = smooth(ZDiff2(1:300),30);
plot(dat1);

dat2 = smooth(ZDiff2(301:600),30);
plot(dat2);
line(get(gca, 'xlim'), [0 0], 'color', 'k')

xlim([5 299])
xlabel('Trial in Experiment')
ylabel('Selectivity for trained colour')

legend({'Feat 1' 'Feat2'})

tit = 'Selectivity over time by cond';
title(tit)
saveas(h, [direct.results str.sub tit '.png'])

%% 
str.feat = {'FEATURE 1' 'FEATURE 2'};
for FF = 1:2
    switch FF
        case 1
            idx.COND = 1:300;
        case 2
            idx.COND = 301:600;
    end
    
    h = figure; hold on;
    
    dat2 = idx.COND;
    dat1 = ZDiff2(idx.COND);
    scatter(dat2,dat1, 'k')
    
    Fit = polyfit(dat2,dat1,1);
    plot(dat2, Fit(1)*dat2 + Fit(2), 'm')
    
    xlabel('Trial #')
    ylabel('Selectivity (Z)')
    
    [r, p] = corr(dat2', dat1');
    
    tit = ['r = ' num2str(r) ', p = ' num2str(p) ' ' str.feat{FF}];
    title(tit)
    
    tit = ['Selectivity over time Scatter ' str.feat{FF}];
     
    saveas(h, [direct.results str.sub tit '.png'])

end


%% Whole Trial FFT
%% Timing Settings

lim.s = [0.25 3];
lim.x = lim.s.*fs;

n.s = lim.s(2) - lim.s(1);
n.x = lim.x(2) - lim.x(1);

lim.x(1) = lim.x(1) + 1;

t = lim.s(1) : 1/fs : lim.s(2) - 1/fs;
f = 0 : 1/n.s : fs - 1/n.s;

%% Frequency Settings

Hz = [15 17];
%     Hz = [15 17]*2;

n.Hz = length(Hz);

for HH = 1:n.Hz
    str.COND{HH} = ['Attend ' num2str(Hz(HH)) 'Hz'];
    str.Hz{HH} = [num2str(Hz(HH)) 'Hz'];
    [~, idx.Hz(HH)] = min(abs(f-Hz(HH)));
end
  %% get trials
        
EPOCHs = NaN(n.x, n.chan, n.trials);
ampALL = NaN(n.x, n.chan, n.trials);

idx.trials = find(ismember(TYPE, trig.StartTrial));
            
idx.start = LATENCY(idx.trials) + lim.x(1);
idx.stop  = LATENCY(idx.trials) + lim.x(2);
            
for TT = 1:length(idx.start)

    tmp = EEG(idx.start(TT) : idx.stop(TT), :);
    tmp = detrend(tmp, 'linear');
    tmp = tmp - repmat(tmp(1,:), n.x, 1);
    
    tmp2 = abs( fft(tmp  ))/n.x;
    tmp2(2:end-1,:) = tmp2(2:end-1,:)*2;
    ampALL(:,:,TT) = tmp2;
    
end
            
figure; plot(f, mean(mean(ampALL(:,unique(BEST),:),2),3))

%% Get Best
BEST = NaN(n.Hz, n.best);
for HH = 1:n.Hz
    tmp = mean(ampALL(idx.Hz(HH), :, :),3);
    
    [j, i] = sort(tmp, 'descend');
    BEST(HH,:) = i(1:n.best);
    
    str.best{HH} = {chanlocs(BEST(HH,:)).labels};
    
end

%% Calculate Selectivity using all available data

clear M SD

for HH = 1:2 % Get Mean and SD
    dat = mean(ampALL(idx.Hz(HH), BEST(HH,:),1:n.trials),2);
    M(HH) = nanmean(dat(:));
    SD(HH) = nanstd(dat(:));
    
end


for TT = 1:n.trials % Calculate the new Z Scores
    for HH = 1:2
        dat = mean(ampALL(idx.Hz(HH), BEST(HH,:),TT),2);
        dat = nanmean(dat);
        Z3(HH,TT) = (dat - M(HH))/SD(HH);
    end
    
     switch TYPE2(TT) % make sure the correct difference is taken
            case 1 
                ZDiff3(TT) = Z3(1,TT) - Z3(2,TT);
            case 2
                ZDiff3(TT) = Z3(2,TT) - Z3(1,TT);
            case 3
                ZDiff3(TT) = Z3(1,TT) - Z3(2,TT);
            case 4
                ZDiff3(TT) = Z3(2,TT) - Z3(1,TT);
    end
end

%% plot selectivity over time. - by COND

h = figure; hold on;
dat1 = smooth(ZDiff3(1:300),30);
plot(dat1);

dat2 = smooth(ZDiff3(301:600),30);
plot(dat2);
line(get(gca, 'xlim'), [0 0], 'color', 'k')

xlim([5 299])
xlabel('Trial in Experiment')
ylabel('Selectivity for trained colour')

legend({'Feat 2' 'Feat 1'})

tit = 'Selectivity over time by cond';
title(tit)
saveas(h, [direct.results str.sub tit '.png'])

%% 
str.feat = {'FEATURE 1' 'FEATURE 2'};
for FF = 1:2
    switch FF
        case 1
            idx.COND = 1:300;
        case 2
            idx.COND = 301:600;
    end
    
    h = figure; hold on;
    
    dat2 = idx.COND;
    dat1 = ZDiff3(idx.COND);
    scatter(dat2,dat1, 'k')
    
    Fit = polyfit(dat2,dat1,1);
    plot(dat2, Fit(1)*dat2 + Fit(2), 'b')
    
    xlabel('Trial #')
    ylabel('Selectivity (Z)')
    ylim([-5 5])
    [r, p] = corr(dat2', dat1');
    
    tit = ['r = ' num2str(r) ', p = ' num2str(p) ' ' str.feat{FF}];
    title(tit)
    
    tit = ['Selectivity over time Scatter Exp Data' str.feat{FF}];
     
    saveas(h, [direct.results str.sub tit '.png'])

end
