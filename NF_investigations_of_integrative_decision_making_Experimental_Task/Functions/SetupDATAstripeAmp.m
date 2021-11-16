%% Design DATA
str.DATA = {
    'Trial'
    'Block'
    
    'StartBlock'
    'CatchTrial'
    
    'TrainedCol'
    
    'idxHz_Trained'
    'idxHz_UnTrained'
    
    'CTrain'
    'CUnTrain'};

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
    load([direct.counterbalanceData 'ColourCounterBalance21-Mar-2018.mat'], 'ColourTrain') % Counterbalancing describing the order in which features are trained
    Col2train = ColourTrain(SUB);
end

DATA(:,D.TrainedCol) = ones(n.trials,1).*Col2train;

switch Col2train
    case 1
        CTRAIN = [1 2]; %[Trained Untrained]
    case 2
        CTRAIN = [2 1]; %[Trained Untrained]
end

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


%% Ctrain

for ii = 1:n.blocks 
   idx.block =  ismember(DATA(:,D.Block), ii);
   
   idx.F1 = DATA(:,D.idxHz_Trained)==1;
   idx.F2 = DATA(:,D.idxHz_Trained)==2;
   
   tmp_F1 = [];
   tmp_F2 = [];
   for jj = 1:2
       tmp_F1 = [tmp_F1; ones(sum(idx.F1)/2, 1).*jj ];
       tmp_F2 = [tmp_F2; ones(sum(idx.F2)/2, 1).*jj ];
   end
   
   tmp_F1 = tmp_F1(randperm(sum(idx.F1)));
   tmp_F2 = tmp_F2(randperm(sum(idx.F2)));
   
   DATA(idx.F1, D.CTrain) = tmp_F1;
   DATA(idx.F2, D.CTrain) = tmp_F2;
end

DATA(:, D.CUnTrain) = ~(DATA(:, D.CTrain)-1)+1; % Untrained in the inverse of trained


% sum(DATA(:,D.CTrain)==1 & DATA(:,D.idxHz_Trained)==1 )
% sum(DATA(:,D.CTrain)==1 & DATA(:,D.idxHz_Trained)==2 )
% sum(DATA(:,D.CTrain)==2 & DATA(:,D.idxHz_Trained)==1 )
% sum(DATA(:,D.CTrain)==2 & DATA(:,D.idxHz_Trained)==2 )