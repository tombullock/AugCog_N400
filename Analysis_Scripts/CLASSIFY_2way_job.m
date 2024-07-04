%{
CLASSIFY_6way_job
Author: Tom Bullock
Date: 03.12.24


%}

clear 
close all

scriptsDir = '/Users/tombullock/Documents/Psychology/AugCog/N400/Analysis_Scripts';

cd(scriptsDir)

% serial or parallel
runInParallel=0; % 0=no,1=yes

if runInParallel
    s = parcluster();
    %s.ResourceTemplate = '--ntasks-per-node=6 --mem=65536';
    job = createJob(s);
end

% cd to spectra folder
cd '/Users/tombullock/Documents/Psychology/AugCog/N400/EEG_Prepro1/'
d = dir('*.mat');
cd(scriptsDir)

% % select electrodes
% load([d(1).folder '/' d(1).name]) % grab chanlocs from one of the files
% chanlocs = EEG.chanlocs;
% theseChanLabels = {'CPz','CP3','CP4','C3','Cz','C4','FC3','FCz','FC4','C1','Cz','C2','FC1','FC2','CP1','CP2'};
% %theseChanLabels = {'AFz','AF3','AF4','F1','Fz','F2','FC1','FC2','C1','Cz','C2'};
% cnt=0; theseChans=[];
% for iChan=1:length(chanlocs)
%     if ismember(chanlocs(iChan).labels,theseChanLabels)
%         cnt=cnt+1;
%         theseChans(cnt) = iChan;
%     end
% end
theseChans = [];

saveSuffix1 = 'realAcc';
saveSuffix2 = 'permAcc';

% loop through files
for iFile =1:length(d)
    thisFilename = d(iFile).name;
    disp(['Processing ' thisFilename])
    if runInParallel
        permuteLabels=0;
        job.createTask(@CLASSIFY_2way,0,{thisFilename,permuteLabels,theseChans,saveSuffix1})
        permuteLabels=1;
        job.createTask(@CLASSIFY_2way,0,{thisFilename,permuteLabels,theseChans,saveSuffix2})
    else
        permuteLabels=0;
        CLASSIFY_2way(thisFilename,permuteLabels,theseChans,saveSuffix1)
        %job.createTask(@wtf_class,0,{thisFilename,permuteLabels,theseElecs,saveSuffix1})
        permuteLabels=1;
        CLASSIFY_2way(thisFilename,permuteLabels,theseChans,saveSuffix2)
        %job.createTask(@wtf_class,0,{thisFilename,permuteLabels,theseElecs,saveSuffix2})
    end
end

if runInParallel
    submit(job)
end
