%%
SetMouse(mon.centre(1), mon.centre(2), windowPtr); % set mouse to centre
ticker = tic;
while responseWait == 0
    FRAME_ALL = FRAME_ALL + 1;
    
    % Get Mouse Angle
    [mouse.x, mouse.y, mouse.buttons] = GetMouse(windowPtr);
    mouse.angle = atand((mouse.y - mon.centre(2))/(mouse.x  - mon.centre(1)));
    if (mouse.x - mon.centre(1))<0
        mouse.angle = mouse.angle + 180;
    end
    %         disp(mouse.angle);
    
    % Get line coords
%     response.x = cosd(mouse.angle)*dots.max_d;
%     response.y = sind(mouse.angle)*dots.max_d;
%     
%     lineCoords = [
%         0 response.x;
%         0 response.y];
    
    %% Draw
    
    if ~isnan(mouse.angle)
        Screen('DrawTexture', windowPtr, Sprite.pointer, [], [], mouse.angle+90);
    end
    Screen('DrawTexture', windowPtr, Sprite.border, [], [],0);
    
    
    Screen('FillOval', windowPtr, colour.white, fix_coord);	% draw fixation dot
    
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('DrawingFinished', windowPtr);
    
    %% FLIP!
    
    flipper
    if breaker; break; end
    
    %% - break out of response if leftclick
    if mouse.buttons(1)
        RESPONSE_TIME(TRIAL) = toc(ticker);
        RESPONSE(TRIAL) = mouse.angle;
        Correct_RESPONSE(TRIAL) = mean(directions(DirectFields(TRIAL,:)));
        
        responseWait = 1;
    end
end
