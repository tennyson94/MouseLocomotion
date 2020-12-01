
function [ph, all_files, anov] = makeFigs(all_files, idx, entry, name, session, ph, anov)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
row = 1; count = 1; tempentry = 0;
name = num2str(cell2mat(name));
numzeros = length(find(idx == 0));
numsesh = length(idx) - numzeros;

if entry == 4
    anov = [];
    pathstring = strcat('Individuals_',date);
    subpath = strcat(pwd, strcat('\',pathstring));
    
   if ~exist(subpath,'dir')
       mkdir(sprintf(pathstring));

   end
end

    % Session length and half length
    len = length(find(all_files(1).strobeID == 19));
    halflen = len/2;

    % Between trial data
    bwtrial_x = [1:len];
    bwtrial_y_loc = zeros(length(idx),len);
    bwtrial_y_lever = zeros(length(idx),len);
    bwtrial_y_trough = zeros(length(idx),len);
    
for m = 1 : numsesh
i = idx(m);
    if i == 0 || count > length(idx)
        break;
    end
        count = count + 1;

    %% Behavioral columns - Sessionn Data
    % Reward delivery
    reward = find(all_files(i).strobeID == 19);
    all_files(i).reward = all_files(i).strobeTime(reward);
    % Lever press
    lever_press = find(all_files(i).strobeID == 18);
    all_files(i).lever = all_files(i).strobeTime(lever_press);
    % Trough Entry
    trough = find(all_files(i).strobeID == 20);
    all_files(i).trough = all_files(i).strobeTime(trough); 
    % Lever out
    lever_out = find(all_files(i).strobeID == 17);
    all_files(i).lever_out = all_files(i).strobeTime(lever_out);
    % Locomotion total
    all_files(i).loco = length(all_files(i).beamTime);
    % Locomotion by beam
    beamOne = find(all_files(i).beamID == 1);
    beamTwo = find(all_files(i).beamID == 2);
    beamThree = find(all_files(i).beamID == 3);
    beamFour = find(all_files(i).beamID == 4);
    all_files(i).one = all_files(i).beamTime(beamOne);
    all_files(i).two = all_files(i).beamTime(beamTwo);
    all_files(i).three = all_files(i).beamTime(beamThree);
    all_files(i).four = all_files(i).beamTime(beamFour);
    % Time between beam breaks
    for j = 2:length(all_files(i).beamTime)
    beamDif(j,1) = all_files(i).beamTime(j) - all_files(i).beamTime(j - 1); 
    end
    beamDifAvg(1,m) = mean(beamDif(2:length(beamDif)));
    % Find half time of session
    total_time = ceil(all_files(i).beamTime(length(all_files(i).beamTime)));
    half_time = total_time/2;
    
%% Create Histograms and trial data
    % Calculate bin centers for histogram, reward time +/- 15 s
    rew_bin_centers = -50:1:50;
    post_rew = 50; pre_rew = -50; 
    lev_bin_centers = -7:0;
    pre_lev = -7; post_lev = 0; 
    lev_win_pre = 0; post_lev_win = 7;
    % Session length and half length
    len = length(all_files(i).reward); 
    halflen = len/2;

    % Init counters
    nancount = 1; 
    nancount2 = 1;
    
if entry == 100
    entry = 5;
    tempentry = 1;
elseif entry == 101
    entry = 6;
    tempentry = 1;
end

if entry ~= 6
    if entry == 5
       len = halflen; 
    end

    % Find first latency response
    for k = 1 : len
        
        if k == len && entry ~= 5
            temp = find(all_files(i).lever >= all_files(i).lever_out(k));
                temp2 = find(all_files(i).trough >= all_files(i).lever_out(k));
        else
        
        temp = find(all_files(i).lever >= all_files(i).lever_out(k) &...
            (all_files(i).lever < all_files(i).lever_out(k+1)));
        temp2 = find(all_files(i).trough >= all_files(i).lever_out(k) &...
            (all_files(i).trough < all_files(i).lever_out(k+1)));
       
        end
        
        if temp
            first_lev(k,:) = (all_files(i).lever(temp(1)) ...
            - all_files(i).lever_out(k));
            nancount = nancount + 1;
        else
            first_lev(k,:) = nan;
        end
        if temp2
            first_tro(k,:) = (all_files(i).trough(temp2(1)) ...
                            - all_files(i).lever_out(k));
            nancount2 = nancount2 + 1;
        else
            first_tro(k,:) = nan;
        end
        
        clear temp; clear temp2;
    end

    % Iterate through all trials (all rewards)
    for k = 1 : len
        % Make lever-to-reward histogram
        lever_idx = find(all_files(i).lever <= (all_files(i).reward(k) + post_rew) & all_files(i).lever >= (all_files(i).reward(k) + pre_rew));
        lever_times = all_files(i).lever(lever_idx);
        lever_times_norm = lever_times - all_files(i).reward(k);
        lever_hist(k,:) = smooth2(hist(lever_times_norm,rew_bin_centers),0);
        
        % Repeat above during lever presentation
        lev_idx = find(all_files(i).lever <= (all_files(i).reward(k) + post_lev) & all_files(i).lever >= (all_files(i).reward(k) + pre_lev));
        lev_times = all_files(i).lever(lev_idx);
        lev_times_norm = lev_times - all_files(i).reward(k);
        lev_hist(k,:) = smooth2(hist(lev_times_norm, lev_bin_centers),0);
    
        % Make trough histogram
        trough_idx = find(all_files(i).trough <= (all_files(i).reward(k) + post_rew) & all_files(i).trough >= (all_files(i).reward(k) + pre_rew));
        trough_times = all_files(i).trough(trough_idx);
        trough_times_norm = trough_times - all_files(i).reward(k);
        trough_hist(k,:) = smooth2(hist(trough_times_norm,rew_bin_centers),0); 
        
        % Repeat above during lever presentation
        tro_idx = find(all_files(i).trough <= (all_files(i).reward(k) + post_lev) & all_files(i).trough >= (all_files(i).reward(k) + pre_lev));
        tro_times = all_files(i).trough(tro_idx);
        tro_times_norm = tro_times - all_files(i).reward(k);
        tro_hist(k,:) = smooth2(hist(tro_times_norm, lev_bin_centers),0); 
    
        % Get trial specific behavior
        % For each k, get trial start and end time 
        % If at the final trial, filter until end of session
        if k == len
        bwtrial_y_loc(m,k) = length(find(all_files(i).beamTime >= (all_files(i).lever_out(k)) & all_files(i).beamTime < (all_files(i).beamTime(length(all_files(i).beamTime)))));
        bwtrial_y_lever(m,k) = length(find(all_files(i).lever >= (all_files(i).lever_out(k)) & all_files(i).lever < (all_files(i).beamTime(length(all_files(i).beamTime)))));
        bwtrial_y_trough(m,k) = length(find(all_files(i).trough >= (all_files(i).lever_out(k)) & all_files(i).trough < (all_files(i).beamTime(length(all_files(i).beamTime)))));
        else
        bwtrial_y_loc(m,k) = length(find(all_files(i).beamTime >= (all_files(i).lever_out(k)) & all_files(i).beamTime < (all_files(i).lever_out(k + 1))));
        bwtrial_y_lever(m,k) = length(find(all_files(i).lever >= (all_files(i).lever_out(k)) & all_files(i).lever < (all_files(i).lever_out(k + 1))));
        bwtrial_y_trough(m,k) = length(find(all_files(i).trough >= (all_files(i).lever_out(k)) & all_files(i).trough < (all_files(i).lever_out(k + 1))));
        end

    end
    
else
    strt = ceil(length(all_files(i).reward)/2) + 1;
     % Find first latency response
    for k = strt : len
        
        if k ~= len
        temp = find(all_files(i).lever >= all_files(i).lever_out(k) &...
            (all_files(i).lever < all_files(i).lever_out(k+1)));
        temp2 = find(all_files(i).trough >= all_files(i).lever_out(k) &...
            (all_files(i).trough < all_files(i).lever_out(k+1)));
        else
        temp = find(all_files(i).lever >= all_files(i).lever_out(k));
        temp2 = find(all_files(i).trough >= all_files(i).lever_out(k));

        end
        
        if temp
            first_lev(nancount,:) = (all_files(i).lever(temp(1)) ...
            - all_files(i).lever_out(k));
        else
            first_lev(nancount,:) = nan;
        end
        if temp2
            first_tro(nancount,:) = (all_files(i).trough(temp2(1)) ...
                            - all_files(i).lever_out(k));
        else
            first_tro(nancount,:) = nan;
        end
        nancount = nancount + 1;
        clear temp; clear temp2;
    end
    % If analyzing the last half of the session, start at trial 14 - 25
        % Iterate through all trials (all rewards)
    for k = strt : len
        % Make lever-to-reward histogram
        lever_idx = find(all_files(i).lever <= (all_files(i).reward(k) + post_rew) & all_files(i).lever >= (all_files(i).reward(k) + pre_rew));
        lever_times = all_files(i).lever(lever_idx);
        lever_times_norm = lever_times - all_files(i).reward(k);
        lever_hist(k,:) = smooth2(hist(lever_times_norm,rew_bin_centers),0);
        
        % Repeat above during lever presentation
        lev_idx = find(all_files(i).lever <= (all_files(i).reward(k) + post_lev) & all_files(i).lever >= (all_files(i).reward(k) + pre_lev));
        lev_times = all_files(i).lever(lev_idx);
        lev_times_norm = lev_times - all_files(i).reward(k);
        lev_hist(k,:) = smooth2(hist(lev_times_norm, lev_bin_centers),0);
    end
    
    for k = strt : len
        % Make trough histogram
        trough_idx = find(all_files(i).trough <= (all_files(i).reward(k) + post_rew) & all_files(i).trough >= (all_files(i).reward(k) + pre_rew));
        trough_times = all_files(i).trough(trough_idx);
        trough_times_norm = trough_times - all_files(i).reward(k);
        trough_hist(k,:) = smooth2(hist(trough_times_norm,rew_bin_centers),0); 
        
        % Repeat above during lever presentation
        tro_idx = find(all_files(i).trough <= (all_files(i).reward(k) + post_lev) & all_files(i).trough >= (all_files(i).reward(k) + pre_lev));
        tro_times = all_files(i).trough(tro_idx);
        tro_times_norm = tro_times - all_files(i).reward(k);
        tro_hist(k,:) = smooth2(hist(tro_times_norm, lev_bin_centers),0); 
    end

end

%% Generate averages
    % For line plots
    lever_hist_mean(row,:) = mean(lever_hist);
    trough_hist_mean(row,:) = mean(trough_hist);
    
    % For bar graphs
    lev_hist_mean(row,:) = mean(lev_hist);
    tro_hist_mean(row,:) = mean(tro_hist);
    
    % For locomotion bar graphs
    loco_mean(row,:) = all_files(i).loco;
    beamOne_mean(row,:) = length(all_files(i).one);
    beamTwo_mean(row,:) = length(all_files(i).two);
    beamThree_mean(row,:) = length(all_files(i).three);
    beamFour_mean(row,:) = length(all_files(i).four);

    if entry == 5
        loco_mean(row,:) = length(find(all_files(i).beamTime < half_time));
        beamOne_mean(row,:) = length(find(all_files(i).one < half_time));
        beamTwo_mean(row,:) = length(find(all_files(i).two < half_time));
        beamThree_mean(row,:) = length(find(all_files(i).three < half_time));
        beamFour_mean(row,:) = length(find(all_files(i).four < half_time));
    end
    
    if entry == 6
        loco_mean(row,:) = length(find(all_files(i).beamTime >= half_time));
        beamOne_mean(row,:) = length(find(all_files(i).one >= half_time));
        beamTwo_mean(row,:) = length(find(all_files(i).two >= half_time));
        beamThree_mean(row,:) = length(find(all_files(i).three >= half_time));
        beamFour_mean(row,:) = length(find(all_files(i).four >= half_time));
    end
    
    
    % For first response latency
    latlev_mean(row,:) = nanmean(first_lev);
    lattro_mean(row,:) = nanmean(first_tro);
    % Save raw latency data in all_files
    all_files(i).latency_trough = first_tro;
    all_files(i).latency_lever = first_lev; 
    
    row = row + 1;
end

% Plot individual animals
if entry == 4
    % Average across sessions
    lever_histogram = mean(lever_hist_mean);
    trough_histogram = mean(trough_hist_mean);
    loco_avg = mean(loco_mean);
    beamOne_avg = mean(beamOne_mean);
    beamTwo_avg = mean(beamTwo_mean);
    beamThree_avg = mean(beamThree_mean);
    beamFour_avg = mean(beamFour_mean);
    
    f1 = figure;
    p = bar(rew_bin_centers, lever_histogram);
    title([name]);
    xlabel('Time from reward (s)');
    ylabel('Lever Press');
    
    f2 = figure;
    bar(rew_bin_centers, trough_histogram, 'r');
    title([name]);
    xlabel('Time from reward (s)');
    ylabel('Trough Entry');

    f3 = figure(3); hold all;
    bar(session, loco_avg, 'g');
    title([name]);
    ylabel('Locomotion');
    
    filename_lever = strcat([name], '_lever');
    filename_trough = strcat([name], '_trough');
    filename_loco = strcat([name], '_loco');
    saveas(f1, fullfile(subpath, filename_lever), 'jpg');
    saveas(f2, fullfile(subpath, filename_trough), 'jpg');
    saveas(f3, fullfile(subpath, filename_loco), 'jpg');

    hold off; 
end

if entry ~= 4 
     % Average across sessions for histograms
    lever_histogram = mean(lever_hist_mean);
    trough_histogram = mean(trough_hist_mean);

    % Calc difference score between trough and lever during the 8s CS
    dif_num_mean = tro_hist_mean - lev_hist_mean;
    dif_norm_mean = tro_hist_mean + lev_hist_mean;
    dif_hist_mean = dif_num_mean./dif_norm_mean;
    dif_hist_mean(find(isnan(dif_hist_mean))) = 0;
    
    % Average behavior across the 8s lever presentation
    for row = 1: size(lev_hist_mean,1)
        lev_avg1(row,:) = mean(lev_hist_mean(row,:));
        tro_avg1(row,:) = mean(tro_hist_mean(row,:));
        dif_avg1(row,:) = mean(dif_hist_mean(row,:));
    end
    
    % Time between beam breaks
    avg_beamDif = mean(beamDifAvg); 
    
    % For between trial analysis
    avg_bw_loc = mean(bwtrial_y_loc);
    avg_bw_trough = mean(bwtrial_y_trough);
    avg_bw_lever = mean(bwtrial_y_lever);
    
    % Average general behavior
    loco_avg = mean(loco_mean);
    beamOne_avg = mean(beamOne_mean);
    beamTwo_avg = mean(beamTwo_mean);
    beamThree_avg = mean(beamThree_mean);
    beamFour_avg = mean(beamFour_mean);
    
    % Average latency
    latlev_avg = nanmean(latlev_mean);
    lattro_avg = nanmean(lattro_mean); 
    
    % Std Error for bar graphs
    % Collapse across 8 columns (corresponding to the 8s lever
    % presentation)la
    % Histograms
    lev_histogram = mean(lev_avg1);
    tro_histogram = mean(tro_avg1);
    dif_histogram = mean(dif_avg1);
    
    % 8 s lever presentation
    lev_std = std(lev_avg1);
    tro_std = std(tro_avg1);
    dif_std = std(dif_avg1);
    loco_std = std(loco_mean);
    one_std = std(beamOne_mean);
    two_std = std(beamTwo_mean);
    three_std = std(beamThree_mean);
    four_std = std(beamFour_mean);
    
    % Time between beam breaks
    std_beamDif = std(beamDifAvg);
    
    % B/w trial averages
    bw_lever_std = std(bwtrial_y_lever);
    bw_trough_std = std(bwtrial_y_trough);
    bw_loco_std = std(bwtrial_y_loc);
    
    % Latencies
    latlev_std = nanstd(latlev_mean);
    lattro_std = std(lattro_mean);
    
    % Divide by square root of observations
    denom = sqrt(numsesh);
    
    std_beamDif = std_beamDif/denom;
    bw_lever_std = bw_lever_std/denom;
    bw_trough_std = bw_trough_std/denom;
    bw_loco_std = bw_loco_std/denom;
    lev_std = lev_std/denom;
    tro_std = tro_std/denom;
    dif_std = dif_std/denom;
    loco_std = loco_std/denom;
    one_std = one_std/denom;
    two_std = two_std/denom;
    three_std = three_std/denom;
    four_std = four_std/denom;
    latlev_std = latlev_std/denom;
    lattro_std = lattro_std/denom;
    
    %% Build ANOVA struct
    curridx = length(anov) + 1;
    % Save data into anov for case 99 - averaging across days for PRE
    % sessions
    
    if tempentry == 1
        if entry == 5 || entry == 6
        entry = 99;
        end
    end
    if entry == 99 
        anov(length(anov)).loco = mean(loco_mean);
        anov(length(anov)).lever = lev_histogram;
        anov(length(anov)).trough = tro_histogram;
        anov(length(anov)).diff = dif_histogram;
        anov(length(anov)).latlev = nanmean(latlev_mean);
        anov(length(anov)).lattro = nanmean(lattro_mean); 
        
    elseif entry == 2 || entry == 3 || entry == 5 || entry == 6
        if strcmp(name, 'PRE') ~= 1 
            
            if entry == 5
                tempsesh = 0;
            elseif entry == 6
                tempsesh = 1;
            end
            for i = 1:length(lev_avg1)
            anov(curridx).name = all_files(idx(i)).name;
            anov(curridx).treatment = name;
            if entry == 5 || entry == 6
                anov(curridx).sesh = tempsesh;
            end
            anov(curridx).loco = loco_mean(i);
            anov(curridx).lever = lev_avg1(i);
            anov(curridx).trough = tro_avg1(i);
            anov(curridx).diff = dif_avg1(i); 
            anov(curridx).latlev = latlev_mean(i);
            anov(curridx).lattro = lattro_mean(i);
            curridx = curridx + 1;
            end
        end
    end
    
   if entry == 1 || entry == 3 || entry == 5
    %% Plots / Bars
    f1 = figure(1); hold all; 
    ph(1,session) = plot(rew_bin_centers, lever_histogram);
    title('Lever Press aligned to reward');
    xlabel('Time from reward (s)');
    ylabel('Lever Press');
%     saveas(f1, fullfile(subpath,'overlayed_lever.jpg'));
    
    f2 = figure(2); hold all;
    ph(2,session) = plot(rew_bin_centers, trough_histogram);
    title('Trough Entry aligned to reward');
    xlabel('Time from reward (s)');
    ylabel('Trough Entry');
%     saveas(f2, fullfile(subpath,'overlayed_trough.jpg'));
    
    f3 = figure(3); hold all; 
    ph(3,session) = bar(session, lev_histogram); 
    ph(3,session).FaceColor = ph(1,session).Color;
    title('Lever Press across treatments');
    xlabel('Treatments');
    ylabel('Lever Press');
    err3 = errorbar(session, lev_histogram, lev_std);
    err3.Color = [0 0 0];
%     saveas(f3, fullfile(subpath,'lever_bar_trt.jpg'));
    
    f4 = figure(4); hold all; 
    ph(4,session) = bar(session, tro_histogram); 
    ph(4,session).FaceColor = ph(1,session).Color;
    title('Trough entry across treatments');
    xlabel('Treatments');
    ylabel('Trough entry');
    err4 = errorbar(session, tro_histogram, tro_std);
    err4.Color = [0 0 0];
%     saveas(f4, fullfile(subpath,'tro_bar_trt.jpg'));
    
    f5 = figure(5); hold all;
    ph(5,session) = bar(session, loco_avg);
    ph(5,session).FaceColor = ph(1,session).Color;
    title('Locomotion by treatment');
    xlabel('Treatments');
    ylabel('Locomotion Count');
    err5 = errorbar(session, loco_avg, loco_std);
    err5.Color = [0 0 0];
%     saveas(f5, fullfile(subpath, 'loco_bar_trt.jpg'));
    
    f6 = figure(6); hold all; 
    ph(6,session) = bar(session, dif_histogram); 
    ph(6,session).FaceColor = ph(1,session).Color;
    title('Trough - Lever Difference');
    xlabel('Treatments');
    ylabel('Trough - Lever');
    err6 = errorbar(session, dif_histogram, dif_std);
    err6.Color = [0 0 0];
%     saveas(f6, fullfile(subpath,'dif_bar_trt.jpg'));

    f7 = figure(7); hold all;   
    ph(7,session) = bar(session, latlev_avg); 
    ph(7,session).FaceColor = ph(1,session).Color;
    title('Latency for Lever Press from Lever Out');
    xlabel('Treatments');
    ylabel('Latency (s)');
    err7 = errorbar(session, latlev_avg, latlev_std);
    err7.Color = [0 0 0];
    
    f8 = figure(8); hold all;   
    ph(8,session) = bar(session, lattro_avg); 
    ph(8,session).FaceColor = ph(1,session).Color;
    title('Latency for Trough Entry from Lever Out');
    xlabel('Treatments');
    ylabel('Latency (s)');
    err8 = errorbar(session, lattro_avg, lattro_std);
    err8.Color = [0 0 0];
    
    f40 = figure(40); hold all;
    ph(40,session) = bar(session, avg_beamDif); 
    ph(40,session).FaceColor = ph(1,session).Color;
    title('Time between beam breaks by treatment');
    xlabel('Treatments');
    ylabel('Averge time between breaks (s)');
    err40 = errorbar(session, avg_beamDif, std_beamDif);
    err40.Color = [0 0 0];
    
   if entry ~= 5 && entry ~= 6
    beams = [1 2 3 4];
    beamdat = [beamOne_avg beamTwo_avg beamThree_avg beamFour_avg];
    beamerr = [one_std two_std three_std four_std];
    tit = strcat('Beam Count: ', [name]);
    tit2 = strcat([name], ' Trial ');
    f9 = figure(9 + session - 1); hold all;   
    ph(9 + session - 1,1) = bar(beams, beamdat); 
    ph(9 + session - 1,1).FaceColor = ph(1,session).Color;
    title(tit);
    xlabel('Treatments');
    ylabel('Counts');
    err9 = errorbar(beams, beamdat, beamerr);
    err9.Color = [0 0 0];
    err9.LineStyle = 'none';
    
    f20 = figure(20 + 3*(session - 1)); hold all;
    ph(20 + 3*(session - 1),1) = bar(bwtrial_x, avg_bw_loc);
    ph(20 + 3*(session - 1),1).FaceColor = ph(1,session).Color; 
    xlim([0 len + 1]);
    title(strcat(tit2,' Locomotion'));
    xlabel('Trial');
    ylabel('Average Locomotion per Trial');
    err20 = errorbar(bwtrial_x, avg_bw_loc, bw_loco_std);
    err20.Color = [0 0 0];
    err20.LineStyle = 'none';
    
    f21 = figure(21 + 3*(session - 1)); hold all;
    ph(21 + 3*(session - 1),1) = bar(bwtrial_x, avg_bw_lever);
    ph(21 + 3*(session - 1),1).FaceColor = ph(1,session).Color; 
    xlim([0 len + 1]);
    title(strcat(tit2,' Lever'));
    xlabel('Trial');
    ylabel('Average Lever Press per Trial');
    err21 = errorbar(bwtrial_x, avg_bw_lever, bw_lever_std);
    err21.Color = [0 0 0];
    err21.LineStyle = 'none';
    
    f22 = figure(22 + 3*(session - 1)); hold all;
    ph(22 + 3*(session - 1),1) = bar(bwtrial_x, avg_bw_trough);
    ph(22 + 3*(session - 1),1).FaceColor = ph(1,session).Color; 
    xlim([0 len + 1]);
    title(strcat(tit2,' Trough'));
    xlabel('Trial');
    ylabel('Average Trough Entry per Trial');
    err22 = errorbar(bwtrial_x, avg_bw_trough, bw_trough_std);
    err22.Color = [0 0 0];
    err22.LineStyle = 'none';
    
   end
   end
   
      if entry == 6
    %% Plots / Bars
    f10 = figure(10); hold all; 
    ph(10,session) = plot(rew_bin_centers, lever_histogram);
    title('Lever Press aligned to reward 2/2');
    xlabel('Time from reward (s)');
    ylabel('Lever Press');
%     saveas(f1, fullfile(subpath,'overlayed_lever.jpg'));
    
    f11 = figure(11); hold all;
    ph(11,session) = plot(rew_bin_centers, trough_histogram);
    title('Trough Entry aligned to reward 2/2');
    xlabel('Time from reward (s)');
    ylabel('Trough Entry');
%     saveas(f2, fullfile(subpath,'overlayed_trough.jpg'));
    
    f12 = figure(12); hold all; 
    ph(12,session) = bar(session, lev_histogram); 
    ph(12,session).FaceColor = ph(10,session).Color;
    title('Lever Press across treatments 2/2');
    xlabel('Treatments');
    ylabel('Lever Press');
    err12 = errorbar(session, lev_histogram, lev_std);
    err12.Color = [0 0 0];
%     saveas(f3, fullfile(subpath,'lever_bar_trt.jpg'));
    
    f13 = figure(13); hold all; 
    ph(13,session) = bar(session, tro_histogram); 
    ph(13,session).FaceColor = ph(10,session).Color;
    title('Trough entry across treatments 2/2');
    xlabel('Treatments');
    ylabel('Trough entry');
    err13 = errorbar(session, tro_histogram, tro_std);
    err13.Color = [0 0 0];
%     saveas(f4, fullfile(subpath,'tro_bar_trt.jpg'));
    
    f14 = figure(14); hold all;
    ph(14,session) = bar(session, loco_avg);
    ph(14,session).FaceColor = ph(10,session).Color;
    title('Locomotion by treatment 2/2');
    xlabel('Treatments');
    ylabel('Locomotion Count');
    err14 = errorbar(session, loco_avg, loco_std);
    err14.Color = [0 0 0];
%     saveas(f5, fullfile(subpath, 'loco_bar_trt.jpg'));
    
    f15 = figure(15); hold all; 
    ph(15,session) = bar(session, dif_histogram); 
    ph(15,session).FaceColor = ph(10,session).Color;
    title('Trough - Lever Difference 2/2');
    xlabel('Treatments');
    ylabel('Trough - Lever');
    err15 = errorbar(session, dif_histogram, dif_std);
    err15.Color = [0 0 0];
%     saveas(f6, fullfile(subpath,'dif_bar_trt.jpg'));

    f16 = figure(16); hold all;   
    ph(16,session) = bar(session, latlev_avg); 
    ph(16,session).FaceColor = ph(10,session).Color;
    title('Latency for Lever Press from Lever Out 2/2');
    xlabel('Treatments');
    ylabel('Latency (s)');
    err16 = errorbar(session, latlev_avg, latlev_std);
    err16.Color = [0 0 0];
    
    f17 = figure(17); hold all;   
    ph(17,session) = bar(session, lattro_avg); 
    ph(17,session).FaceColor = ph(10,session).Color;
    title('Latency for Trough Entry from Lever Out 2/2');
    xlabel('Treatments');
    ylabel('Latency (s)');
    err17 = errorbar(session, lattro_avg, lattro_std);
    err17.Color = [0 0 0];
    
    
    f41 = figure(41); hold all;
    ph(41,session) = bar(session, avg_beamDif); 
    ph(41,session).FaceColor = ph(1,session).Color;
    title('Time between beam breaks by treatment');
    xlabel('Treatments');
    ylabel('Averge time between breaks (s)');
    err41 = errorbar(session, avg_beamDif, std_beamDif);
    err41.Color = [0 0 0];
    
   
   end
end


end