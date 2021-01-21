
for Feature = 1:2
    switch Feature
        case 1
            idx.FeatTrials = zeros(600,1);
            idx.FeatTrials(1:300) = 1;
            str.Feat = 'Feat 1';
        case 2
            idx.FeatTrials = zeros(600,1);
            idx.FeatTrials(301:600) = 1;
            str.Feat = 'Feat 2';
%         case 3
%             idx.FeatTrials = 
    end
    for CatchTrials = 0:1
        %% Load data
%         load([direct.data 'S' num2str(SUB) 'DisplayStream.mat'], 'DATA', 'D', 'CTRAIN','Correct_RESPONSE', 'RESPONSE', 'RESPONSE_TIME', 'TRIAL', 'DirectFields', 'directions', 'SELECTIVITY_Structured', 'SDUSE');
%         n.trials = TRIAL;
        
        %% CATCH TRIALS!
        switch CatchTrials
            case 0
                str.catchTrial = ''; % For Saving
                
                idx.trialsUse = ~DATA(:,D.CatchTrial);
                idx.trialsUse(~idx.FeatTrials) = 0;
                idx.trialsUse(n.trials+1:end) = 0;
                n.trialsUse = sum(idx.trialsUse);
                
                TrialAverager = 20;
                
            case 1
                str.catchTrial = ' No NF'; % For Saving
                
                idx.trialsUse = ~~DATA(:,D.CatchTrial);
                idx.trialsUse(~idx.FeatTrials) = 0;
                idx.trialsUse(n.trials+1:end) = 0;
                n.trialsUse = sum(idx.trialsUse);
                
                TrialAverager = 5;
        end
        
        %% Shorten Responses
        
        RESPONSE = RESPONSE(1:n.trials);
        Correct_RESPONSE = Correct_RESPONSE(1:n.trials);
        
        if any(isnan(RESPONSE))
            warning('NaNs in Response!?')
        end
        %% Response Error
        
        response_plot = wrapTo360(RESPONSE);
        Correct_RESPONSE_plot =  wrapTo360(Correct_RESPONSE);
        
        Direction_shift = NaN(n.trials,1);
        ResponseError = NaN(n.trials,1);
        for TT = 1:n.trials
            %  Direction_shift(TT) = sign(directions(DirectFields(TT,1)) - directions(DirectFields(TT,2))); % switch direction to allign trained and untrained directions
            
            % switch direction to allign trained and untrained directions
            FTRAIN = DATA(TT, [D.idxHz_Trained D.idxHz_UnTrained]); % trained and untrained frequencies - freqs aligned with fields in Pilots 1 to 4!
            dir1 = directions(DirectFields(TT,FTRAIN(1)));
            dir2 = directions(DirectFields(TT,FTRAIN(2)));
            Direction_shift(TT) = sign( dir1 - dir2);
            
            ResponseError(TT) = Direction_shift(TT)*(response_plot(TT)-Correct_RESPONSE_plot(TT));
        end
        
        ResponseErrorUse = ResponseError(idx.trialsUse);
        
        %% Histogram of Responses
        
        bins = -360:20:360;
        h = figure;
        hist(ResponseErrorUse,bins)
        xlim([-360 360])
        
        xlabel('Response Bias (+ve = trained)')
        ylabel('Frequency (count)')
        
        tit = ['All trials Response Error Histogram ' str.catchTrial ' ' str.Feat];
        title(tit)
        saveas(h, [direct.results str.sub tit '.png'])
        
        %% PolarHistogram of Responses
        
        bins = ((-5:10:355)/360)*2*pi;
        h = figure;
        
        tmp = (ResponseErrorUse/360).*2*pi;
        
        polarhistogram(tmp, bins, 'FaceColor','b','FaceAlpha',0.8, 'Normalization', 'count')
        
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir','clockwise' )
        set(gca, 'rticklabels', [], 'ThetaLim', [-180 180])
        
        tit = ['All trials Response Error Polar Histogram ' str.catchTrial ' ' str.Feat];
        title(tit)
        saveas(h, [direct.results str.sub tit '.png'])
        
        %% Selectivity sorting
        SELECTIVITY2 = SELECTIVITY_Structured(:,idx.trialsUse);
        SELECTIVITY2(SELECTIVITY2==0) = NaN;
        
        % selectivity- mean by trial
        SELECTIVITY_Mean = nanmean(SELECTIVITY2,1);
        SELECTIVITY_Mean2 = SELECTIVITY_Mean;
        % get error trials
        % idx.error = ResponseErrorUse > 100 | ResponseErrorUse < -100;
        idx.error = ResponseErrorUse > 67.5 | ResponseErrorUse < -67.5;
        %     idx.error = ResponseErrorUse > 45 | ResponseErrorUse < -45;
        SELECTIVITY_Mean2(idx.error) = NaN;
        ResponseErrorUse2 = ResponseErrorUse;
        ResponseErrorUse2(idx.error) = NaN;
        
        % selectivity sorted
        [SELECTIVITY_Sorted, idx.sortedSelect] = sort(SELECTIVITY_Mean2);
        ResponseError_Sorted = ResponseErrorUse2(idx.sortedSelect);
        
        
        %% Errors
        
        [tmp_select, tmp_idx] = sort(SELECTIVITY_Mean);
        Error_Plot = smooth(tmp_select, idx.error(tmp_idx), TrialAverager);
        h = figure;
        plot(tmp_select, Error_Plot, 'r-x')
        ylim([0 1])
        
        line([0 0], get(gca, 'ylim'), 'color', 'k')
        line(get(gca, 'xlim'), [0.5 0.5], 'color', 'k')
        xlabel('Selectivity (Z score Difference)')
        ylabel('Errors - 0 correct, 1 incorrect')
        
        
        tit=['Error Trials by Selectivity ' str.catchTrial ' ' str.Feat] ;
        title(tit)
        saveas(h, [direct.results str.sub tit '.png'])
        
        %% Response Bias over time
        
        dat1 = ResponseErrorUse2;
        dat1 = smooth(dat1,TrialAverager);
        
        h = figure;
        plot(1:length(dat1), dat1)
        line(get(gca, 'xlim'), [0 0], 'color', 'k')
        
        xlabel('Trial Number')
        ylabel('Bias/ Selectivity')
        
        tit = ['Bias and Selectivity over time ' str.catchTrial ' ' str.Feat];
        title(tit)
        saveas(h, [direct.results str.sub tit '.png'])
        
        
        %% Response Error by Feedback
        SDUSE2 = NaN(n.trialsUse,1);
        dat = SDUSE(1:end-1,idx.trialsUse);
        for TT = 1:n.trialsUse
            tmp = find([0; diff(dat(:,TT))]~=0);
            tmp = tmp(1);
            SDUSE2(TT) = nanmean(dat(tmp(1):end,TT));
        end
        
        h = figure; hold on
        dat1 = abs(ResponseErrorUse2 );
        dat2 = SDUSE2;
        dat2(isnan(dat1)) = [];
        dat1(isnan(dat1)) = [];
        
        scatter(dat2, dat1, 'm');
        
        Fit = polyfit(dat2,dat1,1);
        plot(dat2, Fit(1)*dat2 + Fit(2), 'b')
        
        xlabel('Feedback (SD)')
        ylabel('Response Error (°)')
        
        [r, p] = corr(dat2, dat1);
        
        tit = ['r = ' num2str(r) ', p = ' num2str(p) ' ' str.catchTrial ' ' str.Feat];
        title(tit)
        saveas(h, [direct.results str.sub 'Response Error by coherence Scatter ' str.catchTrial  ' ' str.Feat '.png'])
        
        
        %% Scatter Response Bias Selectivity
        h = figure; hold on
        dat1 = ResponseErrorUse2;
        dat2 = SELECTIVITY_Mean;
        dat2(isnan(dat1)) = [];
        dat1(isnan(dat1)) = [];
        
        scatter(dat2, dat1, 'b');
        
        Fit = polyfit(dat2',dat1,1);
        plot(dat2, Fit(1)*dat2 + Fit(2))
        
        xlabel('Selectivity (Z score Difference)')
        ylabel('Response Bias towards selected freq (°)')
        
        [r, p] = corr(dat2', dat1);
        
        tit = ['r = ' num2str(r) ', p = ' num2str(p) ' ' str.catchTrial  ' ' str.Feat];
        title(tit)
        saveas(h, [direct.results str.sub 'Scatter ' str.catchTrial  ' ' str.Feat '.png'])
        
        
        %% Scatter error
        h = figure; hold on
        dat1 = abs(ResponseErrorUse2);
        dat2 = SELECTIVITY_Mean;
        dat2(isnan(dat1)) = [];
        dat1(isnan(dat1)) = [];
        
        scatter(dat2, dat1, 'g');
        
        Fit = polyfit(dat2',dat1,1);
        plot(dat2, Fit(1)*dat2 + Fit(2))
        
        xlabel('Selectivity (Z score Difference)')
        ylabel('Response Error (°)')
        
        [r, p] = corr(dat2', dat1);
        
        tit = ['r = ' num2str(r) ', p = ' num2str(p) ' ' str.catchTrial  ' ' str.Feat];
        title(tit)
        saveas(h, [direct.results str.sub 'Scatter ERROR ' str.catchTrial  ' ' str.Feat '.png'])
        
        %% indeces for percentile splits
        % top and bottom 50% selectivity
        cutoff = prctile(SELECTIVITY_Mean,80);
        idx.larger = SELECTIVITY_Mean>cutoff;
        cutoff = prctile(SELECTIVITY_Mean,20);
        idx.smaller = SELECTIVITY_Mean<cutoff;
        
        % positive and negative selectivity
        idx.Pos = SELECTIVITY_Mean>0; sum(idx.Pos);
        idx.Neg = SELECTIVITY_Mean<0; sum(idx.Neg);
        
        %% PolarHistogram of Responses - selectivity split
        
        bins = ((-5:10:355)/360)*2*pi;
        h = figure;
        
        subplot(1,2,1)
        tmp = (ResponseErrorUse2(idx.smaller)/360).*2*pi;
        polarhistogram(tmp, bins, 'FaceColor','b','FaceAlpha',0.8, 'Normalization', 'count')
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir','clockwise' )
        set(gca, 'rticklabels', [], 'ThetaLim', [-180 180])
        title('Selectivity < 20th prctile')
        
        subplot(1,2,2)
        tmp = (ResponseErrorUse2(idx.larger)/360).*2*pi;
        polarhistogram(tmp, bins, 'FaceColor','b','FaceAlpha',0.8, 'Normalization', 'count')
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir','clockwise' )
        set(gca, 'rticklabels', [], 'ThetaLim', [-180 180])
        title('Selectivity > 80th prctile')
        
        
        tit = ['Response Error by Selectivity Prctile Polar Hist ' str.catchTrial  ' ' str.Feat];
        suptitle(tit)
        saveas(h, [direct.results str.sub tit '.png'])
        
        %% PolarHistogram of Responses - selectivity split - pos neg
        
        bins = ((-5:10:355)/360)*2*pi;
        h = figure;
        
        subplot(1,2,1)
        tmp = (ResponseErrorUse2(idx.Neg)/360).*2*pi;
        polarhistogram(tmp, bins, 'FaceColor','b','FaceAlpha',0.8, 'Normalization', 'count')
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir','clockwise' )
        set(gca, 'rticklabels', [], 'ThetaLim', [-180 180])
        title('Selectivity -ve')
        
        subplot(1,2,2)
        tmp = (ResponseErrorUse2(idx.Pos)/360).*2*pi;
        polarhistogram(tmp, bins, 'FaceColor','b','FaceAlpha',0.8, 'Normalization', 'count')
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir','clockwise' )
        set(gca, 'rticklabels', [], 'ThetaLim', [-180 180])
        title('Selectivity +ve')
        
        tit = ['Response Error by Selectivity value Polar Hist ' str.catchTrial  ' ' str.Feat];
        suptitle(tit)
        saveas(h, [direct.results str.sub tit '.png'])
        
    end
end