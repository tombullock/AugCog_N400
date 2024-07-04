%{
EEG_Compile_N400
Author: Tom Bullock
Date: 03.13.24
Purpose: create grand avg ERPs

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/EEG_Prepro1'];
destDir = [rDir '/Data_Compiled'];

% % % add EEGLAB to path and load GUI [only need run when first open matlab]
% cd([rDir '/eeglab14_1_2b'])
% eeglab
% cd(rDir)
% close

% which subject's to process?
subjects = 1:26;

for iSub = 1:length(subjects)
    sjNum = subjects(iSub);

    for iCond = 1:4

        if iCond==1; thisCond = 'MWA';
        elseif iCond==2; thisCond = 'MWL';
        elseif iCond==3; thisCond = 'WWA';
        elseif iCond==4; thisCond = 'WWL';
        end

        filename = sprintf('sj%02d_%s_EEG_Prepro1.mat',sjNum,thisCond);

        disp(['Processing: ' filename ' !!'])
        pause(1);

        % load prepro1 EEG data
        load([sourceDir '/' filename ])

        %% additional preprocessing steps

        % re-ref to mastoids [online ref chan removed hence chan index changed]
        EEG = pop_reref(EEG,[9,20],'keepref','on');

        % remove eyeblinks
        EEG = pop_crls_regression( EEG, [1, 31], 1, 0.9999, 0.01,[]);   % remove eye-blinks using AAR toolbox

        % remove eyeblink channels
        EEG = pop_select(EEG,'nochannel',{'Fp1','Fp2'});

        %% epoch data from -200 ms pre stim to 1000 ms post-stim and split into
        %% targets and standards

        % original EEG file
        EEGO = EEG;

        % split into standards and targets
        for iStimType=1:2
            if iStimType==1
                EEG_cong = pop_epoch(EEGO,{101},[-.2,1]);
                EEG_cong = pop_rmbase(EEG_cong,[-200,0]);
            else
                EEG_incong = pop_epoch(EEGO,{102},[-.2,1]);
                EEG_incong = pop_rmbase(EEG_incong,[-200,0]);
            end
        end




        % run threshold rejection

        % SET CHANNELS FOR THRESHOLD REJECTION AND PLOTTING

        %theseChanLabels = {'AFz','AF3','AF4','F1','Fz','F2','FC1','FC2','C1','Cz','C2'};
        %theseChanLabels = {'CPz','CP1','CP2','C1','Cz','C2'}; %'C1','Cz','C2', ,'Pz','P1','P2'
        theseChanLabels = {'CPz','CP3','CP4','C3','Cz','C4','FC3','FCz','FC4'}; %'C1','Cz','C2', ,'Pz','P1','P2'
        %theseChanLabels = {'Oz','POz','PO3','PO4','O1','O2'};

        % identify noisy peripheral channels + refs to exclude from threshold rej routine
        chanlocs = EEG.chanlocs;
        
        %chansToExclude = {'TP9','TP10','FT9','FT10','Fp1','Fp2'};
        %[~,chansToInclude] = setdiff({chanlocs.labels},chansToExclude);
        %chansToInclude = sort(chansToInclude);
        
        % subject exception [manually add bad elects]
        %chansToExclude{end+1} = 'F4';

        idx = ismember({chanlocs.labels},theseChanLabels);
        chansToInclude = find(idx==1);


        pcTrialRej_cong = 0; 
        for iStimType=1:2
            if iStimType==1
                EEG_cong  = pop_eegthresh(EEG_cong, 1, chansToInclude, -100 ,100, -.2,1, 1, 0); % transpose chansToInclude to make it an array
                pcTrialRej_cong = round((sum(EEG_cong.reject.rejthresh)/length(EEG_cong.reject.rejthresh))*100);
            else
                EEG_incong  = pop_eegthresh(EEG_incong, 1, chansToInclude, -100 ,100, -.2,1, 1, 0);
                pcTrialRej_incong = round((sum(EEG_incong.reject.rejthresh)/length(EEG_incong.reject.rejthresh))*100);
            end
        end






        ALL_ERP_cong(iSub,iCond,:,:) = squeeze(mean(EEG_cong.data,3));
        ALL_ERP_incong(iSub,iCond,:,:) = squeeze(mean(EEG_incong.data,3));

    end
end

chanlocs = EEG.chanlocs;
times = EEG.times;

save([destDir '/' 'ERP_MASTER.mat'],'ALL_ERP_incong','ALL_ERP_cong','subjects','chanlocs','times')