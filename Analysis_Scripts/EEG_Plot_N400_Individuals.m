%{
EEG_Plot_N400
Author: Tom Bullock
Date: 08.21.23
Purpose: plot N400 ERP waveforms and topographic plots

NOTE FC2 for SJ09 MWA is BAD

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/EEG_Prepro1'];
destDir = [rDir '/Plots/Individual'];
destDirPrepro2 = [rDir '/EEG_Prepro2'];
destDirTrialRejThreshold = [rDir '/Trial_Rej_Treshold_Stats'];

% % % add EEGLAB to path and load GUI [only need run when first open matlab]
% cd([rDir '/eeglab14_1_2b'])
% eeglab
% cd(rDir)
% close

% which subject's to process?
subjects = 13:26;%1:12;%1:12;

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

        % also create an epoched EEG struct for all stimuli combined
        EEG_all = pop_epoch(EEGO,{101,102},[-.2,1]);
        EEG_all = pop_rmbase(EEG_all,[-100,0]);



        % SET CHANNELS FOR THRESHOLD REJECTION AND PLOTTING

        %theseChanLabels = {'AFz','AF3','AF4','F1','Fz','F2','FC1','FC2','C1','Cz','C2'};
        %theseChanLabels = {'CPz','CP1','CP2','C1','Cz','C2'}; %'C1','Cz','C2', ,'Pz','P1','P2'
        theseChanLabels = {'CPz','CP3','CP4','C3','Cz','C4','FC3','FCz','FC4'}; %'C1','Cz','C2', ,'Pz','P1','P2'
        %theseChanLabels = {'Oz','POz','PO3','PO4','O1','O2'};









        % run threshold rejection

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

        % save thresthold rej trial data
        save([destDirTrialRejThreshold '/' sprintf('sj%02d_%s_TrialRejStats.mat',sjNum,thisCond)],'pcTrialRej_cong','pcTrialRej_incong')

        % interim save step for classifier stuff
        save([destDirPrepro2 '/' sprintf('sj%02d_%s_EEG_Prepro2.mat',sjNum,thisCond)],'EEG_all','-v7.3')




        %% plot ERPs



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

        title(thisCond,'FontSize',16)

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

        theseTimes = [400,600]; % 400-500 ms is roughly where the peak of the P3 would be expected, but this can be adjusted
        %theseTimes = [100,152];
        theseMapLimits = [-6,6]; % set these based on ERPs
        %theseMapLimits = 'maxmin';

        if sjNum==6
            theseMapLimits = [-15,0];
        elseif sjNum==7
            theseMapLimits = [-10,10];
        end



        for iPlot=1:2

            subplot(2,2,iPlot+2) % plots to bottom row

            if iPlot==1
                topo_data = mean(mean(cong_data(:,find(theseTimes(1)==times):find(theseTimes(2)==times),:),2),3);
                congIncong = 'Congruent';
            elseif iPlot==2
                topo_data = mean(mean(incong_data(:,find(theseTimes(1)==times):find(theseTimes(2)==times),:),2),3);
                congIncong = 'Incongruent';
                %     elseif iPlot==3
                %         topo_data = mean(mean(all_data(:,find(theseTimes(1)==times):find(theseTimes(2)==times),:),2),3);
                %         thisTitle = 'All Stimuli';
            end

            title([congIncong ' [' num2str(theseTimes(1)), '-' num2str(theseTimes(2)) ' ms]'],'FontSize',14)
            topoplot(topo_data,...
                chanlocs,...
                'maplimits',theseMapLimits,...
                'emarker2',{theseChans,'o','w'});
            cbar

        end

        saveas(h,[destDir '/sj' num2str(sjNum) '_' thisCond '_ERPs_and_topos.png'],'png')

        close

    end
end

