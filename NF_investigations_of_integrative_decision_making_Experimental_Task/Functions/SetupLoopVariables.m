% - responses
RESPONSE = NaN(n.trials,1);
RESPONSE_TIME = NaN(n.trials,1);
Correct_RESPONSE = NaN(n.trials,1);

% Buffer Reading

SELECTIVITY = [];
SELECTIVITY_Metadata = [];
SELECTIVITY_Structured = NaN(f.dotsmove, n.trials);

% Buffer Read Timing
ReadTimer = tic;
readTiming = [];

% Selectivity SD
SDUSE = NaN(f.dotsmove, n.trials);

% fliptime
vbl = NaN(f.trial*2, n.trials);

if options.practice;  n.trials = 20; end

% Buffer Read count 

BufferReadCount = zeros(1, n.trials);