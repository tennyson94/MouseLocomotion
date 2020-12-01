# MouseLocomotion

Overview
The purpose of this project is to generate figures and data analysis on locomotion data stored in Excel files. A number of helper programs are used to accumulate data into a Matlab structure, clean the data and organize it in a way that's easy to analyze. Other programs are strictly for making figures of performing certain functions such as generating heat maps or making ANOVAs. 

Features
- Use of matlab function calls
- Statistical analysis
- Heatmaps
- Command prompt for users
- Matlab structures and arrays
- Figure generation and saving automatically
- Plot individual and group data
- Histograms and bar graphs

Program descriptions: 
- MakeAllFiles
The purpose of this code is to extract all data from all excel files found in the directory specified below. Variables are written to a .mat file, arranged as one row per animal per training session (day). 

- CBMouseAnalysis
The purpose of this code is to load all CBnT mouse data and perform behavioral analysis on mouse locomotion. Mice will be grouped based on treatment indexed in the all_files struct

- makeFigs
Takes as parameters all_files struct, index, current entry, name, session, and a figure object and creates a figure for the experiments referenced by idx. This function is meant to create several figures by averaging the data across all indexed sessions, plotting it, and returning the figure data for saving in CBMouseAnalysis as well as ANOVA data and the all_files struct with additional behavior calculated. 

- Locomouse_033020
This program takes in mouse trajectory data and creates heatmaps and 3D plots of locomotion, from which trajectory data such as velocity can be calculated in addition to animal visits to specific locations in the training box. 

- makeLocoFigs
Similar to makeFigs, this takes as parameters the coordinate data for all sessions and indices to calculate group averages and make figures from these averages and return figure data to the calling function. 

- Smooth2
Creates smoothed histograms, helper function. 
