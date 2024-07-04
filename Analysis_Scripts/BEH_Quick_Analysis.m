%% calculate accuracy and RT stats

clear
close all

sourceDir = '/Users/tombullock/Documents/Psychology/AugCog/N400/Trial';

d=dir([sourceDir '/' 'sj03*WWL*.txt']);

%FILENAME = 'n400_WWL_TOM_TEST.txt';

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

accuracy = accCnt;
rt = round(rtTotal/accCnt,1);