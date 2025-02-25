%{
EEG_Threshold_Rej_Stats
Author: Tom Bullock
Date: 02.04.25

Get stats on threshold based trial rej

%}

clear
close all

rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/Trial_Rej_Treshold_Stats' ];
destDir = [rDir '/Data_Compiled'];

subjects = 3:26;

for iSub=1:length(subjects)

    sjNum = subjects(iSub);

    for iCond=1:4

        if iCond==1; thisCond = 'MWA';
        elseif iCond==2; thisCond = 'MWL';
        elseif iCond==3; thisCond = 'WWA';
        elseif iCond==4; thisCond = 'WWL';
        end
        
        load([sourceDir '/' sprintf('sj%02d_%s_TrialRejStats.mat',sjNum,thisCond)])        

        trialRejMat(iSub,iCond) = mean([pcTrialRej_incong,pcTrialRej_cong]);

    end

end

trialRejMeans = mean(trialRejMat,1)

