%{
CLASSIFY_Plot
%}

clear
close all

% which data to plot:
nChans = '16ch'; 

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/' 'Classify'];
destDir = [rDir '/Plots/Grouped' ];

% set subs
subjects = 1:12; % kick out a few troublesome sjs for now

% compile
for iSub=1:length(subjects)
    sjNum = subjects(iSub);
    for iCond=1:4

        if iCond==1
            condLabel = 'MWA';
        elseif iCond==2
            condLabel = 'MWL';
        elseif iCond==3
            condLabel = 'WWA';
        elseif iCond==4
            condLabel = 'WWL';
        end
           
        load([sourceDir '/' sprintf('sj%02d_%s_Classify_realAcc.mat',sjNum,condLabel)])
        allAccReal(iSub,iCond,:) = mean(accData,1);
        load([sourceDir '/' sprintf('sj%02d_%s_Classify_permAcc.mat',sjNum,condLabel)])
        allAccPerm(iSub,iCond,:) = mean(accData,1);  
    end
end

% run quick rVp stats
for iTime=1:length(allAccReal)
    [~,p] = ttest(allAccReal(:,:,iTime),allAccPerm(:,:,iTime));
    pVals(iTime,:) = p;
end

%%load behavior data for RT lines
%%load([rDir '/Data_Compiled/' 'BEH_Master.mat'])

times = -200:4:996;

% plot acc
h=figure('units','normalized','OuterPosition',[0.418023255813953          0.62024407753051         0.491569767441861         0.359655419956928]);
for iRealPerm = 1:2
    
    if iRealPerm == 1
        thisLineStyle = '-';
        thisLineWidth = 3;
        theseData = allAccReal;
    else
        thisLineStyle = '-';
        thisLineWidth = 1;
        theseData = allAccPerm;
    end
    
    for iCond=1:4
        
        if iCond==1
            thisColor = 'r';
            subplot(1,2,1);
            thisStatYpos = .4;
        elseif iCond==2
            thisColor = 'b';
            subplot(1,2,1)
            thisStatYpos = .38;
        elseif iCond==3
            thisColor = 'r';
            subplot(1,2,2)
            thisStatYpos = .4;
        elseif iCond==4
            thisColor = 'b';
            subplot(1,2,2)
            thisStatYpos = .38;
        end

        thisLabel = condLabel;

        
        
        d_mean = squeeze(mean(theseData(:,iCond,:),1));
        
        plt(iRealPerm,iCond) =  plot(times,d_mean,...
            'color',thisColor,...
            'linewidth',3,...
            'linestyle',thisLineStyle,...
            'linewidth',thisLineWidth); hold on
        
        thisXlim = [-200,1000];
        thisYlim = [.35,.68];
        set(gca,'box','off','xlim',thisXlim,'ylim',thisYlim,'Fontsize',18,'linewidth',1.5)
        xlabel('Time (ms)')
        ylabel('Classifier Accuracy (p)')
        
        % add lines to mark events
        xline(0,'linewidth',3,'linestyle','--','color','k')
        
%        mean_RT = mean(all_rt_corr_mat(:,iCond));
 %       xline(mean_RT*1000,'color',thisColor,'linewidth',2,'linestyle','--')
        
        if iRealPerm==1
            for idx=1:length(pVals)-1
                if pVals(idx,iCond) <.05
                    line([times(idx),times(idx+1)],[thisStatYpos,thisStatYpos],'linewidth',10,'color',thisColor); hold on
                end
            end
        end
        
        
     
        
        if iCond==2
            legend([plt(1,1),plt(1,2)],'MWA','MWL');
            title('Model-Word Conditions')       
        elseif iCond==4
            legend([plt(1,3),plt(1,4)],'WWA','WWL');
            title('Word-Word Conditions')
        end
        
    end
    
    
end

saveas(h,[destDir '/Classify_N400_' nChans '.eps' ],'epsc')
saveas(h,[destDir '/Classify_N400_' nChans '.jpg' ],'jpeg')


