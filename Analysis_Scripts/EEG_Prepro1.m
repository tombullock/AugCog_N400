%{
EEG_Prepro1
Author: Tom Bullock / Joyce Passananti
Date: 10.04.23
Last updated: 01.29.24
Purpose: 

load Magic Leap event codes and timestamps
load N400 pilot EEG data (4 conditions
parse out triggers from EEG.event structure
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
analysisScripts = [rDir '/Analysis_Scripts'];
sourceDirEEG = [rDir '/EEG_raw'];
sourceDirTrial = [rDir '/Trial'];
destDir = [rDir '/EEG_Prepro1'];
destDirPlots = [rDir '/Plots'];
% 
% % add EEGLAB to path and load GUI [only need run when first open matlab]
cd([rDir '/eeglab14_1_2b'])
eeglab
cd(analysisScripts)
close

% which subject's to process?
subjects = 26;%6;%9:12;% 1:3;

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
                timeIdxToRemove = 121; %121 % NOT SURE IF CORRECT - MAYBE TRY JIGGING?
                simpeakThreshold = 1260310;  % REMEMBER NOT NEGATIVE PEAKS!!!
            elseif iCond==2
                timeIdxToRemove = 140;
                simpeakThreshold = 1260310;
            elseif iCond==3
                timeIdxToRemove = 7;
                simpeakThreshold = 1260310;
            elseif iCond==4
                timeIdxToRemove = 241;
                simpeakThreshold = 1240310;
            end


        elseif sjNum==2
            if iCond==1
                timeIdxToRemove = 121; 
                simpeakThreshold = 1322000;
            elseif iCond==2
                timeIdxToRemove = 130;
                simpeakThreshold = 1322000;
            elseif iCond==3
                timeIdxToRemove = 355;
                simpeakThreshold = 1292750;
            elseif iCond==4
                timeIdxToRemove = 100;
                simpeakThreshold = 1318410;
            end

        elseif sjNum==3
            if iCond==1
                timeIdxToRemove = 138;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 169;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 169;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 113;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==4
            if iCond==1
                timeIdxToRemove = 9.5;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 12;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==5
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 30;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==6
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==7
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==8
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==9
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 4;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 36;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==10
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==11
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==12
            if iCond==1
                timeIdxToRemove = 10;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==13
            if iCond==1
                timeIdxToRemove = 10;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1213070;
            elseif iCond==4
                timeIdxToRemove = 19;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==14
            if iCond==1
                timeIdxToRemove = 10;
                simpeakThreshold = 1120280;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0; 
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1181610;
            end

        elseif sjNum==15
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==16
            if iCond==1
                timeIdxToRemove = 52;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==17
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 65;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==18
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==19
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==20
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 16;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==21
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==22
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==23
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        elseif sjNum==24
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

                    elseif sjNum==25
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

                                elseif sjNum==26
            if iCond==1
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==2
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==3
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            elseif iCond==4
                timeIdxToRemove = 0;
                simpeakThreshold = 1100000;
            end

        end

        EEG = pop_select(EEG,'notime',[0,timeIdxToRemove]);

        

        % cut out end of EEG file
        if sjNum==2 && iCond==3
            EEG = pop_select(EEG,'time',[0,1016]);
            events(97:100,:)=[];
        end

        if sjNum==23 && iCond==1
            EEG = pop_select(EEG,'time',[0,770]);
        end



        % sj exceptions - remove 
        


        % % sj01 icond01 exception
        % if sjNum==1 && iCond==1
        %     EEG = pop_select(EEG,'time',[0,400]);
        % end
        % 
        % % sj01 icond01 and icond04 exception for only 50 trials
        % if sjNum==1 && ismember(iCond,1)
        %     events(51:100,:) = [];
        % end

%% extract events and insert into EEG struct

        % isolate 64th channel (audio/trigger)
        simdata = EEG.data(64,:);
        simdata = abs(simdata);
        simgap = 150;
        % simpeakThreshold = 1260310; % this works for session 1-2
        simcounter = 0;
        simindexPos = 0;
        simpeaks = [];

        % Iterate through the array     
        if sjNum==1
            for i = 1:numel(simdata)
                if simdata(i) < simpeakThreshold % looking for peaks
                    simcounter = simcounter + 1;
                else
                    if simcounter > simgap
                        simindexPos = simindexPos + 1;
                        simpeaks(simindexPos) = i;
                    end
                    simcounter = 0;
                end
            end
        else
            for i = 1:numel(simdata)
                if simdata(i) > simpeakThreshold % looking for troughs
                    simcounter = simcounter + 1;
                else
                    if simcounter > simgap
                        simindexPos = simindexPos + 1;
                        simpeaks(simindexPos) = i;
                    end
                    simcounter = 0;
                end
            end
        end


        disp(simpeaks);

        % plot trigger peaks for reality check [should be 1000 elements]
        h=figure;
        plot(simdata); hold on
        plot(simpeaks,repmat(simpeakThreshold,[1,length(simpeaks)]),'LineStyle','none','Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r')
        saveas(h,[destDirPlots '/' filename '_triggerAudit.fig'],'fig')


        % create table to look at differences between triggers
        event_timing_check = [];
        for i=2:length(simpeaks)-1
            event_timing_check(i,:) = [simpeaks(i), simpeaks(i-1) - simpeaks(i)];
        end
        

        % remove simpeaks if needed (algo messed up)
        if sjNum==1 && iCond==4
            simpeaks([40,66]) = [];
        end

        if sjNum==2 && ismember(iCond,[1,2,3,4])
            simpeaks = [simpeaks(1)-7000,simpeaks]; % added missing first peak (algo wouldn't detect coz too low)
        end

        if sjNum==3 && ismember(iCond,[3])
            simpeaks = [simpeaks(1)-7000,simpeaks]; % added missing first peak (algo wouldn't detect coz too low)
        end

        


        % % parse triggers (removes duplicates created by tones)
        % clear v newEventArray
        % v = [EEG.event.latency];
        % cnt=0;
        % for i=1:length(v)-1
        %     if (v(i)-v(i+1)) <-1000
        %         cnt=cnt+1;
        %         newEventArray(cnt)=v(i+1)
        %     end
        % end
        % 
        % h=figure;
        % plot(newEventArray/1000,repmat(1,[1,length(newEventArray)]),'LineStyle','none','Marker','o');
        % set(gca,'FontSize',18)
        % xlabel('Time (secs)')
        % ylabel('Trigger Code (arbitrary)')
        % title(thisCond)
        % saveas(h,[destDirPlots '/' filename '_triggerAudit.fig'],'fig')

        if sjNum==5 && iCond==3
            events(1,:) = []; 
        end

                % for sj24 cond3 remove events 35 and 37
        if sjNum==24 && iCond==3
            %EEG = pop_select(EEG,'notrial',[35,37]);
            simpeaks([35,37]) = [];
            disp('SIMPEAKS EXCEPTION REMOVING 35 37')
            pause(3)
        end

        if sjNum==24 && iCond==4
            simpeaks([51,52]) = [];
            disp('SIMPEAKS EXCEPTION REMOVING 51 52')
            pause(3)
        end


        % insert events and timestamps into EEG.event structure [just look at true
        % vs false in col 5 for now]
        EEG.event = [];
        for iEvent=1:length(simpeaks)

            % assign event value
            if strcmp(events{iEvent,5},'True') && events{iEvent,4}== 1   
                EEG.event(iEvent).type = 101; % assign code 101 if trial is true (i.e. valid pair) and response matches
            elseif strcmp(events{iEvent,5},'False')  && events{iEvent,4}== 2   
                EEG.event(iEvent).type = 102; % assign code 102 if trial is false (i.e. invalid pair) and response matches
            elseif strcmp(events{iEvent,5},'True') && events{iEvent,4}== 2   
                EEG.event(iEvent).type = 111; % assign code 101 if trial is true (i.e. valid pair) and response doesn't match
            elseif strcmp(events{iEvent,5},'False')  && events{iEvent,4}== 1   
                EEG.event(iEvent).type = 112; % assign code 102 if trial is false (i.e. invalid pair) and response doesn't match
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
        %audioEventInfo.simpeaks = simpeaks;
        %audioEventInfo.simdata = simdata;

        % check audio triggers and trials are consistent
        if length(simpeaks)~=height(events)
            disp('MISMATCH! BREAK!')
            return
        else
            disp(sprintf('%d EVENT TRIGGERS CONFIRMED!',length(simpeaks)))
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

        if sjNum==9 && iCond==1
            EEG = pop_select(EEG,'nochannel',{'FC2'});
        end

        if sjNum==6 && iCond==2
            EEG = pop_select(EEG,'nochannel',{'F3'});
        end



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
        save([destDir '/' sprintf('sj%02d_%s_EEG_Prepro1.mat',sjNum,thisCond)],'EEG','bad_channel_list','accuracy','rt','-v7.3')

        clear bad_channel_list bad_channels cnt events h i newEventArray v 

    end
end
