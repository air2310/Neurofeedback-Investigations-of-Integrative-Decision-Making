%% rotate Screen
if options.rotate
    Screen('glPushMatrix', windowPtr)
    Screen('glTranslate', windowPtr, mon.centre(1), mon.centre(2))
    Screen('glRotate', windowPtr, RotationAng, 0, 0);
    Screen('glTranslate', windowPtr, -mon.centre(1), -mon.centre(2))
end

%%
disp([str.cond{CTRAIN(1)} ' ' num2str(Hz(DATA(TRIAL, D.idxHz_Trained)))])
for FRAME = 1:f.dotsmove-1
    %% Update frame count
    FRAME_ALL = FRAME_ALL + 1;
   
    %% Draw
    
    % draw.colvect ->[TRAINED dots, UNTRAINED dots.].
    
    rectCoord = [
        (rect_train{CTRAIN(1)}(1) + DOT_XY(coord.x,:,FTRAIN(1)) );
        (rect_train{CTRAIN(1)}(2) + DOT_XY(coord.y,:,FTRAIN(1)) );
        (rect_train{CTRAIN(1)}(3) + DOT_XY(coord.x,:,FTRAIN(1)) );
        (rect_train{CTRAIN(1)}(4) + DOT_XY(coord.y,:,FTRAIN(1)) )];

     draw.colvect = colvect(:,:,FTRAIN(1));
     Screen('FillRect', windowPtr, draw.colvect,  rectCoord  )
   
    
    % fixation
    Screen('FillRect', windowPtr, [colour.red colour.red], dots.fixation )
    

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
    
%     if DATA(TRIAL,D.CatchTrial) == 1 && FRAME > mon.ref % edit out feedback in catchtrials
%         dots.SD = sc.CatchTrialSD;
   if isnan(sc.scaled) % Incase there's ever a NaN in the Selectivity Z scores (this fucks up your matlab run, but wouldn't a big deal otherwise)
        dots.SD = sc.newRange;
    else %SD is as caluclated
        dots.SD = sc.scaled;
    end
    
    if FRAME <= mon.ref
        dots.SD = 110; % threshold at which there is no information available!
    end
    
%     if options.staircase %If this is the staircase, SD should be the staircase position
%         dots.SD = stimval;
%     end
%     
    
    
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

%% Send stop trial

SendTrig(trig, trig.stopTrial, options)

%% give the trigger some time
flipper
flipper
flipper
flipper
flipper

%% rotate Screen back!

if options.rotate
    Screen('glPopMatrix', windowPtr)
end