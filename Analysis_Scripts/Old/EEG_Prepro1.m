%{
EEG_Prepro1
Author: Tom Bullock / Joyce Passananti
Date: 08.21.23
Purpose: 

load Magic Leap event codes and timestamps
load N400 pilot EEG data (joyce, 3 conditions)
extract triggers from audio channel and add to EEG.event structure
filter EEG
save EEG

Notes:

Set up folder structure in root dir (rDir) as follows (for now):

/Analysis_Scripts
/EEG_Prepro1
/EEG_raw
/Plots

** REMEMBER TO ADD EEGLAB TO PATH WHEN YOU FIRST OPEN MATLAB AND RUN SCRIPTS
[SEE COMMENTED LINES BELOW] **

Build in a trigger/event length checker
 
%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDirEEG = [rDir '/EEG_raw'];
sourceDirTrial = [rDir '/Trial'];
destDir = [rDir '/EEG_Prepro1'];
destDirPlots = [rDir '/Plots'];

% set file to process [will automate to do multiple subjects later]
%filename = 'audiotest2';

session = 1;

if session==1
    %filename = 'n400_test3_s_1-2'; 
    filename = 'N400_sj81_MWA';
    %renameFile = 'N400_Test1';
    renameFile = filename;
    rejectedPoints = 20000;
elseif session==2
    %filename = 'n400_test3_s_1-4'; 
    filename = 'N400_sj81_MWL';
    %renameFile = 'N400_Test2';
    renameFile = filename;
    rejectedPoints = 10000;
elseif session==3
    %filename = 'n400_test3_s_1-6'; 
    filename = 'N400_sj81_WWA';
    %renameFile = 'N400_Test3';
    renameFile = filename;
    rejectedPoints = 15000;
elseif session==4
    %filename = 'n400_test3_s_1-6'; 
    filename = 'N400_sj81_WWL';
    %renameFile = 'N400_Test3';
    renameFile = filename;
    rejectedPoints = 15000;
end

disp(['Processing: ' filename ' !!'])
pause(3);


% % % add EEGLAB to path and load GUI [only need run when first open matlab]
% cd([rDir '/eeglab14_1_2b'])
% eeglab
% cd(rDir)
% close


%% import magic leap stimulus timestamps and convert to correct format

% load event data from unity file
clear target_timestamps_raw initial_timestamp standard_timestamps_raw
events = readtable([sourceDirTrial '/' filename '.txt']);


%% load EEG data and preprocess

% load data
EEG = pop_fileio([sourceDirEEG '/' filename '.vhdr']);

% add channel locations
EEG = pop_chanedit(EEG, 'lookup',[rDir '/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp']); % add channel data


% for audiotest1 remove first 10k samples [remove first three
% "triggers"]
%if strcmp(filename,'n400_test3_s_1-2')
    EEG = pop_select(EEG,'nopoint',[1,rejectedPoints]); % this rejects first 10k samples [based on visual inspection of trigger plot below]
    disp('REJECTING FIRST xxx samples of data!!!')
% elseif strcmp(filename,'p300audiotest1')
%     EEG = pop_select(EEG,'point',[28000,2030000]); % this keeps EEG between the specified samples [again, based on visual inspection of trigger plot below]
%     disp('REJECTING a bunch of data!!!')
%end

%% extract events and insert into EEG struct

% isolate 64th channel (audio/trigger)
simdata = EEG.data(64,:);
simgap = 150;
simpeakThreshold = 1260310; % this works for session 1-2
simcounter = 0;
simindexPos = 0;
simpeaks = [];

% Iterate through the array
for i = 1:numel(simdata)
    if simdata(i) < simpeakThreshold
        simcounter = simcounter + 1;
    else
        % Check if 200 elements less than 21000 have been encountered
        if simcounter > simgap
        % Reset the counter for elements less than 21000
            simindexPos = simindexPos + 1;
            simpeaks(simindexPos) = i;
            
        end
        simcounter = 0;
    end
end
disp(simpeaks);

% plot trigger peaks for reality check [should be 1000 elements]
h=figure;
plot(simdata); hold on
plot(simpeaks,repmat(simpeakThreshold,[1,length(simpeaks)]),'LineStyle','none','Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r')
saveas(h,[destDirPlots '/' filename '_triggerAudit.fig'],'fig')

% insert events and timestamps into EEG.event structure [JUST LOOK AT
% CORRECT TRIALS FOR NOW]
for iEvent=1:length(simpeaks)

    % assign event value
    if strcmp(events{iEvent,4},'True') && strcmp(events{iEvent,3},'True')
        EEG.event(iEvent).type = 101; % assign code 101 if trial is true (i.e. valid pair) and response matches
    elseif strcmp(events{iEvent,4},'False') && strcmp(events{iEvent,3},'False')
        EEG.event(iEvent).type = 102; % assign code 102 if trial is false (i.e. invalid pair) and response matches
    end
    
    % assign timestamp
    trigger_lag = 110; % we determined this based on photodiode vs audio+stimtrak onset latency lag
    EEG.event(iEvent).latency = simpeaks(iEvent)-trigger_lag;

    % assign other unimportant things
    EEG.event(iEvent).duration = 1; % this is irrelevant
    EEG.event(iEvent).value = 'stim';
    EEG.event(iEvent).urevent = iEvent;

end

% save event info to struct
audioEventInfo.simpeaks = simpeaks;
audioEventInfo.simdata = simdata;

% check audio triggers and trials are consistent
if length(simpeaks)~=height(events)
    disp('MISMATCH! BREAK!')
    return
end


%% more EEG preprocessing

% kick out audio channel now, just want scalp EEG
EEG = pop_select(EEG,'nochannel',[64]);

% downsample EEG to speed up processing time
EEG = pop_resample(EEG,250);

% filter between 0.1 Hz (high pass) and 30 Hz (low pass) [SLOW]
EEG = pop_eegfiltnew(EEG,0.1,30);
%EEG = pop_eegfiltnew(EEG,0,30);

% find bad channels and interpolate
EEG.original_chanlocs = EEG.chanlocs;
EEG = clean_rawdata(EEG,[],'off',[],[],'off','off'); 
bad_channels = setdiff({EEG.original_chanlocs.labels},{EEG.chanlocs.labels});
bad_channel_list = {};
bad_channel_list = unique(cat(2,bad_channel_list,bad_channels));
EEG = pop_interp(EEG,EEG.original_chanlocs, 'spherical');


%% save EEG
save([destDir '/' renameFile '_EEG_Prepro1.mat'],'EEG','bad_channel_list','audioEventInfo')
