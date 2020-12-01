close all; clear all; clc; 
%% Stephen Tennyson, 1/7/2020
%   The purpose of this code is to extract all data from all excel files
%   found in the directory specified below. Variables are written to a .mat 
%   file, arranged as one row per animal per training session (day). 
% 
%   -All files in directory MUST be excel files. Any other file type or 
%    folders in the path will cause errors. 
%
%   -Mag files must be put in a separate folder from autoshaping files
%
%   -The home path specified above is where the load list will be saved.
%    The path pasted on Ln 18 is where the data can be found. 

%% Find files
% Read in all files within directory specified below, only excel files
% This gives a list of all file names, date created and details 


% Modify these two lines, pasting the directory where datafiles are located
% WARNING - Do not remove the \*.csv from the directory, this locates the
% excel file

entry2 = input('Is this locomotion data? (1) Yes (2) No');
if entry2 == 1 
    
%Locomotion Data
addpath(genpath('F:\CBn_Project\Locomotion\Data'));
files = dir('F:\CBn_Project\Locomotion\Data\*.csv');

else
% Behavior Data
addpath(genpath('F:\CBn_Project\CBMice\CBnT26_40_All\Data'));
files = dir('F:\CBn_Project\CBMice\CBnT26_40_All\Data\*.xlsx');

end
% Prompt user to enter file name
entry = input('Enter file name \n', 's');

%% Use a for loop to iterate through all files and extract data
%   all_files struct columns:
%       animal name 
%       date
%       strobe
%       strobeTime
%       beamID
%       beamTime
%       latency

file_count = 1; 
for i = 1 : length(files)
    % Only read in files
    if files(i).isdir ~= 1
        
    % Reset counter
    k = 0; idx = 0;
    
    % Extract file name
    name = strsplit(files(i).name, '_');
    
    % Extract excel data
    datafile = xlsread(files(i).name);   
    
    if entry2 == 2
        %% Find range where beginning 0's end for beamID & beamTime
        % Iterate through all beam breaks
        for k = 1 : length(datafile(:,4))
            % Save index when beam time exceeds 0
            if datafile(k,4) > 0
                idx = k; 
                % Break after first 0
                break;
            end
        end

        % Find length of beam breaks 
        len = length(datafile(:,4));

        %% Write to struct
        all_files(file_count).name = name(1);
        all_files(file_count).date = name(2);
        all_files(file_count).treatment = name(3);
        all_files(file_count).strobeID = datafile(~isnan(datafile(:,1)));
        all_files(file_count).strobeTime = datafile((~isnan(datafile(:,2))), 2);

        % Create temporary storage of beam data to remove beginning 0's
        all_files(file_count).tempBeamID = datafile((~isnan(datafile(:,3))),3);
        all_files(file_count).tempBeamTime = datafile((~isnan(datafile(:,4))),4);
        % Only save non-0 beam data
        all_files(file_count).beamID = all_files(file_count).tempBeamID(idx:len);
        all_files(file_count).beamTime = all_files(file_count).tempBeamTime(idx:len);
        % Remove temp struct fields
        rmfield(all_files,'tempBeamID');
        rmfield(all_files,'tempBeamTime');
        % Save latency
        all_files(file_count).latency = datafile((~isnan(datafile(:,5))),5);

        % Print progress
        fprintf('%s File %i saved\n', all_files(file_count).name{:}, file_count);
        file_count = file_count + 1; 

    else
        %Save locomotion data below
        %Remove negative values at end of matrix
        delidx = find(datafile(:,3)<0);
        datafile(delidx,:) = [];
        % Find number of frames
        len = length(datafile(:,4));

        %% Write to struct
        coords(file_count).name = name(1);
        coords(file_count).date = name(2);
        coords(file_count).treatment = name(4);
        coords(file_count).frames = len;
        coords(file_count).time = datafile(:,2);
        coords(file_count).x = datafile(:,3);
        coords(file_count).y = datafile(:,4);

        % Print progress
        fprintf('%s File %i saved\n', coords(file_count).name{:}, file_count);
        file_count = file_count + 1; 

        
        
    end
    end
end
if entry2 == 2
fprintf('Your load list is ready');
save(entry,  'all_files');

else
    fprintf('Your loco list is ready');
    save(entry, 'coords');
end 