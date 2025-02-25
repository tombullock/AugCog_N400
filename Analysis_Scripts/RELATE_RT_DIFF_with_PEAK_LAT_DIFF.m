%{
RELATE_RT_DIFF_with_PEAK_LAT_DIFF
Author: Tom Bullock
Date: 01.25.25

Correlate the RT DIFF (i.e. cong-incong) with Peak Lat diff (i.e.
cong-incong) for each condition. Is it diminished in MWA???

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/Data_Compiled'];
destDir = [rDir '/Data_Compiled'];

% load behavioral data
BEH = load([sourceDir '/BEH_Master.mat']);
%rt_diff = BEH.rt_diff;
rt = BEH.rt;

% load ERP peak latency data
EEG = load([sourceDir '/ERP_AMP_LAT.mat']);
peak_lat = EEG.peak_lat_all;

% correlate
for i=1:4
    [RHO,PVAL] = corr(rt(:,i),peak_lat(:,i))
end