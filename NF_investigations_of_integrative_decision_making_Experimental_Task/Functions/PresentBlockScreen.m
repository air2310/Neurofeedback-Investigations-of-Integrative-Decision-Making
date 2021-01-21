BLOCK = DATA(TRIAL, D.Block);
blockStart = false;

counter = 0;
while ~blockStart
    counter = counter + 1;
    Screen('TextSize', windowPtr, 40);
    Screen('DrawText', windowPtr, ['BLOCK ' num2str(BLOCK) ' OF ' num2str(n.blocks)],  mon.centre(1)-190, mon.centre(2)-100, colour.white);
    
    % Enforced 10 sec break.
    if ( counter > f.BlockBreakEnforce) || (BLOCK==1)
        Screen('TextSize', windowPtr, 20);
        Screen('DrawText', windowPtr, '[ENTER]',  mon.centre(1)-70, mon.centre(2)+50, colour.white);
        
        [~, ~, keyCode, ~] = KbCheck();
        if find(keyCode)==key.enter
            blockStart = true;
        end
    end
    
    % Flip
    vblB = Screen('Flip', windowPtr);
    
    if counter == 1 % Trigger Block
        SendTrig(trig, trig.BLOCK(BLOCK), options)
    end
    
end