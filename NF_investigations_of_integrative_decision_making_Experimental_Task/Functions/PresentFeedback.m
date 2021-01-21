for FRAME = 1:f.feedback
    FRAME_ALL = FRAME_ALL + 1;
    
    %% actual direction
    fb.angle = mean(directions(DirectFields(TRIAL,:)));
    
    if abs(diff(directions(DirectFields(TRIAL,:))))==AngDiff
        fb.angle = wrapTo360(min(directions(DirectFields(TRIAL,:)))+AngDiff/2);
    else
        fb.angle = wrapTo360(min(directions(DirectFields(TRIAL,:)))-AngDiff/2);
    end
    
    fb.x = cosd(fb.angle)*(dots.max_d-6);
    fb.y = sind(fb.angle)*(dots.max_d-6);
    
    lineCoordsFB = [
        0 fb.x;
        0 fb.y];
    
    
    %% Draw
    
    Screen('DrawTexture', windowPtr, Sprite.pointer, [], [], mouse.angle+90);
    
    Screen('DrawLines', windowPtr, lineCoordsFB, lineWidthPix, colour.red, mon.centre, 1);
    
    Screen('DrawTexture', windowPtr, Sprite.border, [], [],0);
    
    Screen('FillOval', windowPtr, colour.white, fix_coord);	% draw fixation dot
    
    %% tmp section for checking
    %
    %         lineCoordsTmp1 = [
    %             0 cosd(directions(DirectFields(TRIAL,1)))*(dots.max_d-6);
    %             0 sind(directions(DirectFields(TRIAL,1)))*(dots.max_d-6)];
    %
    %         lineCoordsTmp2 = [
    %             0 cosd(directions(DirectFields(TRIAL,2)))*(dots.max_d-6);
    %             0 sind(directions(DirectFields(TRIAL,2)))*(dots.max_d-6)];
    %
    %         Screen('DrawLines', windowPtr, lineCoordsTmp1, lineWidthPix, colour.white, mon.centre, 1);
    %         Screen('DrawLines', windowPtr, lineCoordsTmp2, lineWidthPix, colour.white, mon.centre, 1);
    %
    %%
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('DrawingFinished', windowPtr);
    
    %% FLIP!
    
    flipper
    if breaker; break; end
    
end
