%{
EEG_Plot_N400_diff_waves_together_for_manuscript
Author: Tom Bullock
Date: 11.03.24
Purpose: plot N400 ERP waveforms and topographic plots

Remember sj13 is non-native speaker...

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/Data_Compiled'];
destDir = [rDir '/Plots/Grouped'];

% % add EEGLAB to path and load GUI [only need run when first open matlab]
cd([rDir '/eeglab14_1_2b'])
eeglab
cd(rDir)
close

% load data
load([sourceDir '/' 'ERP_MASTER.mat' ])

% set up fig
h=figure('OuterPosition',[1440         927         560         390]);

% loop through conditions
for iCond = 1:4

    if iCond==1; thisCond = 'MWA'; thisColor = '#186d9e';
    elseif iCond==2; thisCond = 'MWL'; thisColor = '#c8952c';
    elseif iCond==3; thisCond = 'WWA'; thisColor = '#088b6b';
    elseif iCond==4; thisCond = 'WWL'; thisColor = '#c283a6';
    end

    %theseChanLabels = {'AFz','AF3','AF4','F1','Fz','F2','FC1','FC2','C1','Cz','C2'};
    %theseChanLabels = {'CPz','CP3','CP4','C3','Cz','C4','FC3','FCz','FC4','C1','Cz','C2','FC1','FC2','CP1','CP2'}; %'C1','Cz','C2', ,'Pz','P1','P2'
    theseChanLabels = {'CPz','CP3','CP4','C3','Cz','C4','FC3','FCz','FC4','F3','Fz','F4'}; %'C1','Cz','C2', ,'Pz','P1','P2'
    %theseChanLabels = {'Oz','POz','PO3','PO4','O1','O2'};
    %theseChanLabels = {'Pz','P1','P2','P3','P4'};;
    %theseChanLabels = {'Oz','O1','O2'};

    cnt=0; theseChans=[];
    for iChan=1:length(chanlocs)
        if ismember(chanlocs(iChan).labels,theseChanLabels)
            cnt=cnt+1;
            theseChans(cnt) = iChan;
        end
    end

    cong_data = squeeze(ALL_ERP_cong(:,iCond,:,:));
    incong_data = squeeze(ALL_ERP_incong(:,iCond,:,:));

    % remove bad subs [1&2 have noisy baselines]
    badSubjects = 1:2;
    cong_data(badSubjects,:,:,:) = [];
    incong_data(badSubjects,:,:,:) = [];

    % create difference wave
    diff_data = incong_data - cong_data ;
    times = -200:4:996; % overwrite times from file coz this is wrong

    

    theseData = diff_data;
    mean_data = squeeze(mean(mean(theseData(:,theseChans,:),1),2));
    sem_data = std(squeeze(mean(theseData(:,theseChans,:),2)),0,1)./sqrt(size(theseData,1));


    plot1(iCond) = shadedErrorBar(times,mean_data,sem_data,{'color',thisColor,'Linewidth',3},1); hold on


    [~,peak_lat] = min(squeeze(mean(theseData(:,theseChans,:),2)),[],2);
    peak_lat_all(:,iCond) = times(peak_lat);

    theseDataAll(iCond,:,:) = squeeze(mean(diff_data(:,theseChans,:),2));




end

set(gca,'FontSize',20,'box','off','ylim',[-8,4],'linewidth',1.5)
xline(0,'LineStyle',':','LineWidth',1.5,'Color','k')
yline(0,'LineStyle',':','LineWidth',1.5,'Color','k')
xlabel('Time (ms)')
ylabel('Amplitude (uV)')
pbaspect([1.5,1,1])



% DO STATS COMPARING DIFF WAVES TO ZERO

% run and plot stats
for iCond = 1:4 % maintaining order
    for iTime = 1:size(theseDataAll,3)
        d = theseDataAll(iCond,:,iTime);
        H = ttest(d);
        diffWaveStats(iCond,iTime) = H;
    end
end

sigLinePosMat = [-2.5,-3,-3.5,-4]+6;
for iCond=[1,3,2,4] % re-ordering position to MWA,WWA,MWL,WWL

    if iCond==1; thisCond = 'MWA'; thisColor = '#186d9e';
    elseif iCond==2; thisCond = 'MWL'; thisColor = '#c8952c';
    elseif iCond==3; thisCond = 'WWA'; thisColor = '#088b6b';
    elseif iCond==4; thisCond = 'WWL'; thisColor = '#c283a6';
    end

    for iTime = 1:length(times)
        d=diffWaveStats(iCond,iTime);
        if d==1
            line([times(iTime),times(iTime+1)],[sigLinePosMat(iCond),sigLinePosMat(iCond)],'linewidth',7,'color',thisColor)
        end
    end

end

% remember to re-order stats

legend([plot1(1).mainLine,plot1(3).mainLine,plot1(2).mainLine,plot1(4).mainLine],'MWA','WWA','MWL','WWL','Location','southeast','fontsize',14,'box','off')
saveas(h,[destDir '/ERP_Diff_Waves.eps'],'epsc')
saveas(h,[destDir '/ERP_Diff_Waves.png'],'png')


% for iTime=1:length(times)
%     if h_sig(iTime)==1
%         line([times(iTime),times(iTime+1)],[-4.4,-4.4],'linewidth',10)
%     end
% end



% GET PEAK LAT FOR DIFF WAVES

% replace any crazy peak lat values with NaNs
for i=1:size(peak_lat_all,2)
    for j=1:size(peak_lat_all,1)
        if peak_lat_all(j,i) <200 || peak_lat_all(j,i) > 800
            peak_lat_all(j,i) = NaN;
        end
    end
end

% find condition peak lat means
m = nanmean(peak_lat_all,1);

% replace
for iCond=1:4
    peak_lat_all(isnan(peak_lat_all(:,iCond)),iCond) = m(iCond);
end
%%peak_lat_all = peak_lat_all';

% GET MEAN AMP FOR DIFF WAVES
for iCond=1:4
    thisPeakLat = m(iCond);
    [val,thisPeakLatIdx] = min(abs(times-thisPeakLat));
    mean_amp_all(iCond,:) = squeeze(mean(theseDataAll(iCond,:,thisPeakLatIdx-5:thisPeakLatIdx+4),3));    
end

mean_amp_all = mean_amp_all';

% get rid of bad subs
subjects(badSubjects) = [];


save([sourceDir '/' 'ERP_AMP_LAT.mat'],'peak_lat_all','mean_amp_all','subjects')