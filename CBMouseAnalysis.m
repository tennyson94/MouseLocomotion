close all; close all hidden; clear all; clc; 

%% Stephen Tennyson, 1/8/2020
%   The purpose of this code is to load all CBnT mouse data and perform 
%   behavioral analysis on mouse locomotion. Mice will be grouped based
%   on treatment (PCP, SAL etc) indexed in the all_files struct

% Prompt user to load file of interest into workspace(in current directory)
uiopen; 

% Code to average across one of the options below
%       (1) Compare Groups
%       (2) ANOVAs
%       (3) Compare Groups & ANOVAs
%       (4) Individuals
%       (5) Half Sessions

inputstr = ['Please enter:\n(1) Compare Groups\n(2) ANOVAs\n(3)', ... 
    ' Compare Groups & ANOVAs\n(4) Individuals\n(5) Half Sessions\n'];
entry = input(inputstr);

inputstr2 = ['Ignore PRE and REF?\n(1) No\n(2) Yes\n'];
entry2 = input(inputstr2);

% Create a directory to save figures to 
if entry == 1 || entry == 3
    pathstring1 = strcat('CompareGroups_',date);
    subpath = strcat(pwd, strcat('\', pathstring1));
    
    if ~exist(subpath, 'dir')
        
        mkdir(sprintf(pathstring1))
    else
        fprintf('Directory %s already exists, press any key to overwrite, or Ctrl+C to abort', pathstring1);
        inputstr3 = ['\n'];
        entry3 = input(inputstr3);  
    end
end

if entry == 5
    pathstring2 = strcat('HalfSessions_',date);
    subpath = strcat(pwd, strcat('\', pathstring2));
    
    if ~exist(subpath, 'dir')
        
        mkdir(sprintf(pathstring2))
    else
        fprintf('Directory %s already exists, press any key to overwrite, or Ctrl+C to abort', pathstring2);
        inputstr3 = ['\n'];
        entry3 = input(inputstr3);  
    end
    
end

% Remove PRE and REF data if that is what was selected
if entry2 == 2

    % Also remove PRE and REF here
    all_file_count = 1; 
    for j = 1 : length(all_files)
        if strcmp(all_files(j).treatment,'PRE') == 1 || strcmp(all_files(j).treatment, 'REF') == 1
            rmv_idx(all_file_count,1) = j; 
            all_file_count = all_file_count + 1;
        end
    end
    all_files(rmv_idx) = []; 
    
end
% Strobes
% 17 - lever out
% 18 - lever press
% 19 - lever in/pellet out
% 20 - trough break
% 21 - trough break while lever out

%% Create an index where each column has the indices for each animal 

    % Run analysis on individual animals
    % Compile a list of all animals in the current load list
    for i = 1 : length(all_files)
        % Get all session names
        sesh_names(i,1) = all_files(i).name;
        trt_names(i,1) = all_files(i).treatment;
    end
    
% For ANOVAS - Hash table structure for Animal key-value pairs
% Key = animal name, val = animal name value
% ie) CBnT26 (Key) = 1 (Val)
    uanimals = unique(sesh_names);
    for i = 1:length(uanimals)
        animals(i).names = uanimals(i);
        animals(i).val = i;

    end
    
% Hash table structure for Treatment key-value pairs
    utrt = unique(trt_names);
    for i = 1:length(utrt)
        treatments(i).names = utrt(i);
        treatments(i).val = i;
    end
   
    count = 1;
% Create an index for sessions of each animal
    for i = 1 : length(animals)
        row = 1;
        while count <= length(all_files) && ...
                (strcmp(all_files(count).name, animals(i).names) == 1)
            name_idx(row, i) = count;
            row = row + 1;
            count = count + 1;
        end
    end
    
    % Create pre_idx which contains the indices (row) of 'PRE' sessions for each
    % animal (col)
    precount = 1;
    for col = 1 : size(name_idx, 2) 
        for row = 1 : size(name_idx, 1)

            % Check for missing data files / errors in load list
            try all_files(name_idx(row,col)).treatment;
            catch
                warning('Animals have unequal number of sessions, try removing deceased animals from the dataset or check name_idx for missing files indicated by a 0');
            end
            
                % Save idx if PRE
                if strcmp(all_files(name_idx(row, col)).treatment, 'PRE') == 1
                 pre_idx(precount, col) = name_idx(row, col);
                 precount = precount + 1;
                end
        end
        precount = 1;
    end
    
    % If PRE data is available, average across these days for ANOVA
    if entry2 == 1
        %Check for PRE data
        try pre_idx;
        catch
            warning('No PRE data is included in the load list');
        end
        
        ph = gobjects(1, size(pre_idx,2));

        % For full session ANOVAS - use entry 99
        % Use makeFigs to get average data for the pre_idx calculated above
        % Use entry = 99 because you aren't outputting figures for this
        if entry ~= 5
            for i = 1 : size(pre_idx,2)
                anov(i).name = all_files(pre_idx(1,i)).name;
                anov(i).treatment = 'PRE';
                [ph, all_files, anov] = makeFigs(all_files, pre_idx(:,i), 99, ...
                    all_files(pre_idx(1,i)).treatment, i, ph, anov);
            end
        
        else
            % For half session ANOVAs - use entry 100 and 101
             % Run makeFigs two rounds, once for each half of session
            fullseshcount = 1;
            for h = 0 : 1
                for i = 1 : size(pre_idx,2)
                    anov(fullseshcount).name =  all_files(pre_idx(1,i)).name;
                    anov(fullseshcount).treatment = 'PRE';
                    anov(fullseshcount).sesh = h;
                    fullseshcount = fullseshcount + 1;
                    [ph, all_files, anov] = makeFigs(all_files, pre_idx(:,i), ...
                        100 + h, all_files(pre_idx(1,i)).treatment, i, ph, anov);
                end
            end
        end
    else
        % If PRE data not available, don't update anov and 
        anov = [];

    end
    
%% Compare individual animals
    if entry == 4
        % Use the above indices to create bar graphs for individual animals
        ph = gobjects(1,size(name_idx,2));
        for i = 1 : size(name_idx, 2)
                [ph, all_files, anov] = makeFigs(all_files, name_idx(:,i), ...
                        entry, all_files(name_idx(1,i)).name, i, ph);
        end

    end
    
%% Compare Treatment Groups
% This entry, similar to entry = 1, will pass in thei indices for all
% sessions of a specific treatment group and create one figure. makeFigs
% will be called additional times for the other groups to be compared, so
% that those figures can be superimposed on the first figure
if entry == 1 || entry == 2 || entry == 3 || entry == 5
    
    % Compile a list of all treatments in the current list
    for i = 1 : length(all_files)
        % Get all session names
        trt_names(i,1) = all_files(i).treatment;
    end
    % Find unique strings within all names and put into a struct
    trt.names = unique(trt_names);
    
    for i = 1 : length(trt.names)
        count = 1;
        row = 1;
        while count <= length(all_files)
            % Create an index for each animal
           while count <= length(all_files) && ...
                   (strcmp(all_files(count).treatment, trt.names(i)) == 1)
                trt_idx(row, i) = count;
                row = row + 1;
                count = count + 1;
            end
        count = count + 1;
        end
    end
    
    ph = gobjects(1, size(trt_idx,2));

    if entry ~= 5
        for i = 1 : size(trt_idx,2)
            [ph, all_files, anov] = makeFigs(all_files, trt_idx(:,i), ...
                entry, all_files(trt_idx(1,i)).treatment, i, ph, anov);
            legend_names(i) = all_files(trt_idx(1,i)).treatment;
        end
    else
        % Run makeFigs two rounds, once for each half of session
        for h = 0 : 1
            for i = 1 : size(trt_idx,2)
                [ph, all_files, anov] = makeFigs(all_files, trt_idx(:,i), ...
                    entry + h, all_files(trt_idx(1,i)).treatment, i, ph, anov);
                legend_names(i) = all_files(trt_idx(1,i)).treatment;
            end
        end
    end
    
    % Only print figures in case 1 and 3
    if entry == 1 || entry == 3 || entry == 5
     
        if entry == 5
    ct = 1;
    for i = 1:8
        halfaxes(ct,1) = ph(i).Parent.YLim(2);
        halfaxes(ct,2) = ph(i+9).Parent.YLim(2);
        ct = ct + 1;
    end
%     for i = 40
%         halfaxes(ct,1) = ph(i).Parent.YLim(2);
%         halfaxes(ct,2) = ph(i).Parent.YLim(2);
%         ct = ct + 1;
%     end
        end
    f1 = figure(1);
    legend(ph(1,:), legend_names)
    if entry == 5
        ylim([0 max(halfaxes(1,:))]); 
    end
    saveas(f1, fullfile(subpath,'overlayed_lever.jpg'));
        saveas(f1, fullfile(subpath,'overlayed_lever.fig'));


    f2 = figure(2);
    legend(ph(2,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(2,:))]); 
        end
    saveas(f2, fullfile(subpath,'overlayed_trough.jpg'));
    saveas(f2, fullfile(subpath,'overlayed_trough.fig'));

    f3 = figure(3);
    legend(ph(3,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(3,:))]); 
        end
    saveas(f3, fullfile(subpath,'lever_bar_trt.jpg'));
    saveas(f3, fullfile(subpath,'lever_bar_trt.fig'));

    f4 = figure(4);
    legend(ph(4,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(4,:))]); end
    saveas(f4, fullfile(subpath,'tro_bar_trt.jpg'));
    saveas(f4, fullfile(subpath,'tro_bar_trt.fig'));

    f5 = figure(5);
    legend(ph(5,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(5,:))]); end
    saveas(f5, fullfile(subpath, 'loco_bar_trt.jpg'));
    saveas(f5, fullfile(subpath, 'loco_bar_trt.fig'));

    f6 = figure(6);
    legend(ph(6,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(6,:))]); end
    saveas(f6, fullfile(subpath,'dif_bar_trt.jpg'));
        saveas(f6, fullfile(subpath,'dif_bar_trt.fig'));

    f7 = figure(7);
    legend(ph(7,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(7,:))]); end
    saveas(f7, fullfile(subpath,'latency_lever_trt.jpg'));
    saveas(f7, fullfile(subpath,'latency_lever_trt.fig'));
    
    f8 = figure(8);
    legend(ph(8,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(8,:))]); end
    saveas(f8, fullfile(subpath,'latency_trough_trt.jpg'));
        saveas(f8, fullfile(subpath,'latency_trough_trt.fig'));

        if entry ~= 5
    f40 = figure(40);
    legend(ph(40,:), legend_names)
        if entry == 5
        ylim([0 max(halfaxes(9,:))]); end
    saveas(f40, fullfile(subpath,'BwBreaks_trt.jpg'));
        saveas(f40, fullfile(subpath,'BwBreaks_trt.fig'));
        end
        
    if entry ~= 5
        ct = 1;
        % Get max axes for beam figures
        for i = 9:9 + length(utrt) - 1
            allaxes(ct) = ph(i).Parent.YLim(2);
            ct = ct + 1;
        end
        
        ct = 1;
        % Get max axes for locomotion per trial
        for i = 20:3:20 + 3*(length(utrt)) - 1
            allaxes_2(ct) = ph(i).Parent.YLim(2);
            ct = ct + 1;
        end
        
        ct = 1;
        % Get max axes for lever per trial
        for i = 21:3:21 + 3*(length(utrt)) - 1
            allaxes_3(ct) = ph(i).Parent.YLim(2);
            ct = ct + 1;
        end
        
        ct = 1;
        % Get max axes for trough by trial
        for i = 22:3:22 + 3*(length(utrt)) - 1
            allaxes_4(ct) = ph(i).Parent.YLim(2);
            ct = ct + 1;
        end
        
        ymax = max(allaxes);
        ymax_2 = max(allaxes_2);
        ymax_3 = max(allaxes_3);
        ymax_4 = max(allaxes_4);
        ct = 1;
        
        for i = 9:9+ length(utrt)
            f(ct) = figure(i);
            strtit = strcat('BeamBreak', num2str(ct), '.jpg');
            strtitfig = strcat('BeamBreak',num2str(ct),'.fig');

            ylim([0 ymax])
            saveas(f(ct), fullfile(subpath,strtit));
                    saveas(f(ct), fullfile(subpath,strtitfig));

            ct = ct + 1;
        end

        for i = 20:3:20 + 3*(length(utrt)) - 1
            f(ct) = figure(i);
            strtit = strcat('BWTrialLocomotion', num2str(ct), '.jpg');
            strtitfig = strcat('BWTrialLocomotion',num2str(ct),'.fig');

            ylim([0 ymax_2])
            saveas(f(ct), fullfile(subpath,strtit));
                    saveas(f(ct), fullfile(subpath,strtitfig));

            ct = ct + 1;
        end
        
        for i = 21:3:21 + 3*(length(utrt)) - 1
            f(ct) = figure(i);
            strtit = strcat('BWTrialLever', num2str(ct), '.jpg');
            strtitfig = strcat('BWTrialLever',num2str(ct),'.fig');
            
            ylim([0 ymax_3])
            saveas(f(ct), fullfile(subpath,strtit));
            saveas(f(ct), fullfile(subpath,strtitfig));
            
            ct = ct + 1;
        end
        
        for i = 22:3:22 + 3*(length(utrt)) - 1
            f(ct) = figure(i);
            strtit = strcat('BWTrialTrough', num2str(ct), '.jpg');
            strtitfig = strcat('BWTrialTrough',num2str(ct),'.fig');
            
            ylim([0 ymax_4])
            saveas(f(ct), fullfile(subpath,strtit));
            saveas(f(ct), fullfile(subpath,strtitfig));
            
            ct = ct + 1;
        end
        
    end
  end
  if entry == 5

      f10 = figure(10);
      legend(ph(10,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(1,:))]); end
      saveas(f10, fullfile(subpath,'overlayed_lever_2of2.jpg'));
            saveas(f10, fullfile(subpath,'overlayed_lever_2of2.fig'));

      f11 = figure(11);
      legend(ph(11,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(2,:))]); end
      saveas(f11, fullfile(subpath,'overlayed_trough_2of2.jpg'));
            saveas(f11, fullfile(subpath,'overlayed_trough_2of2.fig'));

      f12 = figure(12);
      legend(ph(12,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(3,:))]);end
      saveas(f12, fullfile(subpath,'lever_bar_trt_2of2.jpg'));
            saveas(f12, fullfile(subpath,'lever_bar_trt_2of2.fig'));

      f13 = figure(13);
      legend(ph(13,:), legend_names)
          if entry == 5
       ylim([0 max(halfaxes(4,:))]); end
      saveas(f13, fullfile(subpath,'tro_bar_trt_2of2.jpg'));
            saveas(f13, fullfile(subpath,'tro_bar_trt_2of2.fig'));

      f14 = figure(14);
      legend(ph(14,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(5,:))]); end
    
      saveas(f14, fullfile(subpath, 'loco_bar_trt_2of2.jpg'));
            saveas(f14, fullfile(subpath, 'loco_bar_trt_2of2.fig'));

      f15 = figure(15);
      legend(ph(15,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(6,:))]); end
      saveas(f15, fullfile(subpath,'dif_bar_trt_2of2.jpg'));
            saveas(f15, fullfile(subpath,'dif_bar_trt_2of2.fig'));

      f16 = figure(16); 
      legend(ph(16,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(7,:))]); end
      saveas(f16, fullfile(subpath,'lever_latency_2of2.jpg'));
            saveas(f16, fullfile(subpath,'lever_latency_2of2.fig'));

      f17 = figure(17);
      legend(ph(17,:), legend_names)
          if entry == 5
        ylim([0 max(halfaxes(8,:))]); end
      saveas(f17, fullfile(subpath,'trough_latency_2of2.jpg'));
            saveas(f17, fullfile(subpath,'trough_latency_2of2.fig'));

%       f41 = figure(41);
%       legend(ph(41,:), legend_names)
%           if entry == 5
%         ylim([0 max(halfaxes(9,:))]); end
%       saveas(f41, fullfile(subpath,'BWTrialTrough_2of2.jpg'));
%             saveas(f41, fullfile(subpath,'BWTrialTrough_2of2.fig'));

      
%       f18 = figure(18);
%       legend(ph(18,:), legend_names)
%       saveas(f18, fullfile(subpath,'beams_2of2.jpg'));
%      
  end
end


%% For ANOVAs
% Pass an array containing the indices of each animal per column.
if entry == 2 || entry == 3 || entry == 5
    % Create a directory to save Anova excel sheets
    pathstringa = strcat('AnovaSession_',date);
    subpath = strcat(pwd, strcat('\', pathstringa));
    if ~exist(subpath, 'dir')

    mkdir(sprintf(pathstringa))
    end
     
    %% Convert anov struct to array for anovan function
    % This loop compares anov.name to animals(i).names in order to get the
    % indices (rows) for each animal. 
    for i = 1 : length(animals)
       namedx(:,i) =  find(strcmp([anov.name], animals(i).names)==1);
    end
    
    % Remove PRE column of treatments (created earlier in code) 
    % because PRE doesn't have equal number of sessions 
    treatments(find(strcmp([treatments.names],'PRE')==1)) = [];

    % This loop compares anov.treatment to treatments(i).names to get the
    % indices (rows) for each treatment
    for i = 1 : length(treatments)
       trtdx(:,i) =  find(strcmp({anov.treatment}, treatments(i).names)==1);
    end
    
    % Add PRE key value pair back into treatments
    treatments(length(treatments) + 1).names = 'PRE';
    treatments(length(treatments)).val = 0;
    
    for i = 1 : length(anov)
        % For each row of anov, compare that sessions' name and treatment
        % to that of namedx and trtdx
        for row = 1 : size(namedx,1)
            % Check if empty first to avoid crash
            if ~isempty(find(namedx(row,:) == i))
                found = find(namedx(row,:) == i);
            end
        end
        % Skip if a PRE session
        if ~(strcmp(anov(i).treatment,'PRE')==1)
            for row = 1 : size(trtdx,1)
                % Check if empty first to avoid crash
                if ~isempty(find(trtdx(row,:) == i))
                    found2 = find(trtdx(row,:) == i);
                    % Use hash table 'treatments' to get the key for val
                    tempval = treatments(found2).val;
                end
            end
        else tempval = 0;
        end
        
        % If there was a match for this row of anov, a value will be stored
        % in 'found' and 'tempval'. 
        
        % Put everything back into an array because Anova doesn't work with
        % structures
        if entry ~= 5
            % Use hash table 'animals' to get the key for val at index
            arry(i,1) = animals(found).val;
            arry(i,2) = tempval;
            arry(i,3) = anov(i).loco;
            arry(i,4) = anov(i).lever;
            arry(i,5) = anov(i).trough;
            arry(i,6) = anov(i).diff;
            arry(i,7) = anov(i).latlev;
            arry(i,8) = anov(i).lattro;
        else
            arry(i,1) = animals(found).val;
            arry(i,2) = tempval;
            arry(i,3) = anov(i).sesh;
            arry(i,4) = anov(i).loco;
            arry(i,5) = anov(i).lever;
            arry(i,6) = anov(i).trough;
            arry(i,7) = anov(i).diff;
            arry(i,8) = anov(i).latlev;
            arry(i,9) = anov(i).lattro; 
        end
        
    end
  
    if entry ~= 5
        [ploco, tloco, statloco, termloco] = anovan(arry(:,3),arry(:,2), 'model','interaction','varnames',strvcat('Locomotion'));
        sprintf('Locomotion stats\np: %f', ploco)

        [plev, tlev, statlev, termlev] = anovan(arry(:,4),arry(:,2), 'model','interaction','varnames',strvcat('Lever'));
        sprintf('Lever stats\np: %f', plev)

        [ptro, ttro, stattro, termtro] = anovan(arry(:,5),arry(:,2), 'model','interaction','varnames',strvcat('Trough'));
        sprintf('Trough stats\np: %f', ptro)

        [pdiff, tdiff, statdiff, termdiff] = anovan(arry(:,6),arry(:,2), 'model','interaction','varnames',strvcat('Diff'));
        sprintf('Trough Lever Difference stats\np: %f', pdiff)

        % Col 1 : animal, Col 2: Treatment, Col 3: Behavioral Data (excel filename)
        xlswrite(fullfile(subpath,'Locomotion'),[arry(:,1),arry(:,2),arry(:,3)]);
        xlswrite(fullfile(subpath,'Lever'),[arry(:,1),arry(:,2),arry(:,4)]);
        xlswrite(fullfile(subpath,'Trough'),[arry(:,1),arry(:,2),arry(:,5)]);
        xlswrite(fullfile(subpath,'Diff'),[arry(:,1),arry(:,2),arry(:,6)]);


    else
        [ploco, tloco, statloco, termloco] = anovan(arry(:,4), {arry(:,3),arry(:,2)}, 'model',2,'varnames',{'session','treatment'});
        sprintf('Locomotion stats\np: %f', ploco)
        
        [plev, tlev, statlev, termlev] = anovan(arry(:,5), {arry(:,3),arry(:,2)}, 'model',2,'varnames',{'session','treatment'});
        sprintf('Lever stats\np: %f', plev)

        [ptro, ttro, stattro, termtro] = anovan(arry(:,6), {arry(:,3),arry(:,2)}, 'model',2,'varnames',{'session','treatment'});
        sprintf('Trough stats\np: %f', ptro)

        [pdiff, tdiff, statdiff, termdiff] = anovan(arry(:,7), {arry(:,3),arry(:,2)}, 'model',2,'varnames',{'session','treatment'});
        sprintf('Trough Lever Difference stats\np: %f', pdiff)

        % Col 1 : animal, Col 2: Treatment, Col 3: Session, Col 4: Behavioral Data (excel filename)
        xlswrite(fullfile(subpath,'HalfSeshLocomotion'),[arry(:,1),arry(:,2),arry(:,3),arry(:,4)]);
        xlswrite(fullfile(subpath,'HalfSeshLever'),[arry(:,1),arry(:,2),arry(:,3),arry(:,5)]);
        xlswrite(fullfile(subpath,'HalfSeshTrough'),[arry(:,1),arry(:,2),arry(:,3),arry(:,6)]);
        xlswrite(fullfile(subpath,'HalfSeshDiff'),[arry(:,1),arry(:,2),arry(:,3),arry(:,7)]);

    end
%     %% Repeated measures anova - Probably doesn't work
%     t = table(arry(:,2), arry(:,3),'VariableNames',{'Treatment','Locomotion'});%,'Lever','Trough','Diff'});
%     loco = table([1]', 'VariableNames', {'Measurements'});
%     rm = fitrm(t,'Locomotion-Locomotion~Treatment','WithinDesign',loco);
%     ranovatbl = ranova(rm)


end



