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
        
        % get combined cong and incong acc and rt
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

        % split by cong and incong
        accCong=0;
        rtCong=0;
        accIncong=0;
        rtIncong=0;

        for i=1:height(events)
            if (strcmp(events{i,5}{1},'True')) && (events{i,4}==1)
                accCong=accCong+1;
                rtCong = rtCong + events{i,3};
            elseif (strcmp(events{i,5}{1},'False')) && (events{i,4}==2)
                accIncong=accIncong+1;
                rtIncong = rtIncong + events{i,3};
            end
        end

        accuracy_cong(iSub,iCond) = accCong*2;
        rt_cong(iSub,iCond) = round(rtCong/accCong,1);

        accuracy_incong(iSub,iCond) = accIncong*2;
        rt_incong(iSub,iCond) = round(rtIncong/accIncong,1);

    end

end

% combine cong and incong into one mat for plotting
accuracy_cong_incong = [accuracy_cong(:,1),accuracy_incong(:,1),accuracy_cong(:,2),accuracy_incong(:,2),accuracy_cong(:,3),accuracy_incong(:,3),accuracy_cong(:,4),accuracy_incong(:,4)];
rt_cong_incong = [rt_cong(:,1),rt_incong(:,1),rt_cong(:,2),rt_incong(:,2),rt_cong(:,3),rt_incong(:,3),rt_cong(:,4),rt_incong(:,4)];

% compute incong-cong difference for each condition
accuracy_diff = [accuracy_incong(:,1)-accuracy_cong(:,1), accuracy_incong(:,2)-accuracy_cong(:,2), accuracy_incong(:,3)-accuracy_cong(:,3),accuracy_incong(:,4)-accuracy_cong(:,4)];
rt_diff = [rt_incong(:,1)-rt_cong(:,1), rt_incong(:,2)-rt_cong(:,2), rt_incong(:,3)-rt_cong(:,3),rt_incong(:,4)-rt_cong(:,4)];


% save acc and RT mats to file
save([destDir '/BEH_Master.mat'],'accuracy','rt','accuracy_cong','accuracy_incong','rt_cong','rt_incong','accuracy_cong_incong','rt_cong_incong','accuracy_diff','rt_diff','subjects')

% plot combined cong and incong
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


% plot separate cong and incong
h=figure;
for iPlot=1:2

    if iPlot==1
        d_acc = accuracy_cong;
        thisColor = 'g';
    else
        d_acc = accuracy_incong;
        thisColor = 'r';
    end

    mean_acc = mean(d_acc,1);
    sem_acc = std(d_acc,0,1)./sqrt(size(mean_acc,1));

    errorbar(mean_acc,sem_acc,'color',thisColor); hold on
    set(gca,'xlim',[0.5,4.5],'xtick',1:4,'xticklabel',{'MWA','MWL','WWA','WWL'})
    ylabel('Accuracy (p)')

end
legend('cong','incong')

% plot separate cong and incong
h=figure;
for iPlot=1:2

    if iPlot==1
        d_rt = rt_cong;
        thisColor = 'g';
    else
        d_rt = rt_incong;
        thisColor = 'r';
    end

    mean_RT = mean(d_rt,1);
    sem_RT = std(d_rt,0,1)./sqrt(size(d_rt,1));

    %h=figure;
    errorbar(mean_RT,sem_RT,'color', thisColor); hold on
    set(gca,'xlim',[0.5,4.5],'xtick',1:4,'xticklabel',{'MWA','MWL','WWA','WWL'})
    ylabel('RT (ms)')

end

legend('cong','incong')







