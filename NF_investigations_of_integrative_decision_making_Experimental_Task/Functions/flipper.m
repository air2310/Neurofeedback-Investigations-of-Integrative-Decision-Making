% - Flip!
if FRAME_ALL <= f.trial*2
    vbl(FRAME_ALL, TRIAL) = Screen('Flip', windowPtr);
else
    Screen('Flip', windowPtr);
end

% - break if esc pressed
[~, ~, keyCode, ~] = KbCheck();
if find(keyCode)==key.esc
    if options.hideCursor
        ShowCursor
    end
    breaker = true;
end