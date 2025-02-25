#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jan 11 09:26:54 2025

@author: tombullock
"""

import pandas as pd
import numpy as np
from scipy.io import loadmat
import os
import janitor # useful pivot function for wide > long
import seaborn as sns
import matplotlib.pyplot as plt

## SET DIRECTORIES AND LOAD DATA

# set dirs (check all folders are already present)
rDir = '/Users/tombullock/Documents/Psychology/AugCog/N400'
scriptDir = os.path.join( rDir, 'Analysis_Scripts_Py')
sourceDir = 'Data_Compiled'
destDir = 'Plots_Py' 
destDirData = 'Data_Compiled_Py'

# set filenames
mat_file = 'BEH_Master' # source file 
image_title = 'Behavior_Cong_Incong' # destination figure title 

# load matlab data
mat_contents = loadmat(os.path.join(rDir,sourceDir, mat_file))

# set path for figure ()
figPath = os.path.join(rDir, destDir, image_title)


## CREATE DATAFRAMES FOR AVERAGED BEHAVIOR

# grab subjects info
subjects = mat_contents['subjects'][0]

## SET COLUMN NAMES FOR DATAFRAMES
cond_names = ["MWA Con","MWA Inc","MWL Con","MWL Inc","WWA Con","WWA Inc","WWL Con","WWL Inc"]


## FOR ACCURACY (just output summary stats, no need for dataframe)

# isolate acc
all_acc = mat_contents['accuracy_cong_incong']
mean_acc = np.mean(all_acc,axis=0)
sem_acc = np.std(all_acc,axis=0)/(len(all_acc)**.5)

# put acc into a df
df_acc = pd.DataFrame(all_acc)
df_acc.columns = cond_names

# convert dataframe from wide to long format
df_acc_long = pd.melt(df_acc,
                value_vars=cond_names,
                var_name='Condition',
                value_name='Acc')

# add subject numbers
df_acc_long.insert(0, 'SjNum', np.tile(subjects,8))


## FOR RT

# isolate the RTs (creates a 40 subs x 3 cond matrix)
all_rt = mat_contents['rt_cong_incong']

# put data into dataframe
df_rt = pd.DataFrame(all_rt)
df_rt.columns = cond_names

# convert dataframe from wide to long format
df_rt_long = pd.melt(df_rt,
                value_vars=cond_names,
                var_name='Condition',
                value_name='RT')

# add subject numbers
df_rt_long.insert(0, 'SjNum', np.tile(subjects,8))


# output dataframe to csv [optional - useful if you want to ouput the "long" format dataframe to a csv to then import into, say, R, to run stats]
#filename = os.path.join(rDir,destDirData,'BEH_RT_Grouped.csv')
#df1.to_csv(filename)


## FOR RT DIFF

# isolate acc
all_rt_diff = mat_contents['rt_diff']

# put acc into a df
df_rt_diff = pd.DataFrame(all_rt_diff)
cond_names = ["MWA","MWL","WWA","WWL"]
df_rt_diff.columns = cond_names

# convert dataframe from wide to long format
df_rt_diff_long = pd.melt(df_rt_diff,
                value_vars=cond_names,
                var_name='Condition',
                value_name='RT')

# add subject numbers
df_rt_diff_long.insert(0, 'SjNum', np.tile(subjects,4))





# GENERATE PLOTS

# set theme
sns.set_theme(context="poster", style='ticks')

# set color palette
#thisColorPalette = ['#9A28D4','#3886EB','#F7482F'] # created using Adobe https://color.adobe.com/create/color-wheel
#thisColorPalette = ['#0072B2','#E69F00','#009E73','#CC79A7']
thisColorPalette = ['#0072B2','#0072B2','#009E73','#009E73','#E69F00','#E69F00','#CC79A7','#CC79A7']

# set color for mean line
yellow = '#B9D9C1'#'#A3D6A4'#'#53D798' #'#F5DA67'
meanLineColor = yellow

# set figure dimensions, axes etc.
fig_w = 22
fig_h = 12

this_figsize = (fig_w,fig_h)
thisSubplotShape = (fig_h,fig_w)

fig = plt.figure(figsize=this_figsize)
ax1 = plt.subplot2grid((fig_h, fig_w), (0, 0), rowspan = 5,colspan=6) # axis for accuracy boxplot + beeswarm plot
#ax2 = plt.subplot2grid((fig_h, fig_w), (0, 6),rowspan = 5, colspan=2) # axis for accuracy density plot
ax3 = plt.subplot2grid((fig_h, fig_w), (0, 8), rowspan = 5, colspan=6) # axis for RT boxplot + beeswarm plot
#ax4 = plt.subplot2grid((fig_h, fig_w), (0, 16), rowspan = 5, colspan=2) # axis for RT density plot
ax5 = plt.subplot2grid((fig_h, fig_w), (0, 16), rowspan = 5, colspan=6) # axis for RT boxplot + beeswarm plot




# PLOT ACCURACY GROUPED

# # plot beeswarm
# sns.swarmplot(ax=ax1,
#           data=df_acc_long,
#           x='Condition',
#           y='Acc',
#           palette='dark:k',
#           alpha=.9,
#           size=7)

# plot boxplot
sns.boxplot(ax=ax1,
        data=df_acc_long,
        x='Condition',
        y='Acc',
        showmeans=True,
        meanline=True,
        showfliers=False,
        palette=thisColorPalette,
        order = ["MWA Con","MWA Inc","WWA Con","WWA Inc","MWL Con","MWL Inc","WWL Con","WWL Inc"],
        meanprops={'color':meanLineColor,
                    'ls':'-',
                    'lw':3})

ax1.set(xlabel=None, ylabel='Accuracy (%)')#,ylim=(350,550),yticks=np.arange(375,526,25))
ax1.tick_params(axis='x', rotation=90)
sns.despine(ax=ax1, trim=True)


# # plot density
# sns.kdeplot(ax=ax2,
#         data=df_acc_long,
#         y="Acc",
#         hue="Condition",
#         palette=thisColorPalette,
#         fill=True,
#         legend=False)

# sns.despine(ax=ax2, trim=True)

# ax2.set(ylabel=None,
#     yticks=[],
#     xticks=[])#,
#     #ylim=(350,550))

# ax2.spines['left'].set_visible(False)



## PLOT RT GROUPED

# # plot swarmplot
# sns.swarmplot(ax=ax3,
#           data=df_rt_long,
#           x='Condition',
#           y='RT',
#           palette='dark:k',
#           alpha=.9,
#           size=7)

# plot boxplot
sns.boxplot(ax=ax3,
        data=df_rt_long,
        x='Condition',
        y='RT',
        showmeans=True,
        meanline=True,
        showfliers=False,
        palette=thisColorPalette,
        order = ["MWA Con","MWA Inc","WWA Con","WWA Inc","MWL Con","MWL Inc","WWL Con","WWL Inc"],
        meanprops={'color':meanLineColor,
                    'ls':'-',
                    'lw':3})

ax3.set(xlabel=None, ylabel='RT (ms)')#,ylim=(350,550),yticks=np.arange(375,526,25))
ax3.tick_params(axis='x', rotation=90)
sns.despine(ax=ax3, trim=True)


# # plot density
# sns.kdeplot(ax=ax4,
#         data=df_rt_long,
#         y="RT",
#         hue="Condition",
#         palette=thisColorPalette,
#         fill=True,
#         legend=False)

# sns.despine(ax=ax4, trim=True)

# ax4.set(ylabel=None,
#     yticks=[],
#     xticks=[])#,
#     #ylim=(350,550))

# ax4.spines['left'].set_visible(False)



## PLOT RT DIFF GROUPED

thisColorPalette = ['#0072B2','#009E73','#E69F00','#CC79A7']



# plot boxplot
sns.boxplot(ax=ax5,
        data=df_rt_diff_long,
        x='Condition',
        y='RT',
        showmeans=True,
        meanline=True,
        showfliers=False,
        palette=thisColorPalette,
        order = ["MWA","WWA","MWL","WWL"],
        meanprops={'color':meanLineColor,
                    'ls':'-',
                    'lw':3})

ax5.set(xlabel=None, ylabel='RT Con-Inc Differences (ms)')#,ylim=(350,550),yticks=np.arange(375,526,25))
ax5.tick_params(axis='x', rotation=90)
sns.despine(ax=ax5, trim=True)






## ADD TEXT LABELS
ax1.text(-.1, 1.1, 'a', transform=ax1.transAxes, fontweight='bold',
     fontsize=32, va='top', ha='right')  # adds a subplot label
ax3.text(-.1, 1.1, 'b', transform=ax3.transAxes, fontweight='bold',
     fontsize=32, va='top', ha='right')  # adds a subplot label
ax5.text(-.1, 1.1, 'c', transform=ax5.transAxes, fontweight='bold',
     fontsize=32, va='top', ha='right')  # adds a subplot label

# save figure
fig.show()
plt.savefig(figPath + '.png', bbox_inches='tight')
plt.savefig(figPath + '.pdf', bbox_inches='tight')
#fig.close()

