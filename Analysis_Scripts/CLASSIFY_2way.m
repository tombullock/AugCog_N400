function CLASSIFY_2way(thisFilename,permuteLabels,theseChans,saveSuffix)
%=======================================================================
% function: wtf_class
% purpose:  classify spatial position in working memory tuning function
%           experiment.
% inputs:   dataFile with data to be classified. assumes it contains eegs
%               (data, ntrials x nelecs x ntime) for all trials
%           permuteLabels boolean to run a version with class labels shuffled
%               classifier or not
%           timeStep if >1, will step through time in nonoverlapping
%               windows
%           theseElecs index for desired electrodes (e.g., 1:nElecs)
%           saveSuffx appended suffix to output file
% outputs:  mat file for each file analyzed that includes the classifier
%               accuracy
%
% author:   barry giesbrecht (edits by Tom)
% date:     4/1/2019
%========================================================================
% 



% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/EEG_Prepro1'];
destDir = [rDir '/Classify'];

%load the data
load([sourceDir '/' thisFilename]);


% re-ref to mastoids [online ref chan removed hence chan index changed]
EEG = pop_reref(EEG,[9,20],'keepref','on');

% remove eyeblinks
EEG = pop_crls_regression( EEG, [1, 31], 1, 0.9999, 0.01,[]);   % remove eye-blinks using AAR toolbox

% remove eyeblink channels
EEG = pop_select(EEG,'nochannel',{'Fp1','Fp2'});

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




% select electrodes
%%load([d(1).folder '/' d(1).name]) % grab chanlocs from one of the files
chanlocs = EEG.chanlocs;
%theseChanLabels = {'CPz','CP3','CP4','C3','Cz','C4','FC3','FCz','FC4','C1','Cz','C2','FC1','FC2','CP1','CP2'};
theseChanLabels = {'AFz','AF3','AF4','F1','Fz','F2','FC1','FC2','C1','Cz','C2'};
cnt=0; theseChans=[];
for iChan=1:length(chanlocs)
    if ismember(chanlocs(iChan).labels,theseChanLabels)
        cnt=cnt+1;
        theseChans(cnt) = iChan;
    end
end



trialLocs = [repmat(1,[1,length(EEG_cong.epoch)]),repmat(2,[1,length(EEG_incong.epoch)])];
dat = cat(3,EEG_cong.data,EEG_incong.data);




%convert to power
%eegPower = abs(spectra).^2;

%each matfile has an eegInfo struct, eegs matrix, and a minCnt scalar
%eegInfo has chanLabels, preTime, postTime (stim), sampRate, posBin
%(condition)
%eegs is a trial x electrode x time matrix
%minCnt is the minimum number of trials in a condition


% %the epoch goes out to 2.5 s, but to avoid edge artifacts and to match 
% %IEM generalization only go out to 2s. in this case that's
% %timepoint 640.
% blah(:,:,:)=eegs(:,:,1:640);
% eegs=blah;
% clear blah;

% isolate 30 Hz data
% freqIdx = find(myFreqs==30);
% eegPower = eegPower(:,:,freqIdx);

nTrials=size(dat,3);

%nTpts=size(eegs,3);

%accData = zeros(nTpts/timeStep,1);

%timeStepCtr=1;



% iterate [important for perm - will be important for real when we start
% kickng out trials]
for iIterate=1:5
    
    if permuteLabels
        for i=1:7
            %eegInfo.posBin=eegInfo.posBin(randperm(size(eegInfo.posBin,1)));
            trialLocs = trialLocs(randperm(size(trialLocs,2)));
        end
    end
    
    %for iTpt=1
    
    %thisData(:,:)=squeeze(mean(eegPower(:,theseElecs,iTpt),3)); %average over time
    
    %theseElects = [16:18, 47:49];
    thisData = dat(theseChans,:,:); % USE ALL ELECTRODES FOR NOW (UNLESS PROBLEM)
    
    
    
    for iTime=1:size(thisData,2)
        
        iTime
        
        correctTrials=0;
        
        for iTrial = 1:nTrials
            
            
            
            testData = squeeze(thisData(:,iTime,iTrial));
            testMember = trialLocs(iTrial);
            trainIdx = setdiff(1:nTrials,iTrial);
            trainData = squeeze(thisData(:,iTime,trainIdx));
            trainMember = trialLocs(trainIdx);
            p=repmat(1/2,1,2); %force a uniform prior, to ensure that the classifier doesn't just merely use class frequency
            %                   to determine the descriminant function. i.e.,
            %
            
            % vanilla matlab classifier. the 'lin' flag specifies a linear
            % classifier that fits a multivariate normal density to each group,
            % with a pooled estimate of covariance. see lines 223-237 in
            % classify.m. then the label for any given trial is determined by
            % the density function that is closest to the test trial.
            
            Labels=classify(testData',trainData',trainMember,'lin',p);
            
            
            if length(Labels)==1
                if Labels==testMember
                    correctTrials=correctTrials+1;
                end
            else
                correctTrials=correctTrials+length(find(Labels==testMember));
            end
            
        end
        
        accData(iIterate,iTime) =correctTrials/nTrials;
        
    end
    
end


save([destDir '/' thisFilename(1:8) '_Classify_' saveSuffix '.mat'],'accData','theseChans');

return



