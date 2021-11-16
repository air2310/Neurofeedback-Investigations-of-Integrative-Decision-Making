%% Neurofeedback, Attention and Decision making Experiment
%             ______    ___    _________    ___    ___    _________     __________     
%            /\      \ /\  \  /\   _____\  /\  \  /\  \  /\   ___  \   /\   ____  \  
%            \ \  \\ \ \ \  \ \ \  \____/_ \ \  \ \ \  \ \ \  \__\   \ \ \  \__/\  \
%             \ \  \ \ \ \\  \ \ \   _____\ \ \  \ \ \  \ \ \   __   /  \ \  \ \ \  \ 
%              \ \  \  \ \    \ \ \  \____/_ \ \  \_\_\  \ \ \  \  \  \  \ \  \_\_\  \  
%               \ \_ \   \ \ __\ \ \________\ \ \_________\ \ \__\\  \__\ \ \_________\  
% 	             \/__/     \/__/  \/________/  \/_________/  \/__/  \/__/  \/_________/   
%  _________    _________    _________    ________      ________       ______      ________    ___	  ___
% /\   _____\  /\   _____\  /\   _____\  /\   ____ \   /\   ___  \	  /  ____ \   /\   ____\  /\  \  /  /
% \ \  \____/_ \ \  \____/_ \ \  \____/_ \ \  \__/\  \ \ \  \__\  /  /\  \___\  \ \ \  \___/  \ \  \/  /
%  \ \   _____\ \ \   _____\ \ \   _____\ \ \  \ \ \  \ \ \   ___ \  \ \   ____  \ \ \  \      \ \     \
%   \ \  \____/  \ \  \____/_ \ \  \____/_ \ \  \_\_\  \ \ \  \__\  \ \ \  \__/\  \ \ \  \____  \ \  \\  \
%    \ \__\       \ \________\ \ \________\ \ \________/  \ \_______/  \ \__\ \ \__\ \ \_______\ \ \__\ \__\
%     \/__/        \/________/  \/________/  \/_______/    \/______/    \/__/  \/__/  \/_______/  \/__/\/__/   
%
% This script implements neurofeedback training of attentional selectivity,
% and can be used to assess how this selectivity might effect the decision 
% weighting of the selected feature
%
% Run with (in separate matlab streams):
% 1. ReadAmplifiers8 OR ArtificialDataStream -- Stream EEG data
% 2. SSVEP_Stream_V3                         -- Calculate SSVEP attentional selectivity
% 3. This script                             -- Evoke SSVEPs and display feedback
%
% Written by Angela. I. Renton (March '18)


%% Start
input('Press Enter to Start Experiment')

%% Directories

SUB = 0;

direct.functions = 'Functions\'; addpath(direct.functions);
SetupDirectories

%% Settings

options.practice = 0; 
options.DisplayStream = 1;
options.stripeAmp = 0;
SetupSettings

%% DATA

SetupDATA

%% TCP Server Client Setup

SetupTriggers

%% Setup Dots

SetupDots

%% setup Psychtoolbox

SetupGraphics

%%  Initialise Variables

SetupLoopVariables

%% Start Presenting Dots!

for TRIAL = 1:n.trials
    
    StartTrial
    
    %% Present trial
    
    PlayDots
   
%     pause(2);
    %% Response time
    
    GatherResponse
    
    %% feedback
    
    PresentFeedback
    
    %% Break out of animation loop if any key on keyboard or any button
    
    if breaker; break; end
    
end

%% Cleanup
Priority(0);
Screen('CloseAll');
% SendTrig(trig, trig.startRecording, options);
if ~options.practice
    io64(trig.ioObj, trig.address(1), trig.stopRecording);
end

% fclose(tcp.Ptr)

%% Save all
close all;

if options.practice
    save([direct.data observer.fname 'DisplayStream_Practice.mat']);
else
    save([direct.data observer.fname 'DisplayStream.mat']);
end

%% Quick Analysis

% if ~options.practice
%     PreliminaryAnalysis
% end

figure;
plot(diff(vbl))
