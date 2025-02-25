%{
EEG_Compile_Bad_Channel_Info
Author: Tom Bullock
Date: 01.14.25
Purpose: plot N400 ERP waveforms and topographic plots

NOTE FC2 for SJ09 MWA is BAD

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
subjects = 3:26
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
        load([sourceDir '/' filename ],'bad_channel_list')

        % create mat for bad channels
        allBadChans(iSub,iCond) = size(bad_channel_list,2);

    end
end

mean_bad_chans = mean(mean(allBadChans,1),2);
std_bad_chans = mean(std(allBadChans));

save([destDir '/' 'Bad_Trials_Master.mat'],'allBadChans','mean_bad_chans','std_bad_chans')
