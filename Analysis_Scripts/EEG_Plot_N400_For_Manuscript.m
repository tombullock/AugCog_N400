%{
EEG_Plot_N400
Author: Tom Bullock
Date: 03.13.24
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

% loop through conditions
for iCond = 1:4

    if iCond==1; thisCond = 'MWA';
    elseif iCond==2; thisCond = 'MWL';
    elseif iCond==3; thisCond = 'WWA';
    elseif iCond==4; thisCond = 'WWL';
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

    % REMOVE BAD SUBJECTS!!! [1&2 have noisy baselines]
    badSubjects = 1:2;

    cong_data(badSubjects,:,:,:) = [];
    incong_data(badSubjects,:,:,:) = [];

    % create difference wave
    diff_data = incong_data - cong_data;

    times = -200:4:996; % overwrite times from file coz this is wrong



    % create figure
    %h=figure('Units','normalized','OuterPosition',[0.3, 0, 0.53, 0.97]);
    h=figure('OuterPosition',[1440         927         560         390]);

    % set up subplot axes
    %subplot(2,3,1:3) % spans across top row

    for iPlot=1:3

        if iPlot==1
            theseData = cong_data;
            thisColor = [.8,.8,.8];%'g'; % blue
        elseif iPlot==2
            theseData = incong_data;
            thisColor = [0,0,0];%'k'; % red
        elseif iPlot==3
            theseData = diff_data;
            thisColor = 'r'; % black
        end

        mean_data = squeeze(mean(mean(theseData(:,theseChans,:),1),2));
        sem_data = std(squeeze(mean(theseData(:,theseChans,:),2)),0,1)./sqrt(size(theseData,1));
        plot1(iPlot) = shadedErrorBar(times,mean_data,sem_data,{'color',thisColor,'Linewidth',3},1); hold on
        
        % plot(times,mean_data,...
        %     'color',thisColor,...
        %     'LineWidth',3); hold on

        %shadedErrorBar(times,mean_data,sem_data,{'color',thisColor,'Linewidth',3},1); hold on

    end

    set(gca,'FontSize',20,'box','off','ylim',[-7,6],'linewidth',1.5)

    xline(0,'LineStyle',':','LineWidth',1.5,'Color','k')
    yline(0,'LineStyle',':','LineWidth',1.5,'Color','k')

    xlabel('Time (ms)')
    ylabel('Amplitude (uV)')

    %title(thisCond,'FontSize',16)

    pbaspect([2,1,1])

    %legend('Congruent','Incongruent')
    





    % run and plot stats
    for iTime = 1:size(cong_data,3)
        d = [squeeze(mean(cong_data(:,theseChans,iTime),2)),squeeze(mean(incong_data(:,theseChans,iTime),2))];
        h_sig(iTime) = ttest(d(:,1),d(:,2));
    end

    for iTime=1:length(times)
        if h_sig(iTime)==1
            line([times(iTime),times(iTime+1)],[-6.4,-6.4],'linewidth',10)
        end
    end

    legend([plot1(1).mainLine,plot1(2).mainLine,plot1(3).mainLine],'Cong.','Incong.','Diff.','Location','northeast','fontsize',14,'box','off')

    saveas(h,[destDir '/ERP_Waveforms_' thisCond  '.eps'],'epsc')
    saveas(h,[destDir '/ERP_Waveforms_' thisCond  '.png'],'png')


    close

    %% plot topographic maps

    % isolate channel locations data
    %chanlocs = EEG.chanlocs;

    % % for now, remove Fp1 and Fp2 from topo plots (blinks still present in
    % % these channels and this throws off the heatmap limits)
    % cong_data([1,31],:,:) = [];
    % incong_data([1,31],:,:) = [];
    % all_data([1,31],:,:) = [];
    % chanlocs([1,31]) = [];

    theseTimes = [200,600]; % THIS WAS SET TO [400,600]
   
    theseMapLimits = [-5,5]; % THIS WAS SET TO [-6,6]
    %theseMapLimits = 'maxmin';

    

    


    for iPlot=1:3

        %subplot(2,3,iPlot+3) % plots to bottom row
        h=figure;

        if iPlot==1
            topo_data = mean(mean(cong_data(:,:,find(theseTimes(1)==times):find(theseTimes(2)==times)),1),3);
            congIncong = 'Congruent';
        elseif iPlot==2
            topo_data = mean(mean(incong_data(:,:,find(theseTimes(1)==times):find(theseTimes(2)==times)),1),3);
            congIncong = 'Incongruent';
        elseif iPlot==3
            topo_data = mean(mean(diff_data(:,:,find(theseTimes(1)==times):find(theseTimes(2)==times)),1),3);
            congIncong = 'Difference';
        end

        %title([congIncong ' [' num2str(theseTimes(1)), '-' num2str(theseTimes(2)) ' ms]'],'FontSize',14)
        topoplot(topo_data,...
            chanlocs,...
            'maplimits',theseMapLimits,...
            'emarker2',{theseChans,'o','w'});
        %cbar

        saveas(h,[destDir '/TOPO_' thisCond '_' congIncong  '.eps'],'epsc')
        close

    end

    %saveas(h,[destDir '/ERPs_' thisCond '_Grand_Avg_With_Diff_Wave.png'],'png')
    %saveas(h,[destDir '/ERPs_' thisCond '_Grand_Avg.png'],'png')

end

