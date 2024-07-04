clear

% set dir
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDirEEG = [rDir '/EEG_raw'];

% select filename
%filename = 'N400_Test2_No_Cap_MWA';
%filename = 'N400_Test2_No_Cap_MWL';
%filename = 'N400_Test2_No_Cap_WWA';
%filename = 'N400_Test2_No_Cap_WWL'; % problem one

% Barry second pilot
%filename = 'N400_sj82_MWA_task';
%filename = 'N400_sj82_MWL_task';
filename = 'N400_sj82_WWA_task';
%filename = 'N400_sj82_WWL_task';



% load data
EEG = pop_fileio([sourceDirEEG '/' filename '.vhdr']);

clear v v1
v = [EEG.event.latency];
cnt=0;
for i=1:length(v)-1
    if (v(i)-v(i+1)) <-1000
        cnt=cnt+1;
        v1(cnt)=v(i+1)
    end
end

plot(v1/1000,repmat(1,[1,length(v1)]),'LineStyle','none','Marker','o');
set(gca,'FontSize',18)
xlabel('Time (secs)')
ylabel('Trigger Code (arbitrary)')
title(filename(end-2:end))

