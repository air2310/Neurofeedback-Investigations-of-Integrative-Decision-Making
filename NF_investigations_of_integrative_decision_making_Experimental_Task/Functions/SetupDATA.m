
%% Design DATA
str.DATA = {
    'Trial'
    'Block'
    
    'StartBlock'
    'CatchTrial'
    
    'TrainedFeature'
    'UnTrainedFeature'
    
    'idxHz_Trained'
    'idxHz_UnTrained'};

n.D = length(str.DATA);

for ii = 1:n.D
   D.(str.DATA{ii}) = ii; 
end

DATA = NaN(n.trials, n.D);

%% Fill DATA
%% - Trials
DATA(:,D.Trial) = 1:n.trials; 

%% - Block count
tmp = [];
for ii = 1:n.blocks
    tmp = [tmp; ones(n.trialsBlock,1).*ii];
end
DATA(:,D.Block) = tmp;

%% - Block startTrials
PHold = zeros(n.trialsBlock,1); PHold(1) = 1;
tmp = [];
for ii = 1:n.blocks
    tmp = [tmp; PHold];
end
DATA(:,D.StartBlock) = tmp;

%% - Catch Trials
n.catchTrialsBlock = n.trialsBlock*CatchTrialRatio; % How many catch trials in the block
n.trialsPerCatch = n.trialsBlock/n.catchTrialsBlock; 

tmp = [];
for ii = 1:n.blocks
    for jj = 1:n.catchTrialsBlock % Place one catch trial in every group of 10 trials (seudo-random placing)
        idx.catch = ceil(rand*n.trialsPerCatch);
        
        PHold = zeros(n.trialsPerCatch,1);
        PHold(idx.catch) = 1;
        
        tmp = [tmp; PHold];
    end
end
% figure; plot(diff(find(tmp))); % number of trials between each catch trial;
DATA(:,D.CatchTrial) = tmp;

%% Colour Counterbalancing

if SUB == 0
    Col2train = ceil(rand*2);
    Col2train = [1];
else
    load([direct.counterbalanceData 'ColourCounterBalance21-Mar-2018.mat'], 'ColourTrain')
    Col2train = ColourTrain(SUB);
end


switch Col2train
    case 1
        ctrain1 = [1 2]; %[Trained Untrained]
    case 2
        ctrain1 = [2 1]; %[Trained Untrained]
end


DATA(1:round(n.trials/2),D.TrainedFeature) = ones(round(n.trials/2),1).*ctrain1(1);
DATA(1:round(n.trials/2),D.UnTrainedFeature) = ones(round(n.trials/2),1).*ctrain1(2);

DATA(round(n.trials/2)+1:end,D.TrainedFeature) = ones(round(n.trials/2),1).*ctrain1(2);
DATA(round(n.trials/2)+1:end,D.UnTrainedFeature) = ones(round(n.trials/2),1).*ctrain1(1);


%% Frequency Counterbalancing - for catch trials and reqular trials separately

for ii = 1:n.blocks 
   idx.block =  ismember(DATA(:,D.Block), ii);
   
   idx.catch = idx.block & DATA(:,D.CatchTrial);
   idx.NF =  idx.block & ~DATA(:,D.CatchTrial);
   
   tmp_catch = [];
   tmp_NF = [];
   for jj = 1:2
       tmp_catch = [tmp_catch; ones(sum(idx.catch)/2, 1).*jj ];
       tmp_NF    = [tmp_NF;    ones(sum(idx.NF)   /2, 1).*jj ];
   end
   
   tmp_catch = tmp_catch(randperm(sum(idx.catch)));
   tmp_NF = tmp_NF(randperm(sum(idx.NF)));
   
   DATA(idx.catch, D.idxHz_Trained) = tmp_catch;
   DATA(idx.NF, D.idxHz_Trained) = tmp_NF;
end

DATA(:, D.idxHz_UnTrained) = ~(DATA(:, D.idxHz_Trained)-1)+1; % Untrained in the inverse of trained

