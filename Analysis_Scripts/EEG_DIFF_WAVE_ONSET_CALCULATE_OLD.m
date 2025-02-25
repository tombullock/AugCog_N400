%{
EEG_DIFF_WAVE_ONSET_CALCULATE
Author: Tom Bullock
Date: 01.25.25

Find the timepoint where diff waves become statistically significant.
Compare this to the timepoint where the classifier becomes statistically
significant.

%}

clear
close all

% set dirs
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400';
sourceDir = [rDir '/Data_Compiled'];
destDir = [rDir '/Data_Compiled'];

% load ERP peak latency data
EEG = load([sourceDir '/ERP_AMP_LAT.mat']);
peak_lat = EEG.peak_lat_all;



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