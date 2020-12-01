
function [ph, coords, anov] = makeLocoFigs(coords, idx, entry, name, session, ph, anov)

row = 1; count = 1; tempentry = 0;
name = num2str(cell2mat(name));
numzeros = length(find(idx == 0));
numsesh = length(idx) - numzeros;
fps = 30; 
mouse_ct = 1;

for midx = 1 : numsesh
    i = idx(midx);
    % Verify that no session is a 0 (helps avoid crashes)
    % A 0 in idx can occurr if there are unequal number of sessions for a
    % treatment group
    if i == 0 || count > length(idx)
        break;
    end
    count = count + 1;
    
    
    if entry == 1 || entry == 2
        % Time vector for plot3
        T = coords(i).frames;
        timevect = 1:T;
        % z- axis
        timevect_s = timevect/fps;
        
        %% CREATE HEATMAP
        % Find min and max for x y
        xmax = max(coords(i).x);
        xmin = min(coords(i).x);
        ymax = max(coords(i).y);
        ymin = min(coords(i).y);
        
        % Create segmentation constant
        segx = (xmax - xmin)/12;
        segy = (ymax - ymin)/8;
        
        % Segmentation of the 12 x 8 grid
        % x seg
        n = 1 : 13;
        x = zeros(13, 1);
        x(n) = (n-1)*segx;
        % y seg
        m = 1 : 9;
        y = zeros( 9, 1);
        y(m) = (m-1)*segy;
        
        % Create empty array for grid
        mouse(mouse_ct).gridpos = zeros(8,12);
        
        % Iterate through x dimension
        for n = 1:12;
            % Iterate through y dimension
            for m = 1:8;
                % Iterate through frames where tracking occurred
                for k = 1:coords(i).frames
                    % If current trajectory falls within x
                    if ((x(n + 1) + xmin) >= coords(i).x(k)) && ...
                            (coords(i).x(k) >= (x(n) + xmin));
                        % Within y
                        if ((y(m + 1) + ymin) >= coords(i).y(k)) && ...
                                (coords(i).y(k) >= (y(m) + ymin));
                            mouse(mouse_ct).gridpos(m,n) = mouse(mouse_ct).gridpos(m,n) + 1;
                        end
                    end
                end
            end
        end
        
        % Flip heatmap vertically to match video
        mouse(mouse_ct).gridpos = flipud(mouse(mouse_ct).gridpos);
        
        if entry == 2
            % Plot individual figures
            %Figure 1
            figure
            title('3D view');
            hold on
            plot3(coords(i).x,coords(i).y, timevect_s, 'r')
            view([-30 20])

            %Figure 2
            figure
            title('Mouse coordinates');
            hold on
            plot(coords(i).x,coords(i).y, 'r')
            box off

            figure
            image(mouse(mouse_ct).gridpos,'CDataMapping','scaled')
        end
        mouse_ct = mouse_ct + 1;

    end

end

    if entry == 1
        gridsum = zeros(8,12);
        % Average over heatmaps in mouse for the current trt group
        for a = 1:length(mouse)
            gridsum = gridsum + mouse(a).gridpos;
        end
        % Divide by number of animals (a)
        gridsum = gridsum ./a;
        
        % Plot this grid for current trt group
        figure
        image(gridsum,'CDataMapping','scaled');
        title(strcat(name, ' Average Heatmap'));
        
    end
