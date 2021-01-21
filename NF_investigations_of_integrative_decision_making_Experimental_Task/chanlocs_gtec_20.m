labels{1} = {
    'O9'
    'O1' 
    'PO9'
    'PO7'
    'PO3'
    'P9'
    'P7'
    'P3'
    'O10'
    'O2'
    'PO10'
    'PO8'
    'PO4'
    'P10'
    'P8'
    'P4'
    'trig'};

labels{2} = {
    'Iz'
    'Oz' 
    'POz'
    'Pz'     };

%% create str.chan
count = 0;
for group = 1:2
    for CC = 1:length(labels{group})
        count = count +1;
        str.chan{count} = labels{group}{CC};
    end
end

