%{
EEG_Isolate_Triggers
Author: Tom Bullock / Joyce Passananti
Date: 02.12.24

Purpose: 

load Magic Leap event codes and timestamps
load N400 pilot EEG data (4 conditions
parse out triggers from EEG.event structure
save settings

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

% % % add EEGLAB to path and load GUI [only need run when first open matlab]
% cd([rDir '/eeglab14_1_2b'])
% eeglab
% cd(rDir)
% close

% which subject's to process?
subjects = 1;

for iSub = 1:length(subjects)
    sjNum = subjects(iSub);

    for iCond = 1:4

        if iCond==1; thisCond = 'MWA';
        elseif iCond==2; thisCond = 'MWL';
        elseif iCond==3; thisCond = 'WWA';
        elseif iCond==4; thisCond = 'WWL';
        end

        d = dir([sourceDirTrial '/' sprintf('sj%02d_n400_%s_*',sjNum,thisCond) ])

        filename = d.name;%sprintf('sj%02d_%s_task',sjNum,thisCond);


        disp(['Processing: ' filename ' !!'])
        pause(1);

        % load event data from unity file (downloaded from ML)
        clear target_timestamps_raw initial_timestamp standard_timestamps_raw
        events = readtable([sourceDirTrial '/' filename]);

        % load EEG data
        d = dir([sourceDirEEG '/' sprintf('sj%02d_%s.vhdr',sjNum,thisCond)]);
        EEG = pop_fileio([sourceDirEEG '/' d.name]);

        % add channel locations
        EEG = pop_chanedit(EEG, 'lookup',[rDir '/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp']); % add channel data


        % isolate trial data
        timeIdxToRemove = .1;
        if sjNum==1
            if iCond==1
                timeIdxToRemove = 121; % MISSING SOME TRIGGERS IN SECOND BLOCK
            elseif iCond==2
                timeIdxToRemove = 0; % CORRECT
            elseif iCond==3
                timeIdxToRemove = 0; % CORRECT
            elseif iCond==4
                timeIdxToRemove = 0; % CORRECT (only 50 trials though)
            end
        end

        EEG = pop_select(EEG,'notime',[0,timeIdxToRemove]);



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














        






        % isolate trial data
        timeIdxToRemove = .1;
        if sjNum==1
            if iCond==1
                timeIdxToRemove = 113; % MISSING SOME TRIGGERS IN SECOND BLOCK
            elseif iCond==2
                timeIdxToRemove = 145; % CORRECT
            elseif iCond==3
                timeIdxToRemove = 132; % CORRECT
            elseif iCond==4
                timeIdxToRemove = 142; % CORRECT (only 50 trials though)
            end
        end

        EEG = pop_select(EEG,'notime',[0,timeIdxToRemove]);

        % % sj01 icond01 exception
        % if sjNum==1 && iCond==1
        %     EEG = pop_select(EEG,'time',[0,400]);
        % end
        %
        % % sj01 icond01 and icond04 exception for only 50 trials
        % if sjNum==1 && ismember(iCond,1)
        %     events(51:100,:) = [];
        % end



        % parse triggers (removes duplicates created by tones)
        clear v newEventArray
        v = [EEG.event.latency];
        cnt=0;
        for i=1:length(v)-1
            if (v(i)-v(i+1)) <-1000
                cnt=cnt+1;
                newEventArray(cnt)=v(i+1)
            end
        end

        h=figure;
        plot(newEventArray/1000,repmat(1,[1,length(newEventArray)]),'LineStyle','none','Marker','o');
        set(gca,'FontSize',18)
        xlabel('Time (secs)')
        ylabel('Trigger Code (arbitrary)')
        title(thisCond)
        saveas(h,[destDirPlots '/' filename '_triggerAudit.fig'],'fig')



        % insert events and timestamps into EEG.event structure [just look at true
        % vs false in col 5 for now]
        EEG.event = [];
        for iEvent=1:length(newEventArray)

            % assign event value
            if strcmp(events{iEvent,5},'True')% && strcmp(events{iEvent,3},'True')
                EEG.event(iEvent).type = 101; % assign code 101 if trial is true (i.e. valid pair) and response matches
            elseif strcmp(events{iEvent,5},'False')% && strcmp(events{iEvent,3},'False')
                EEG.event(iEvent).type = 102; % assign code 102 if trial is false (i.e. invalid pair) and response matches
            end

            % assign timestamp
            trigger_lag = 110; % we determined this based on photodiode vs audio+stimtrak onset latency lag
            EEG.event(iEvent).latency = newEventArray(iEvent)-trigger_lag;

            % assign other unimportant things
            EEG.event(iEvent).duration = 1; % this is irrelevant
            EEG.event(iEvent).value = 'stim';
            EEG.event(iEvent).urevent = iEvent;

        end

        % save event info to struct
        %audioEventInfo.simpeaks = simpeaks;
        %audioEventInfo.simdata = simdata;

        % check audio triggers and trials are consistent
        if length(newEventArray)~=height(events)
            disp('MISMATCH! BREAK!')
            return
        else
            disp(sprintf('%d EVENT TRIGGERS CONFIRMED!',length(newEventArray)))
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

        %% calculate accuracy and RT stats
        accCnt=0;
        rtTotal=0;
        for i=1:height(events)
            if (strcmp(events{i,5}{1},'True')) && (events{i,4}==1)
                accCnt=accCnt+1;
                rtTotal = rtTotal + events{i,3};
            elseif (strcmp(events{i,5}{1},'False')) && (events{i,4}==2)
                accCnt=accCnt+1;
                rtTotal = rtTotal + events{i,3};
            end
        end

        accuracy = accCnt;
        rt = round(rtTotal/accCnt,1);




        %% save EEG
        save([destDir '/' sprintf('sj%02d_%s_EEG_Prepro1.mat',sjNum,thisCond)],'EEG','bad_channel_list','accuracy','rt')

        clear bad_channel_list bad_channels cnt events h i newEventArray v

    end
end
