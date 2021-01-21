%% rotate Screen
if options.rotate
    Screen('glPushMatrix', windowPtr)
    Screen('glTranslate', windowPtr, mon.centre(1), mon.centre(2))
    Screen('glRotate', windowPtr, RotationAng, 0, 0);
    Screen('glTranslate', windowPtr, -mon.centre(1), -mon.centre(2))
end

%%

disp([str.cond{CTRAIN(1)} ' ' num2str(Hz(DATA(TRIAL, D.idxHz_Trained)))])
disp(['CatchTrial: ' num2str(DATA(TRIAL,D.CatchTrial))])
for FRAME = 1:f.dotsmove-1
    %% Update frame count
    FRAME_ALL = FRAME_ALL + 1;
    
    %% Sort out Buffer things
    if ~options.practice
        nSamples = readBufferSamples( cfg.stream ); % how much data is available?
        if (nSamples) > idx.samplesRead % update if new information available
            % Update buffer read count
            BufferReadCount(TRIAL) = BufferReadCount(TRIAL)+ 1;
            
            % read data
            latencyRead = idx.samplesRead    :   nSamples-1; % latency of this chunk
            selectivity = readBufferData( [latencyRead(1) latencyRead(end)], cfg.stream );
            
            if any(isnan(selectivity))
                selectivity(isnan(selectivity)) = 0;
            end
            
            % update next datapoint to read first.
            idx.samplesRead = nSamples;
            
            % add data to collection
            SELECTIVITY = [SELECTIVITY; selectivity];
            SELECTIVITY_Metadata = [SELECTIVITY_Metadata; TRIAL FRAME];
            
            % update read timing vector
            readTiming = [readTiming; toc(ReadTimer)];
            
        end
        
        SELECTIVITY_Structured(FRAME, TRIAL) = nanmean(selectivity);
        
    end
    %% Draw
    
    % draw.colvect ->[TRAINED dots, UNTRAINED dots.].
    
    switch dotType
        case 1
            
            for RGB = 1:3
                switch FTRAIN(1) % keep trained and untrained flicker freqs together while maintaining dot order. In CTRAIN and FTRAIN 1 = trained, 2 = untrained
                    case 1 % order is always [slower dots faster dots] - switch around colours.
                        draw.colvect(RGB,:) = [colvect(RGB,:, FTRAIN(1)).*dots.cols(CTRAIN(1),RGB)' colvect(RGB,:,FTRAIN(2)).*dots.cols(CTRAIN(2),RGB)'];
                        
                    case 2
                        draw.colvect(RGB,:) = [colvect(RGB,:, FTRAIN(2)).*dots.cols(CTRAIN(2),RGB)' colvect(RGB,:,FTRAIN(1)).*dots.cols(CTRAIN(1),RGB)'];
                end
            end
            
            % moving dots
            draw.dotsxy = [DOT_XY(:,:,freq.A) DOT_XY(:,:,freq.B)]; % draw moving dots
            Screen('DrawDots', windowPtr, draw.dotsxy(:,dots.order(TRIAL,:)), dots.width, draw.colvect(:,dots.order(TRIAL,:)), mon.centre,1);  % change 1 to 0 to draw square dots
            
            % fixation
            Screen('FillRect', windowPtr, [colour.white colour.white], dots.fixation )
            
        case 2
            
            switch FTRAIN(1) % keep trained and untrained flicker freqs together while maintaining dot order. In CTRAIN and FTRAIN 1 = trained, 2 = untrained
                case freq.A
                    rectCoord = [
                        (rect_train{CTRAIN(1)}(1) + DOT_XY(coord.x,:,freq.A) ),   (rect_train{CTRAIN(2)}(1) + DOT_XY(coord.x,:,freq.B) );
                        (rect_train{CTRAIN(1)}(2) + DOT_XY(coord.y,:,freq.A) ),   (rect_train{CTRAIN(2)}(2) + DOT_XY(coord.y,:,freq.B) );
                        (rect_train{CTRAIN(1)}(3) + DOT_XY(coord.x,:,freq.A) ),   (rect_train{CTRAIN(2)}(3) + DOT_XY(coord.x,:,freq.B) );
                        (rect_train{CTRAIN(1)}(4) + DOT_XY(coord.y,:,freq.A) ),   (rect_train{CTRAIN(2)}(4) + DOT_XY(coord.y,:,freq.B) )];
                case freq.B
                    rectCoord = [
                        (rect_train{CTRAIN(2)}(1) + DOT_XY(coord.x,:,freq.A) ),   (rect_train{CTRAIN(1)}(1) + DOT_XY(coord.x,:,freq.B) );
                        (rect_train{CTRAIN(2)}(2) + DOT_XY(coord.y,:,freq.A) ),   (rect_train{CTRAIN(1)}(2) + DOT_XY(coord.y,:,freq.B) );
                        (rect_train{CTRAIN(2)}(3) + DOT_XY(coord.x,:,freq.A) ),   (rect_train{CTRAIN(1)}(3) + DOT_XY(coord.x,:,freq.B) );
                        (rect_train{CTRAIN(2)}(4) + DOT_XY(coord.y,:,freq.A) ),   (rect_train{CTRAIN(1)}(4) + DOT_XY(coord.y,:,freq.B) )];
            end
            
            draw.colvect = [colvect(:,:,freq.A) colvect(:,:,freq.B)];
            Screen('FillRect', windowPtr, draw.colvect(:,dots.order(TRIAL,:)),  rectCoord(:,dots.order(TRIAL,:))  )
            
            % fixation
            Screen('FillRect', windowPtr, [colour.red colour.red], dots.fixation )
            
    end
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('DrawingFinished', windowPtr);
    
    %% - Transform Selectivity Score
    
    if ~options.practice
        ScoreUse = SELECTIVITY_Structured(FRAME, TRIAL);
    elseif options.practice
        ScoreUse = 2.5;
    end
    
    ScoreUse = -ScoreUse; %invert sign - more selectivity = lower SD.
    
    sc.scaled = (ScoreUse/sc.oldRange)*sc.newRange;
    sc.scaled = sc.newRange + sc.scaled;
    
    if sc.scaled < 0; sc.scaled = 0;  end % SD shouldn't be less than 0 (impossible)
    
    if DATA(TRIAL,D.CatchTrial) == 1 && FRAME > mon.ref % edit out feedback in catchtrials
        dots.SD = sc.CatchTrialSD;
    elseif isnan(sc.scaled) % Incase there's ever a NaN in the Selectivity Z scores (this fucks up your matlab run, but wouldn't a big deal otherwise)
        dots.SD = sc.newRange;
        disp('Nan in Feedback!')
    else %SD is as caluclated
        dots.SD = sc.scaled;
    end
    
    if FRAME <= mon.ref
        dots.SD = 120; % threshold at which there is no information available!
    end
    
    if options.staircase %If this is the staircase, SD should be the staircase position
        dots.SD = stimval;
    end
    
    
    
    SDUSE(FRAME, TRIAL) = dots.SD;
    
    %% Update Colors && Move Dots
    FRAME_use = FRAME +1;
    
    % update luminance
    for HH = 1:n.Hz
        scaler = (dots.max_d - sqrt( DOT_XY(1,:,HH).^2 + DOT_XY(2,:,HH).^2));
        scaler = 2*scaler/dots.max_d;
        scaler(scaler > 1) = 1;
        
        colvect(:,:,HH) = repmat(FLICKER(FRAME_use,:,HH).*scaler,3,1);
    end
    
    % update dot position
    for FIELD = 1:2
        if options.rotate
            Duse = DirectionsRot;
        else
            Duse = directions;
        end
        DOT_XY(:,:,FIELD) = updateDotCoords2(DOT_XY(:,:,FIELD), dots, DirectFields,Duse, TRIAL, FIELD);
    end
    
    %% FLIP!
    
    flipper
    if breaker; break; end
    
end

%% Display Trial Selectivity 
if ~options.staircase
    disp(['Mean Selectivity over ' num2str(BufferReadCount(TRIAL) ) ' reads:']);
    disp([nanmean(SELECTIVITY_Structured(:, TRIAL))]);
end

%% Send stop trial

SendTrig(trig, trig.stopTrial, options)

%% rotate Screen back!

if options.rotate
    Screen('glPopMatrix', windowPtr)
end