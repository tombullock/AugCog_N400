%{
EEG_Plot_N400
Author: Tom Bullock
Date: 08.21.23
Purpose: plot N400 ERP waveforms and topographic plots

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/EEG_Prepro1'];
destDir = [rDir '/Plots'];

% % % add EEGLAB to path and load GUI [only need run when first open matlab]
% cd([rDir '/eeglab14_1_2b'])
% eeglab
% cd(rDir)
% close

% set file to process [will automate to do multiple subjects later]

session=1;
if session==1
    filename = 'N400_sj81_MWA';
    thisTitle = 'MWA';
elseif session==2
    filename = 'N400_sj81_WWA';
    thisTitle = 'WWA';
elseif session==3
    % filename = 'N400_Test3';
    % thisTitle = 'N400 Test3';
end

disp(['Processing: ' filename ' !!'])
pause(3);

% load prepro1 EEG data
load([sourceDir '/' filename '_EEG_Prepro1.mat' ])

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

% also create an epoched EEG struct for all stimuli combined
EEG_all = pop_epoch(EEGO,{101,102},[-.2,1]);
EEG_all = pop_rmbase(EEG_all,[-200,0]);


%% plot ERPs

%theseChans = [12,43,51,47,52]; % cluster of electrodes centered around Pz
%theseChans = [31,32,59,33,60,5,27]%[11,22,50]%;%[6,28,39,56,23,11,22,52]; % cluster of electrodes centered around Cz

%theseChanLabels = {'AFz','AF3','AF4','F1','Fz','F2','FC1','FC2','C1','Cz','C2'};
%theseChanLabels = {'C1','Cz','C2','CPz','CP1','CP2'};
theseChanLabels = {'Oz','POz','PO3','PO4','O1','O2'};

cnt=0; theseChans=[];
for iChan=1:length(EEG.chanlocs)
    if ismember(EEG.chanlocs(iChan).labels,theseChanLabels)
        cnt=cnt+1;
        theseChans(cnt) = iChan;
    end
end


cong_data = EEG_cong.data;
incong_data = EEG_incong.data;
all_data = EEG_all.data;

times = EEG_cong.times;

% create figure
h=figure('Units','normalized','OuterPosition',[0.3, 0, 0.53, 0.97]);

% set up subplot axes
subplot(2,2,1:2) % spans across top row

for iPlot=1:2

    if iPlot==1
        theseData = cong_data;
        thisColor = [.8,.8,.8];%'g'; % blue
    elseif iPlot==2
        theseData = incong_data;
        thisColor = [0,0,0];%'k'; % red
%     elseif iPlot==3
%         theseData = all_data;
%         thisColor = 'k'; % black
    end

    plot(times,squeeze(mean(mean(theseData(theseChans,:,:),1),3)),...
        'color',thisColor,...
        'LineWidth',3); hold on

end

set(gca,'FontSize',16,'box','off')

xline(0,'LineStyle',':','LineWidth',1.5,'Color','k')
yline(0,'LineStyle',':','LineWidth',1.5,'Color','k')

xlabel('Time (ms)')
ylabel('Amplitude (uV)')

title(thisTitle,'FontSize',16)

pbaspect([2,1,1])

legend('Congruent','Incongruent')

%saveas(h,[destDir '/' filename '_ERPs.png'],'png')



%% plot topographic maps

% isolate channel locations data
chanlocs = EEG.chanlocs;

% % for now, remove Fp1 and Fp2 from topo plots (blinks still present in
% % these channels and this throws off the heatmap limits)
% cong_data([1,31],:,:) = [];
% incong_data([1,31],:,:) = [];
% all_data([1,31],:,:) = [];
% chanlocs([1,31]) = [];

%theseTimes = [400,600]; % 400-500 ms is roughly where the peak of the P3 would be expected, but this can be adjusted
theseTimes = [100,152];
%theseMapLimits = [-6,6]; % set these based on ERPs
theseMapLimits = [0,2];



for iPlot=1:2

    subplot(2,2,iPlot+2) % plots to bottom row

    if iPlot==1
        topo_data = mean(mean(cong_data(:,find(theseTimes(1)==times):find(theseTimes(2)==times),:),2),3);
        thisTitle = 'Congruent';
    elseif iPlot==2
        topo_data = mean(mean(incong_data(:,find(theseTimes(1)==times):find(theseTimes(2)==times),:),2),3);
        thisTitle = 'Incongruent';
%     elseif iPlot==3
%         topo_data = mean(mean(all_data(:,find(theseTimes(1)==times):find(theseTimes(2)==times),:),2),3);
%         thisTitle = 'All Stimuli';
    end
    
    title([thisTitle ' [' num2str(theseTimes(1)), '-' num2str(theseTimes(2)) ' ms]'],'FontSize',14)
    topoplot(topo_data,...
        chanlocs,...
        'maplimits',theseMapLimits,...
        'emarker2',{theseChans,'o','w'});
    cbar

end

saveas(h,[destDir '/' filename 'ERPs_and_topos.png'],'png')

