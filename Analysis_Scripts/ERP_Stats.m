%{
BEH_Stats_RT
Author: Tom Bullock
Date: 11.10.24

Run stats on behavioral data

%}

clear
close all

% seed rng
rng('shuffle')

% set dirs
sourceDir = '/Users/tombullock/Documents/Psychology/AugCog/N400/Data_Compiled';
destDir = sourceDir;

% add stats to path
addpath(genpath('/Users/tombullock/Documents/MATLAB/ML_TOOLBOXES/resampling'))

% load data
load([sourceDir '/' 'ERP_AMP_LAT.mat'])

% loop through different datasets and run analyses
for iData=1:2
    
    % which data?
    if iData==1
        observedData = mean_amp_all;
    elseif iData==2
        observedData = peak_lat_all;
    end
    
    % % organize data for stats analysis
    % observedData = [...
    %     theseData(:,:,1),...
    %     theseData(:,:,2),...
    %     theseData(:,:,3),...
    %     theseData(:,:,4),...
    %     theseData(:,:,5)
    %     ];
    
    % name variables
    var1_name = 'Model_Word';
    var1_levels = 2;
    var2_name = 'Assoc_Label';
    var2_levels = 2;
    
    % generate resampled iterations for ANOVA/t-tests
    for j=1:1000
        
        for i=1:size(observedData,1)    % for each row of the observed data
            thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
            for k=1:length(thisPerm)
                nullDataMat(i,k,j) = observedData(i,thisPerm(k));
            end
        end
        
        % do ANOVA on permuted data for each new iteration
        statOutput = teg_repeated_measures_ANOVA(nullDataMat(:,:,j),[var1_levels var2_levels],{var1_name, var2_name});  % run ANOVA
        var1.fValsNull(j,1) = statOutput(1,1);   % create column vectors of null F-values
        var2.fValsNull(j,1) = statOutput(2,1);
        varInt.fValsNull(j,1) = statOutput(3,1);
        
        clear statOutput
        
        % get post-hoc null t value distribution (only makes sense to create
        % one null distribution for all combinations of tests, given within
        % subjects column shuffling method)
        [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j));
        tValsNull(j,1) = STATS.tstat;
        clear STATS
        
    end
    
    % run ANOVA on observed data
    statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
    % get fvalues
    var1.fValObserved = statOutput(1,1);
    var2.fValObserved = statOutput(2,1);
    varInt.fValObserved = statOutput(3,1);
    % get effect sizes
    var1.partialEtaSq = statOutput(1,7);
    var2.partialEtaSq = statOutput(2,7);
    varInt.partialEtaSq = statOutput(3,7);
    % get dfs
    var1.df = statOutput(1,[2,3]);
    var2.df = statOutput(2,[2,3]);
    varInt.df = statOutput(3,[2,3]);
    % get p-values (non-resampled)
    var1.pVal_non_resampled = statOutput(1,4);
    var2.pVal_non_resampled = statOutput(2,4);
    varInt.pVal_non_resampled = statOutput(3,4);
    
    clear statOutput
    
    % sort null f-values, get index value and convert to percentile (VAR_1)
    var1.NAME = var1_name;
    var1.LEVELS = var1_levels;
    var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
    [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
    var1.fValueIndex = var1.fValueIndex/1000;
    var1.pValueANOVA = var1.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var2.NAME = var2_name;
    var2.LEVELS = var2_levels;
    var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
    [c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved));
    var2.fValueIndex = var2.fValueIndex/1000;
    var2.pValueANOVA = var2.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR INTER)
    varInt.NAME = 'INTERACTION';
    varInt.LEVELS = [num2str(var1_levels) '-by-' num2str(var2_levels)];
    varInt.fValsNull = sort(varInt.fValsNull(:,1),1,'descend');
    [c varInt.fValueIndex] = min(abs(varInt.fValsNull - varInt.fValObserved));
    varInt.fValueIndex = varInt.fValueIndex/1000;
    varInt.pValueANOVA = varInt.fValueIndex;
    
    
    
    
    clear cohens_d
    
    % run select pairwise comparisions
    
    
    % do t-tests on observed data
    for iTest=1:4
        
        % within session
        if      iTest==1; thisPair=[1,2];
        elseif  iTest==2; thisPair=[3,4]; 
        elseif  iTest==3; thisPair=[1,3]; 
        elseif  iTest==4; thisPair=[2,4];          
        end
        
        [H,P,CI,STATS] = ttest(observedData(:,thisPair(1)),observedData(:,thisPair(2)));
        tValsObs(1,iTest) = STATS.tstat;
        cohens_d(iTest)=computeCohen_d(observedData(:,thisPair(1)),observedData(:,thisPair(2)),'paired');
        
        % compute dfs
        tValsObs(2,iTest) = STATS.df;
        clear STATS

    end
    
    % sort null t-values, get index value and convert to percentile
    tValsNull = sort(tValsNull(:,1),1,'descend');
    
    % compare observed t values with the distribution of null t values
    [c tValueIndex(1)] = min(abs(tValsNull - tValsObs(1,1)));
    [c tValueIndex(2)] = min(abs(tValsNull - tValsObs(1,2)));
    [c tValueIndex(3)] = min(abs(tValsNull - tValsObs(1,3)));
    [c tValueIndex(4)] = min(abs(tValsNull - tValsObs(1,4)));
    
    % convert to percentiles
    tValueIndex = tValueIndex./1000;
    pValuesPairwise = tValueIndex;
    
    % add pnull values to tValsObs for easy viewing
    tValsObs(3,:) = pValuesPairwise;
    
    % critical t score
    tmpA = tValsNull(25);
    tmpB = tValsNull(975);
    
    if tmpA<0
        tCriticalNeg = tmpA;
        tCriticalPos = tmpB;
    else
        tCriticalNeg = tmpB;
        tCriticalPos = tmpA;
    end
    
    
    % compare critical t score to distribution and present 0 (ns) or 1(sig)
    % values in output
    for i=1:4
        if tValsObs(1,i)<0 && tValsObs(1,i)<tCriticalNeg
            tValsObs(4,i)=1;
        elseif tValsObs(1,i)>0 && tValsObs(1,i)>tCriticalPos
            tValsObs(4,i)=1;
        else
            tValsObs(4,i)=0;
        end
    end
    
    % add cohens d effect sizes into tValsObs matrix
    tValsObs(5,:) = cohens_d;
    
    
    % save data
    if iData==1
        AMPLITUDE.ANOVA.var1 = var1;
        AMPLITUDE.ANOVA.var2 = var2;
        AMPLITUDE.ANOVA.varInt = varInt;
        AMPLITUDE.Pairwise.t = tValsObs;
    elseif iData==2
        PEAK_LAT.ANOVA.var1 = var1;
        PEAK_LAT.ANOVA.var2 = var2;
        PEAK_LAT.ANOVA.varInt = varInt;
        PEAK_LAT.Pairwise.t = tValsObs;
    end
    
    clear nullDataMat observedData pValuesPairwise thisPerm tValsNull tValsObs tValueIndex var1 var2 varInt cohens_d
    
end


% save important stats info
save([destDir '/' 'ERP_AMP_LAT_STATS.mat'],'PEAK_LAT','AMPLITUDE');