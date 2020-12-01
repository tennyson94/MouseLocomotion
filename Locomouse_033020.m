clear all; close all; clc

%% Stephen Tennyson, 3/30/2020

uiopen; 

inputstr1 = ['Please choose an anlaysis:\n(1) Compare Groups\n(2) Individuals\n'];
entry = input(inputstr1);

inputstr2 = ['Ignore PRE and REF?\n(1) No\n(2) Yes\n'];
entry2 = input(inputstr2);

% Create a directory to save figures to
if entry == 1
    pathstring1 = strcat('LocomotionTrtCompare_',date);
    subpath = strcat(pwd, strcat('\',pathstring1));
    if ~exist(subpath, 'dir')
        
        mkdir(sprintf(pathstring1))
    else
        fprintf('Directory %s already exists, press any key to overwrite, or Ctrl+C to abort', pathstring1);
        inputstr3 = ['\n'];
        entry3 = input(inputstr3);  
    end
end

% Remove PRE and REF data if that is what was selected
if entry2 == 2

    % Also remove PRE and REF here
    coord_count = 1; 
    for j = 1 : length(coords)
        if strcmp(coords(j).treatment,'PRE') == 1 || strcmp(coords(j).treatment, 'REF') == 1
            rmv_idx(coord_count,1) = j; 
            coord_count = coord_count + 1;
        end
    end
    coords(rmv_idx) = []; 
    
end

if entry == 1 || entry == 2
    % Compile a list of all treatments in the current list
    for i = 1 : length(coords)
        % Get all session names
        trt_names(i,1) = coords(i).treatment;
    end
    % Find unique strings within all names and put into a struct
    trt.names = unique(trt_names);
    
    for i = 1 : length(trt.names)
        count = 1;
        row = 1;
        while count <= length(coords)
            % Create an index for each animal
            while count <= length(coords) && ...
                    (strcmp(coords(count).treatment, trt.names(i)) == 1)
                trt_idx(row, i) = count;
                row = row + 1;
                count = count + 1;
            end
            count = count + 1;
        end
    end
    
    % Call on makeLocoFigs function
    ph = gobjects(1, size(trt_idx,2));
    anov = [];
    allgrids = zeros(8,12,size(trt_idx,2));

    for i = 1 : size(trt_idx,2)
            [ph, coords, anov, allgrids] = makeLocoFigs(coords, trt_idx(:,i), ...
                entry, coords(trt_idx(1,i)).treatment, i, ph, anov, allgrids);
            legend_names(i) = coords(trt_idx(1,i)).treatment;
    end
    
    
    % Get average of allgrids to subtract from other treatment groups
    allgrids_mean = mean(allgrids,3);
    
    % Graph all heatmaps, subtracting mean
    for i = 1 : size(trt_idx,2)
        currname = coords(trt_idx(1,i)).treatment;
        heatmap(:,:,i) = flipud(allgrids(:,:,i) - allgrids_mean);
        fig = figure(i); hold on; 
        colorbar
        image(heatmap(:,:,i),'CDataMapping','scaled');
        title(strcat(currname, ' Average Heatmap'));
        
        maxaxes(i) = max(fig.CurrentAxes.CLim);
        minaxes(i) = min(fig.CurrentAxes.CLim);

    end
    
    clim = max(maxaxes);
    % Plot and Save compare group figures
    if entry == 1
        for i = 1 : size(trt_idx,2)
            
            fig = figure(i); hold on; 
            caxis(fig.CurrentAxes, [0 clim]); hold off;
            saveas(fig, fullfile(subpath,strcat(num2str(i),'_HeatmapTrt.jpg')));
            saveas(fig, fullfile(subpath,strcat(num2str(i),'_HeatmapTrt.fig')));

        end
        
    end
    
end




