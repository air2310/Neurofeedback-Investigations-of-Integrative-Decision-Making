disp(['TRIAL: ' num2str(TRIAL) ', BLOCK: ' num2str(DATA(TRIAL, D.Block))])

%% Reset Variables
responseWait = 0;
FRAME_ALL = 0;
selectivity = 0;

%% IF Block start trial

if DATA(TRIAL, D.StartBlock)
    PresentBlockScreen
end

%% clear the decks of old sample position in buffer
if ~options.practice
    
    idx.samplesRead = readBufferSamples( cfg.stream );
    
    if TRIAL == 1
        idx.samplesRead = 0;
    end
end

%% Trigger Start of trial

% CTRAIN is constant for duration of exp. FTRAIN is counterbalanced
FTRAIN = DATA(TRIAL, [D.idxHz_Trained D.idxHz_UnTrained]); 
CTRAIN = [DATA(TRIAL, D.CTrain) DATA(TRIAL, D.CUnTrain)];

SendTrig(trig, trig.StartTrial(FTRAIN(1),CTRAIN(1)), options)
