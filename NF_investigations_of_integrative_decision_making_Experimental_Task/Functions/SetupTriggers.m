%% Triggers

trig.stopRecording = 254;
trig.startRecording = 255;

trig.StartTrial = [
    1 3
    2 4];

trig.stopTrial = 5;

trig.staircase = 55;
trig.StripeAmp = 56;

trig.BLOCK = (1:n.blocks) + 100;
%% Setup triggering
if ~options.practice ||options.staircase || options.stripeAmp
    switch options.triggertype
        case 1
            
            trig.ioObj = io64;
            trig.status = io64(trig.ioObj);
            
            switch PCuse
                case 1
                     trig.options.port = { 'D010'  'D030' };
                case 3
                     trig.options.port = { 'D050'  'D050' };
                case 4
                    trig.options.port = { '21'  '21' };
            end
            n.ports = length(trig.options.port);
            trig.address = NaN(n.ports,1);
            
            for AA = 1:n.ports
                trig.address(AA) = hex2dec( trig.options.port{AA} );
            end
            io64(trig.ioObj, trig.address(2), 0);
            
        case 2
            tcp.IP = getIP(direct.ip);
            
            tcp.networkRole = 'client';
            
            trig.Ptr = tcpip(tcp.ip, 'NetworkRole', tcp.networkRole);
            fopen(trig.Ptr)
    end
end

if ~options.practice && options.EyeTracking
    trig.EYEPtr = tcpip('localhost',1972);
    fopen(trig.EYEPtr)
end


%%
% 
% ioObj = io64;
% status = io64(ioObj);
% % address = hex2dec('2FF4');
% address = hex2dec('D030');
% 
% 
% io64(ioObj, address, 0)
% io64(ioObj, address, 5)
% 
% address = hex2dec('21');
% 
% io64(ioObj, address, trig.stopRecording)
