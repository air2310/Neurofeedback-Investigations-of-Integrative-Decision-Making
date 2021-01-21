%% Neurofeedback, Attention and Decision making Experiment

%% Start
input('Press Enter to Start')

%% Directories

SUB = 4;

direct.functions = 'Functions\'; addpath(direct.functions);

SetupDirectories

%% Settings

options.practice = 1;
options.stripeAmp = 1;
options.DisplayStream = 1;
SetupSettings
options.EyeTracking = 0;

%% DATA

SetupDATAstripeAmp

%% TCP Server Client Setup

%% Triggers
SetupTriggers

%% Setup Dots

SetupDots

%% setup Psychtoolbox

SetupGraphics

%%  Initialise Variables

SetupLoopVariables

n.trials = 120;
options.staircase = 1;

%% Start Presenting Dots!
tic
for TRIAL = 1:n.trials
   
    StartTrial_StripeTest
    
    %% Present trial
    
    PlayDots_StripeTest
   
    %% Break out of animation loop if any key on keyboard or any button
    
    if breaker; break; end
    
end
toc
%% Cleanup
Priority(0);
Screen('CloseAll');

% Trigger Staircase and stop recording
SendTrig(trig, trig.StripeAmp, options);
pause(0.5);
io64(trig.ioObj, trig.address(1), trig.stopRecording);


%% Save all
close all;

save([direct.data str.sub 'StripeTest.mat']);
