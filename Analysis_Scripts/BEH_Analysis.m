%{
BEH_Analysis
Author: Tom Bullock
Date: 11.02.24

Calulate accuracy and RT for each sub, output compiled data to mat, make
quick plots.

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/Trial'];
destDir = [rDir '/Data_Compiled'];

% subjects
subjects = 3:26;

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

        d=dir([sourceDir '/' sprintf('sj%02d*%s*.txt',sjNum,condLabel)]);

        events = readtable([sourceDir '/' d.name]);
        accCnt=0;
        rtTotal=0;
        for i=1:height(events)
            if (strcmp(events{i,5}{1},'True')) && (events{i,4}==1)
                accCnt=accCnt+1;
                rtTotal = rtTotal + events{i,3};
            elseif (strcmp(events{i,5}{1},'False')) && (events{i,4}==2)
                accCnt=accCnt+1;
                rtTotal = rtTotal + events{i,3};
            end
        end

        accuracy(iSub,iCond) = accCnt;
        rt(iSub,iCond) = round(rtTotal/accCnt,1);

    end

end

% save acc and RT mats to file
save([destDir '/BEH_Master.mat'],'accuracy','rt','subjects')


mean_acc = mean(accuracy,1);
sem_acc = std(accuracy,0,1)./sqrt(size(mean_acc,1));

mean_RT = mean(rt,1);
sem_RT = std(rt,0,1)./sqrt(size(rt,1));

h=figure;
errorbar(mean_acc,sem_acc)
set(gca,'xlim',[0.5,4.5],'xtick',1:4,'xticklabel',{'MWA','MWL','WWA','WWL'})
ylabel('Accuracy (p)')

h=figure;
errorbar(mean_RT,sem_RT)
set(gca,'xlim',[0.5,4.5],'xtick',1:4,'xticklabel',{'MWA','MWL','WWA','WWL'})
ylabel('RT (ms)')


