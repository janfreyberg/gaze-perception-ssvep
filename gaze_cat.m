clearvars
savefile = fullfile(pwd, 'Results', 'test_data.mat');
scripts = savescripts;
try
%% Setup

% Background Luminance
scr_background = 127.5;

% Open Full-Screen Window
Screen('Preference', 'SkipSyncTests', 1); % JUST FOR TESTING

scr_no = 0;
scr = Screen('OpenWindow', scr_no, scr_background);
rng('shuffle');

% Picture Frequency
f_pictures = 6; % flicker freq in Hz for all images

% Screen Frequency
if IsWin
    f_screen = Screen('FrameRate', scr_no); % this does not work on Mac??
elseif IsOSX
    frame_dur = Screen('GetFlipInterval', scr);
    f_screen = round(1/frame_dur);
end

t_frames = round(f_screen / f_pictures);

% Face Frequency
f_face = f_pictures/5; % this NEEDS to be an integer division of f_pictures

% Trial Duration
trialdur = 20;

% Break Duration
breakdur = 4;

% Contrasts
% contrasts = [0 0.08, 0.16, 0.32, 0.64];

% Stimulus Size
% stimsize = 12;
stimsize = 200; % this is in pixels (actual image size)

% Spatial Frequency
cycperdeg = 2;

% Repitions per Condition
nrep = 6;

% Background Luminance
scr_background = 127.5;

% Image Folders & Numbers
folder_objects = fullfile(pwd, 'Stimuli', 'frontal');
folder_faces = fullfile(pwd, 'Stimuli', 'sideways');

filenames_objects = dir(fullfile(folder_objects, '*.jpg'));
filenames_faces = dir(fullfile(folder_faces, '*.jpg'));

n_objects = size(dir(fullfile(folder_objects, '*.jpg')), 1);
n_faces = size(dir(fullfile(folder_faces, '*.jpg')), 1);

filenames_all(1:n_objects) = filenames_objects;
filenames_all(n_objects+1:n_objects+n_faces) = filenames_faces;


%% Set up Keyboard, Screen, Sound

% Variables related to Display
scr_diagonal = 24;
scr_distance = 60;
frame_dur = 1/f_screen;

% Keyboard
KbName('UnifyKeyNames');
u_key = KbName('UpArrow');
d_key = KbName('DownArrow');
l_key = KbName('LeftArrow');
r_key = KbName('RightArrow');
esc_key = KbName('Escape');
ent_key = KbName('Return'); ent_key = ent_key(1);
keyList = zeros(1, 256);
keyList([u_key, d_key, esc_key, ent_key]) = 1;
KbQueueCreate([], keyList); clear keyList
ListenChar(2);

% I/O driver
% config_io
address = hex2dec('D010');

% Sound
InitializePsychSound;
pa = PsychPortAudio('Open', [], [], [], [], [], 256);
bp400 = PsychPortAudio('CreateBuffer', pa, [MakeBeep(400, 0.2); MakeBeep(400, 0.2)]);
PsychPortAudio('FillBuffer', pa, bp400);

% Open Window
% scr = Screen('OpenWindow', scr_no, scr_background);
HideCursor;
Screen('BlendFunction', scr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Screen('TextFont', scr, 'Segoe UI Light');
Screen('TextSize', scr, 20);
scr_dimensions = Screen('Rect', scr_no);
xcen = scr_dimensions(3)/2;
ycen = scr_dimensions(4)/2;

% Display Configuring Screen
DrawFormattedText(scr, 'Configuring...', 'center', 'center', 0);
Screen('Flip', scr);


%% Prepare stimuli
% This just covers the stimulus parameters, the actual loading of images
% happens for each trial separately

% Stimulus Size, if conversion is needed code here
pxsize = stimsize;

% Fixation Cue (maybe not necessary)
fixWidth = 2; % make sure it doesn't exceed hardware max
fixLength = 8;
fixLines = [-fixLength, +fixLength, 0, 0; 0, 0, -fixLength, +fixLength];
fixColor = 0.2 * 255;

% Stimposition
offset = 0;
stimRect = [xcen-offset-pxsize/2, ycen-pxsize/2, xcen-offset+pxsize/2, ycen+pxsize/2];

% On-Off Flicker Wave (sinusoidal)
flicker_wave = (cos(linspace(pi, 3*pi, t_frames)) + 1)/2;


%% Trial Order
% Code here any trial randomisation



%% Instructions
instrucs = ['In the following few trials, we just want to measure your brain response to\n\n',...
            'natural images. We are going to present these images in quick succession for\n\n'...
            '60s. During this time, please keep your eyes fixated on the images, and stay\n\n'...
            'alert. There will be 12 trials, and in between trials you will have some time\n\n'...
            'to rest your eyes. Press the Space Bar when you are ready to begin.'];
DrawFormattedText(scr, instrucs, 'center', 'center', 0);
Screen('Flip', scr);
KbStrokeWait;


%% Demonstration
% % Display Configuring Screen
% DrawFormattedText(scr, 'Configuring...', 'center', 'center', 0);
% Screen('Flip', scr);
% 
% % Load stimuli for this trial
% n_trialstims = trialdur * f_pictures;
% list_trialstims = randperm(n_objects, n_trialstims);
% for iStim = 1:numel(list_trialstims)
%     temp_image = imread( fullfile(folder_objects, filenames_objects(list_trialstims(iStim)).name) );
%     temp_alpha = ~(sum(temp_image, 3) >= 3*250) * 255;
%     temp_image = cat(3, temp_image, temp_alpha);
%     temp_image( ~any(temp_alpha, 2), :, : ) = []; % delete rows
%     temp_image( :, ~any(temp_alpha, 1), : ) = []; % delete cols
%     textures_trial{iStim} = Screen('MakeTexture', scr, temp_image);
% end
% 
% % Replace every 5th with a face
% n_trialfaces = floor(trialdur * f_face);
% list_trialfaces = randperm(n_faces, n_trialfaces);
% for iFace = 1:n_trialfaces
%     Screen('Close', textures_trial{iFace * f_pictures/f_face});
%     temp_image = imread( fullfile(folder_faces, filenames_faces(list_trialfaces(iFace)).name) );
%     temp_alpha = ~(sum(temp_image, 3) >= 3*250) * 255;
%     temp_image = cat(3, temp_image, temp_alpha);
%     temp_image( ~any(temp_alpha, 2), :, : ) = []; % delete rows
%     temp_image( :, ~any(temp_alpha, 1), : ) = []; % delete cols
%     textures_trial{iFace * f_pictures/f_face} = Screen('MakeTexture', scr, temp_image);
% end
% 
% % Pre-Trial
% DrawFormattedText(scr, ['Practice Trial', '\nReady?'], 'center', ycen-pxsize/3, 0);
% Screen('DrawLines', scr, fixLines, fixWidth, fixColor, [xcen, ycen]);
% Screen('Flip', scr);
% KbStrokeWait;
% Screen('DrawLines', scr, fixLines, fixWidth, fixColor, [xcen, ycen]); 
% Screen('Flip', scr);
% WaitSecs(2);
% 
% % Trial
% Priority(1);
% trial_frames = ceil(trialdur * f_screen);
% t_last = GetSecs;
% for i = 1:trial_frames;
%     Screen('DrawTexture', scr, textures_trial{ ceil(i/t_frames) }, [], [], [], [], flicker_wave(mod(i-1, t_frames)+1));
%     t_last = Screen('Flip', scr, t_last+0.5*frame_dur); % specify deadline for timing issues?
% end
% Priority(0);
% Screen('Close');
% 
% % Take a Break
% KbQueueStart;
% for lapsedTime = 0:breakdur
% DrawFormattedText(scr, ['Break for ' num2str(breakdur-lapsedTime)], 'center', ycen-pxsize/3, 0);
% Screen('Flip', scr);
% [~, pressed] = KbQueueCheck;
% if pressed(esc_key)
%     error('Interrupted in the break!');
% end
% WaitSecs(1);
% end
% KbQueueStop;


%% Go through Trials
for iTrial = 1:12
    
    % Display Configuring Screen
    DrawFormattedText(scr, 'Configuring...', 'center', 'center', 0);
    Screen('Flip', scr);

    % Load stimuli for this trial
    n_trialstims = trialdur * f_pictures;
    list_trialstims = randperm(n_objects, n_trialstims);
    for iStim = 1:numel(list_trialstims)
        temp_image = imread( fullfile(folder_objects, filenames_objects(list_trialstims(iStim)).name) );
        temp_alpha = ~(sum(temp_image, 3) >= 3*250) * 255;
        temp_image = cat(3, temp_image, temp_alpha);
        temp_image( ~any(temp_alpha, 2), :, : ) = []; % delete rows
        temp_image( :, ~any(temp_alpha, 1), : ) = []; % delete cols
        temp_image = imresize( temp_image, pxsize/size(temp_image, 2) ); % resize image to be 200px wide
        
        textures_trial{iStim} = Screen('MakeTexture', scr, temp_image);
    end

    % Replace every 5th with a face
    n_trialfaces = floor(trialdur * f_face);
    list_trialfaces = randperm(n_faces, n_trialfaces);
    for iFace = 1:n_trialfaces
        Screen('Close', textures_trial{iFace * f_pictures/f_face});
        temp_image = imread( fullfile(folder_faces, filenames_faces(list_trialfaces(iFace)).name) );
        temp_alpha = ~(sum(temp_image, 3) >= 3*250) * 255;
        temp_image = cat(3, temp_image, temp_alpha);
        temp_image( ~any(temp_alpha, 2), :, : ) = []; % delete rows
        temp_image( :, ~any(temp_alpha, 1), : ) = []; % delete cols
        temp_image = imresize( temp_image, pxsize/size(temp_image, 2) ); % resize image to be 200px wide
        
        textures_trial{iFace * f_pictures/f_face} = Screen('MakeTexture', scr, temp_image);
    end

    % Pre-Trial
    DrawFormattedText(scr, ['Practice Trial', '\nReady?'], 'center', ycen-pxsize/3, 0);
    Screen('DrawLines', scr, fixLines, fixWidth, fixColor, [xcen, ycen]);
    Screen('Flip', scr);
    KbStrokeWait;
    Screen('DrawLines', scr, fixLines, fixWidth, fixColor, [xcen, ycen]); 
    Screen('Flip', scr);
    WaitSecs(2);
    
    % Trial
    Priority(1);
    outp(address, iTrial); % decide how to trigger trials
    WaitSecs(0.002);
    outp(address, 0);
    trial_frames = ceil(trialdur * f_screen);
    t_last = GetSecs;
    for i = 1:trial_frames;
        Screen('DrawTexture', scr, textures_trial{ ceil(i/t_frames) }, [], [], [], [], flicker_wave(mod(i-1, t_frames)+1));
        t_last = Screen('Flip', scr, t_last+0.5*frame_dur); % specify deadline for timing issues?
    end
    Priority(0);
    Screen('Close');
    
    % Clean Up
    outp(address, 255); % the 255 trigger marks the end of trials
    WaitSecs(0.002);
    outp(address, 0);
    Priority(0);
    
    % Take a Break
    KbQueueStart;
    for lapsedTime = 0:breakdur
    DrawFormattedText(scr, ['Break for ' num2str(breakdur-lapsedTime)], 'center', ycen-pxsize/3, 0);
%     DrawFormattedText(scr, sprintf('%2.1f %%', 100*frames_dropped), 0, 0, 0);
    Screen('Flip', scr);
    [~, pressed] = KbQueueCheck;
    if pressed(esc_key)
        error('Interrupted in the break!');
    end
    WaitSecs(1);
    end
    KbQueueStop;
    
end


%% Shut Down
KbQueueFlush;
KbQueueStop;
KbQueueRelease;
ListenChar(0);
sca;
PsychPortAudio('Close');
save(savefile);
Priority(0);


catch err
%% Catch Errors
KbQueueFlush;
KbQueueStop;
KbQueueRelease;
ListenChar(0);
sca;
PsychPortAudio('Close');
save(savefile);
Priority(0);
rethrow(err);


end