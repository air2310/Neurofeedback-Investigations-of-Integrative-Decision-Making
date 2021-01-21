AssertOpenGL;

%% open the screen

screens=Screen('Screens');
screenNumber = mon.use; %max(screens);
[windowPtr, rect] = Screen('OpenWindow', screenNumber, 0);

% Enable alpha blending with proper blend-function.
% We need it for drawing of smoothed points:
Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% other screen things

[mon.centre(1), mon.centre(2)] = RectCenter(rect);
fix_coord = [mon.centre-fix_r mon.centre+fix_r];

mon.ref=Screen('FrameRate',windowPtr);      % frames per second
mon.ifi=Screen('GetFlipInterval', windowPtr);
if mon.ref==0
    mon.ref=1/mon.ifi;
end

Priority(MaxPriority(windowPtr));
if options.hideCursor
    HideCursor;	% Hide the mouse cursor
end

%% Initial flip...
vbl=Screen('Flip', windowPtr);

%% Load pointer

IM = imread( [direct.Stim 'pointer-02.png']);
[s1, s2, s3] = size(IM); % Get the size of the image
 
% IM2 = zeros(s1,s2,s3+1);
% IM2(:,:,1:3) = IM;
% IM2(:,:,4) = (mean(IM,3)~=255)*255;

Sprite.pointer = Screen('MakeTexture', windowPtr, IM);

%% load border
IM = imread( [direct.Stim 'border2-01.png']);
[s1, s2, s3] = size(IM); % Get the size of the image
 
IM2 = zeros(s1,s2,s3+1);
IM2(:,:,1:3) = IM;
IM2(:,:,4) = (mean(IM,3)==255)*255;

Sprite.border = Screen('MakeTexture', windowPtr, IM2);
% 
% Screen('DrawTexture', windowPtr, Sprite.border, [], [],0);
% Screen('DrawingFinished', windowPtr);
% Screen('Flip', windowPtr);

%% Starting var
breaker = 0;
dots.dxdy = NaN(dots.n, 2, n.fields);

for TT = 1:n.trials
    for FIELD = 1:n.fields
        dots.AngDist(:,FIELD, TT) = randn(dots.n,1);
    end
end

% TRIALdot = 1;
dots.order = NaN(n.trials,dots.n*2);
for TT = 1:n.trials
    dots.order(TT,:) = randperm(dots.n*n.fields);
end

colour.white = uint8([1 1 1]*255)';
colour.black =  uint8([0 0 0]*255)';
colour.green = uint8([0 1 0]*255)';
colour.red = uint8([1 0 0]*255)';

%% Fixation cross
dots.fixation = [
    mon.centre(1) - 8, mon.centre(1) - 2; 
    mon.centre(2) - 2, mon.centre(2) - 8; 
    mon.centre(1) + 8, mon.centre(1) + 2; 
    mon.centre(2) + 2, mon.centre(2) + 8];

%% Rectangle

rect_train{1} = [
    mon.centre(coord.x) - W
    mon.centre(coord.y) - H
    mon.centre(coord.x) + W
    mon.centre(coord.y) + H];

rect_train{2} = [
    mon.centre(coord.x) - H
    mon.centre(coord.y) - W
    mon.centre(coord.x) + H
    mon.centre(coord.y) + W];

%% #######################
% W = 24;
% z = W^2;
% x = sqrt(z/2);
% x=x/2;
% 
% Screen('DrawLine', windowPtr , colour.white, mon.centre(coord.x) -x, mon.centre(coord.y)-x, mon.centre(coord.x) + x, mon.centre(coord.y) +  x, 8);
% Screen('DrawLine', windowPtr , colour.white, mon.centre(coord.x) +x, mon.centre(coord.y)-x, mon.centre(coord.x) - x, mon.centre(coord.y) +  x, 8);
% Screen('Flip', windowPtr)

% %%
% rect_train{1} = [
%     mon.centre(coord.x) - 5.7, mon.centre(coord.y) - 11.3
%     mon.centre(coord.x) - 11.3, mon.centre(coord.y) - 5.7
%     mon.centre(coord.x) + 5.7, mon.centre(coord.y) + 11.3
%     mon.centre(coord.x) + 11.3, mon.centre(coord.y) + 5.7];
% 
% tmpX = (randn(1,400)-0.5)*300;
% tmpY = (randn(1,400)-0.5)*300;
% 
% points = rect_train{1};
% % points(:,1) = points(:,1);% + tmpX;
% % points(:,2) = points(:,2); %+ tmpY;
% 
% rectCoord = [
%     (rect_train{CTRAIN(2)}(1) + DOT_XY(coord.x,:,freq.A) ),   (rect_train{CTRAIN(1)}(1) + DOT_XY(coord.x,:,freq.B) );
%     (rect_train{CTRAIN(2)}(2) + DOT_XY(coord.y,:,freq.A) ),   (rect_train{CTRAIN(1)}(2) + DOT_XY(coord.y,:,freq.B) );
%     (rect_train{CTRAIN(2)}(3) + DOT_XY(coord.x,:,freq.A) ),   (rect_train{CTRAIN(1)}(3) + DOT_XY(coord.x,:,freq.B) );
%     (rect_train{CTRAIN(2)}(4) + DOT_XY(coord.y,:,freq.A) ),   (rect_train{CTRAIN(1)}(4) + DOT_XY(coord.y,:,freq.B) )];
% 
% return
% Screen('FillPoly', windowPtr, colour.white, rectCoord );
% Screen('Flip', windowPtr)
% return