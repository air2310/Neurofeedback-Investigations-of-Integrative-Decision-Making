function SendTrig(trig, trig2send, options)

% EEG
if ~options.practice || options.staircase
    switch options.triggertype
        case 1
            
            io64(trig.ioObj, trig.address(2), trig2send);
            
            if ismember(trig2send, trig.BLOCK)
                 io64(trig.ioObj, trig.address(1), trig2send);
            end

        case 2
            fwrite(trig.Ptr, trig2send)
    end
end

% Eye Tracking
if ~options.practice && options.EyeTracking
    fwrite(trig.EYEPtr, trig2send,    'uint8'  )
end