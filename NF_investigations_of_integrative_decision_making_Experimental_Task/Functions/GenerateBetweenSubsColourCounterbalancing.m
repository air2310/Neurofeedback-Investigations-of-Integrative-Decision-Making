rng('shuffle');
Seed = rng;

n.subs = 40;
colourOpts = [1 2];
n.cOpts = length(colourOpts);

tmp = [];
for ii = 1:n.cOpts
    tmp = [tmp; ones(ceil(n.subs/2),1).*colourOpts(ii)];
end

idx = randperm(length(tmp));
ColourTrain = tmp(idx);

save(['ColourCounterBalance' date '.mat'])