%% Directories

SUB = 4;

direct.functions = 'Functions\'; 
addpath(direct.functions);

SetupDirectories

%% Settings

options.practice = 1; options.DisplayStream = 1;
SetupSettings


%% Changes to standard settings for staircase
s.dotsmove = 2;
f.dotsmove = s.dotsmove*mon.ref;

options.staircase = 1;

%% Setup Triggers

SetupTriggers

%% Response criteria

responseCriteria = 33.75;

%% DATA

SetupDATA

%% Setup Dots

SetupDots

%% setup Psychtoolbox

SetupGraphics

%%  Initialise Variables

SetupLoopVariables

%% set up sc parameters

sc.maxtrials = 20;  % the maximum number of trials
sc.maxreversals = inf; % the maximum number of reversals
sc.ignorereversals = 3; % number of reversals to ignore

sc.minstimval = 1; % minimum stimulus value
sc.maxstimval = 120; % maximum stimulus value
sc.maxboundaries = 3; % number of times sc can hit boundary

sc.steptype = 'fixed'; % other option is 'random'
sc.fixedstepsizes = [20 8 3 1]; % specifies the stepsize vector

sc.up = 1; % # of incorrect answers to go one step up
sc.down = 1;  % # of correct answers to go one step down

%% set up the staircases

sc.stairs(1).initial = 120; % The individual staircases are set up in an embedded structure called sc.stairs, and each one has an index
sc.stairs(2).initial = 80; % second staircase
sc.stairs(3).initial = 40;
sc.stairs(4).initial = 1;

%% initialises the staircases

sc.trial = 0; % global trialcounter
sc.num = 4; % get the number of staircases we want to initialise
sc.active = 1:sc.num; % create a vector with the active staircases
sc.done = 0; % we're not done, we're only just starting!


%% cycle through the staircases to initialise them

for N = 1:sc.num

    % set up some values for all staircases
    sc.stairs(N).trial = 0;             % staircase specific trial number
    sc.stairs(N).data = [];             % contains raw data
    sc.stairs(N).index = n;             % index of the staircase
    sc.stairs(N).wrong = 0;             % number of correct answers
    sc.stairs(N).right = 0;             % number of incorrect answers
    sc.stairs(N).direction = 0;         % the direction of the staircase
    sc.stairs(N).reversal = [];         % contains reversal data
    sc.stairs(N).maxboundaries = 3;     % maximum it can hit the boundaries
    sc.stairs(N).hitboundaries = 0;     % counter for how often it hit the boundaries
    
    % Set some staircase specific variables:  
    
    % set the up/down separately for each staircase if it was specified
    if ~isfield(sc.stairs(N), 'up') || isempty(sc.stairs(N).up), sc.stairs(N).up = sc.up;end
    if ~isfield(sc.stairs(N), 'down') || isempty(sc.stairs(N).down), sc.stairs(N).down = sc.down; end

    % set the steptype separately for each staircase if specified
    if ~isfield(sc.stairs(N), 'steptype') || isempty(sc.stairs(N).steptype), sc.stairs(N).steptype = sc.steptype; end

    % set the condition separately for each staircase if specified
    if ~isfield(sc.stairs(N), 'condition') || isempty(sc.stairs(N).condition), sc.stairs(N).condition = 1; end

    % set the minimum and maximum stimvals and the number of times a staircase is allowed to reach that boundary before terminating
    if ~isfield(sc.stairs(N), 'maxboundaries') || isempty(sc.stairs(N).maxboundaries), sc.stairs(N).maxboundaries = sc.maxboundaries; end
    if ~isfield(sc.stairs(N), 'minstimval') || isempty(sc.stairs(N).minstimval), sc.stairs(N).minstimval = sc.minstimval; end
    if ~isfield(sc.stairs(N), 'maxstimval') || isempty(sc.stairs(N).maxstimval), sc.stairs(N).maxstimval = sc.maxstimval; end

    sc.stairs(N).stimval = sc.stairs(N).initial; % set the initial stimulus value

end


%% run the experiment

while ~sc.done
    
    % gets the next trial; some of the trial parameters are stored in a
    % 'trial' struct, like the stimulus value (trial.stimval) and the 
    % trial number (trial.number)
    % selects a random staircase and gets new trial parameters

    sc.current = sc.active(ceil(numel(sc.active) * rand(1,1))); % select a random staircase from the active staircases - returns index of % sc rather than the index used in the active staircase vector
    sc.stairs(sc.current).trial = sc.stairs(sc.current).trial + 1; % increment the trial counter for the current staircase

    sc.trial = sc.trial + 1; % increment the total trial count
    disp(sc.trial)
    
    stimval = sc.stairs(sc.current).stimval; % get the current stimval
    direction = sc.stairs(sc.current).direction; % get the direction to decide if we're going to add or substract
    numreversals = size(sc.stairs(sc.current).reversal,1); % calculate the number of reversals

    if sc.stairs(sc.current).trial > 1 % if we're on the first trial, just use the initial values
        switch lower(sc.stairs(sc.current).steptype)
            case 'fixed'
                if numreversals < numel(sc.fixedstepsizes) % we're not on the last item in the stepsize vector

                    % the index in the stepsize vector is equal to the number
                    % of reversals we have encountered so far (+1 for zero index)
                    stepindex = numreversals + 1;
                else
                    stepindex = numel(sc.fixedstepsizes); % we're at the last element in the stepsize vector
                end
                
                stepsize = sc.fixedstepsizes(stepindex); % extract the stepsize
                stimval = stimval + (direction * stepsize); % calculate the new stimval

            case 'random' % choose a random stepsize
                stepindex = ceil(numel(sc.fixedstepsizes)*rand(1,1)); % stepindex = randi(numel(sc.fixedstepsizes),1);
                stepsize = sc.fixedstepsizes(stepindex); % extract the stepsize
                stimval = stimval + (direction * stepsize); % calculate the new stimval
        end

        % checks if the stimulus value is out of bounds
        if (stimval < sc.stairs(sc.current).minstimval) % stimval is smaller than the minumum stimval
            
            stimval = sc.stairs(sc.current).minstimval; % set the stimval to the min stimval
            sc.stairs(sc.current).hitboundaries = sc.stairs(sc.current).hitboundaries + 1; % increase the boundary hit counter
            
        elseif (stimval > sc.stairs(sc.current).maxstimval) % stimval is larger than the maximum stimval;
            
            stimval = sc.stairs(sc.current).maxstimval; % set the stimval to the max stimval
            sc.stairs(sc.current).hitboundaries = sc.stairs(sc.current).hitboundaries + 1; % increase the boundary hit counter
        
        end

    end

    sc.stairs(sc.current).stimval = stimval; % set it back to the new (or old) value
    trial.stimval = sc.stairs(sc.current).stimval; % set the values in the trial struct
    trial.number = sc.stairs(sc.current).trial;
    
    %% Play Dots
    
    TRIAL = sc.trial;
    if TRIAL>size(DATA,1)
        TRIAL = TRIAL - size(DATA,1);
    end
    responseWait = 0;
    FRAME_ALL = 0;
    
    
    % send Trigger
    CTRAIN = DATA(TRIAL, [D.TrainedFeature D.UnTrainedFeature]); 
    FTRAIN = DATA(TRIAL, [D.idxHz_Trained D.idxHz_UnTrained]); 
    SendTrig(trig, trig.StartTrial(FTRAIN(1),CTRAIN(1)), options)
%     SendTrig(trig, trig.StartTrial(FTRAIN(1)), options)
    
    % - Play dots
    PlayDots
    
    GatherResponse
    
    PresentFeedback
    
    % evaluate response
    response = abs(wrapTo360(RESPONSE(TRIAL)) - wrapTo360(Correct_RESPONSE(TRIAL)));
   
    trial.resp = response > responseCriteria;
    disp([ response trial.resp]);
    
    %% evaluates the response

    sc.stairs(sc.current).direction = 0; % set the direction to 'no change' as a default

    switch trial.resp
        case 0 % incorrect answer
            sc.stairs(sc.current).wrong = sc.stairs(sc.current).wrong + 1; % increase the number of correct answers index

            if sc.stairs(sc.current).up == 1 || mod(sc.stairs(sc.current).wrong, ...
                    sc.stairs(sc.current).up) == 0
                if sc.stairs(sc.current).right >= sc.stairs(sc.current).down % we've got a reversal so save it! 
                    data = [ sc.stairs(sc.current).trial sc.stairs(sc.current).stimval ];
                    sc.stairs(sc.current).reversal = [ sc.stairs(sc.current).reversal; data ]; % save it to the reversal matrix
                end

                sc.stairs(sc.current).right = 0;  % reset the counter
                sc.stairs(sc.current).direction = 1; % set the step direction to up
            end
        case 1 % correct answer
            sc.stairs(sc.current).right = sc.stairs(sc.current).right + 1; % increase the number of correct answers index

            if sc.stairs(sc.current).down == 1 || mod(sc.stairs(sc.current).right, sc.stairs(sc.current).down) == 0,
                if sc.stairs(sc.current).wrong >= sc.stairs(sc.current).up % we've got a reversal so save it!
                    data = [ sc.stairs(sc.current).trial sc.stairs(sc.current).stimval ];
                    sc.stairs(sc.current).reversal = [ sc.stairs(sc.current).reversal; data ]; % save it to the reversal matrix
                end

                sc.stairs(sc.current).wrong = 0; % reset the counter
                sc.stairs(sc.current).direction = -1; % set the step direction to down

            end
    end


    %% updates the staircase with new data

    newdata = [trial.number trial.stimval trial.resp]; % create a new line for the data saving process
    sc.stairs(sc.current).data = [sc.stairs(sc.current).data; newdata]; % save the data from this trial to the struct

    % check if we have reached the limit for this staircase based on the number
    % of trials and reversals or when it has hit the maximum about of boundary 
    % hits-- if we have, remove that staircase from list
    terminate = sc.stairs(sc.current).trial >= sc.maxtrials || ...
                size(sc.stairs(sc.current).reversal,1) >= sc.maxreversals || ...
                sc.stairs(sc.current).hitboundaries >= sc.maxboundaries;

    % if this is indeed the end, remove it
    if terminate 
        % a little function that removes an active staircase from the active
        % staircase vector once we're done. Just added to keep me sane.

        index = sc.stairs(sc.current).index; % get the current index
        sc.active(sc.active == sc.current ) = []; % delete that one from the list
    end

   
    sc.done = ~numel(sc.active);  % a simple check to check if we should quit - no more active staircases

end

%% Cleanup
Priority(0);
Screen('CloseAll');

% Trigger Staircase and stop recording
SendTrig(trig, trig.staircase, options);
pause(0.5);
io64(trig.ioObj, trig.address(1), trig.stopRecording);
clear s t
%% display stats

fprintf('\n');
fprintf('%s:\n\n', 'SUMMARY DATA');
fprintf('%s\t\t%s\t\t%s\t\t%s\t\t%s\t\t%s\n', 'ID', 'Thresh.', 'Std.', 'Trials', 'Cond.', 'Steptype')

for N = 1:sc.num % get the last portion of the reverals for all staircases, ignoring the first # reversals (specified in the config) 
    
    if isempty( sc.stairs(N).reversal ) % when there are no reversals... (it's possible)
%         t(N) = sc.stairs(N).stimval; % just use the last stimval (is there a better method for this?)
%         s(N) = 0; % SD is kinda stupid here, isn't it?
        
        % I don't trust this = just going to exclude the offending
        % staircase (AIR - Apr '18)
        t(N) = NaN; % just use the last stimval (is there a better method for this?)
        s(N) = NaN; % SD is kinda stupid here, isn't it?
        
    else
        if ~sc.ignorereversals
            rev = sc.stairs(N).reversal(sc.ignorereversals:end,2); % you may also not want to ignore any reversals
        else
            rev = sc.stairs(N).reversal(sc.ignorereversals:end,2); % get the last portion of the reversals, ignoring a certain number
        end

        t(N) = mean(rev); % get the threshold (t) and the standard deviation (s)
        s(N) = std(rev);

    end

    % save them in the structure
    sc.stairs(N).threshold = t(N);
    sc.stairs(N).std = s(N);

    % output the data
    fprintf('%-2.f\t\t%-6.2f\t\t%-6.2f\t\t%-6.0f\t\t%-2.0f\t\t\t%s\n', ...
    N, sc.stairs(N).threshold, ...
    sc.stairs(N).std, sc.stairs(N).trial, ...
    sc.stairs(N).condition, sc.stairs(N).steptype);

end

% save the final threshold and standard deviation
sc.threshold = nanmean(t); sc.std = nanmean(s);

%fprintf('%s\n', '------------------------------------------------------');
fprintf('%s\t\t%-6.2f\t\t%-6.2f\t\t%-6.0f\n', 'M', sc.threshold, sc.std, sc.trial)
fprintf('\n');

disp('Threshold = ') 
disp(t)


%% visualise the staircase

thresholds = []; % YES! it's a growing vector, I know that. 
fig = figure('color', 'w'); % initialise a new figure with a white background

hold on; box on; set(gca, 'FontSize', 12);
ylim([0 sc.maxstimval]); % just using the values used in the simulation

% loop through all staircases
idx.scPLOT = find(~isnan(t));
for i=idx.scPLOT
    
    p(1) = plot(sc.stairs(i).data(:,1), sc.stairs(i).data(:,2), '-ko', 'MarkerSize', 3, 'MarkerFaceColor', 'r'); % plot the normal values in blue
    f = sc.stairs(i).data(:,3) == 0; % plot the "Correct" values in green
    p(2) = plot(sc.stairs(i).data(f,1), sc.stairs(i).data(f,2), 'go', 'MarkerSize', 3, 'MarkerFaceColor', 'g');
    p(3) = gridxy(sc.stairs(i).reversal(:,1), [], 'LineStyle', ':', 'Color', [0.8 0.8 0.8]); % plot the reversals
    thresholds = [ thresholds; sc.stairs(i).threshold ]; % gather the individual thresholds
    
end

observer.stop_time = clock;
observer.name = str.sub;
% draw the final threshold and individual thresholds
p(4) = gridxy([], sc.threshold, 'color', 'r', 'linewidth', 1.5);
p(5) = gridxy([], thresholds, 'color', 'r', 'LineStyle', ':');

% labels and title
xlabel('Trial number', 'fontsize', 12);
ylabel('SD', 'fontsize', 12);
legend([p(1) p(2) p(3) p(4) p(5)], 'InCorrect answer', 'Correct answer', 'Reversal', 'Mean threshold', 'Individual threshold', 'Location', 'SouthEast');

tit = [ observer.name ' ' date ' ' num2str( observer.stop_time(4) ) '-' num2str( observer.stop_time(5) ) '-' num2str( round( observer.stop_time(6) ) ) ];

tit = [ tit [ ', SD = ' num2str( round( nanmean( t ) ) ) ] ];

        
title(tit)

saveas(fig, [direct.data tit '.png' ], 'png')
saveas(fig, [direct.data tit  '.fig' ], 'fig')

THRESHOLD_mean = round( nanmean( t ) );
THRESHOLD_min = round(min( t ) );

%% save and close

save( [ direct.data 'SD_THRESHOLD.mat' ], 'THRESHOLD_mean', 'THRESHOLD_min'  );
save( [ direct.data tit '.mat' ] );
disp('results saved!!!')
