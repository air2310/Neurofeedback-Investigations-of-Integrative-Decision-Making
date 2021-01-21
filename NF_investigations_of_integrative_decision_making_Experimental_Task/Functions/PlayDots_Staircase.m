%% Play Dots

TRIAL = sc.trial;
responseWait = 0;
FRAME_ALL = 0;

for FRAME = 1:f.dotsmove-1
    %% Update frame count
    FRAME_ALL = FRAME_ALL + 1;
    
    %% Draw
        
    % draw.colvect ->[TRAINED dots, UNTRAINED dots.].
    % CTRAIN is constant for duration of exp. FTRAIN is counterbalanced
    FTRAIN = DATA(TRIAL, [D.idxHz_Trained D.idxHz_UnTrained]);
    
    for RGB = 1:3
        switch FTRAIN(1) % keep trained and untrained flicker freqs together while maintaining dot order. In CTRAIN and FTRAIN 1 = trained, 2 = untrained
            case 1 % order is always [slower dots faster dots] - switch around colours.
                draw.colvect(RGB,:) = [colvect(RGB,:, FTRAIN(1)).*dots.cols(CTRAIN(1),RGB)' colvect(RGB,:,FTRAIN(2)).*dots.cols(CTRAIN(2),RGB)'];
            case 2
                draw.colvect(RGB,:) = [colvect(RGB,:, FTRAIN(2)).*dots.cols(CTRAIN(2),RGB)' colvect(RGB,:,FTRAIN(1)).*dots.cols(CTRAIN(1),RGB)'];
        end
    end
    
    % - Draw Dots
    switch dotType
        case 1
                % moving dots
                draw.dotsxy = [DOT_XY(:,:,1,TRIALdot) DOT_XY(:,:,2,TRIALdot)]; % draw moving dots
                Screen('DrawDots', windowPtr, draw.dotsxy(:,dots.order), dots.width, draw.colvect(:,dots.order), mon.centre,1);  % change 1 to 0 to draw square dots
                
                % fixation
                Screen('FillRect', windowPtr, [colour.white colour.white], dots.fixation )
        case 2
            
            rectCoord = [
                (mon.centre(1) + DOT_XY(1,:,1,TRIALdot) - W),   (mon.centre(1) + DOT_XY(1,:,2,TRIALdot) - H);
                (mon.centre(2) + DOT_XY(2,:,1,TRIALdot) - H),   (mon.centre(2) + DOT_XY(2,:,2,TRIALdot) - W);
                (mon.centre(1) + DOT_XY(1,:,1,TRIALdot) + W),   (mon.centre(1) + DOT_XY(1,:,2,TRIALdot) + H);
                (mon.centre(2) + DOT_XY(2,:,1,TRIALdot) + H),   (mon.centre(2) + DOT_XY(2,:,2,TRIALdot) + W)];
            
            Screen('FillRect', windowPtr, draw.colvect(:,dots.order),  rectCoord(:,dots.order)  )
            
             % fixation
                Screen('FillRect', windowPtr, [colour.red colour.red], dots.fixation )
    end
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('DrawingFinished', windowPtr);
    
    SDUSE(FRAME, TRIAL) = stimval;
    dots.SD = stimval;
    
    %% Update Colors && Move Dots
    FRAME_use = FRAME +1;
    
    % update luminance
    for HH = 1:n.Hz
        scaler = (dots.max_d - sqrt( DOT_XY(1,:,HH,TRIALdot).^2 + DOT_XY(2,:,HH,TRIALdot).^2));
        scaler = 2*scaler/dots.max_d;
        scaler(scaler > 1) = 1;
        
        colvect(:,:,HH) = repmat(FLICKER(FRAME_use,:,HH).*scaler,3,1);
    end
    
    % update dot position
    for FIELD = 1:2
        DOT_XY(:,:,FIELD,TRIALdot) = updateDotCoords2(DOT_XY(:,:,FIELD,TRIALdot), dots, DirectFields, directions, TRIAL, FIELD);
    end
    
    %% FLIP!
    
    flipper
    if breaker; break; end
    
end