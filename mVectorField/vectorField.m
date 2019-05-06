function [outFrames, x, y, U, V] = vectorField(vid, coords, grid_MN, TW, SW)
%generates a vector field using explicit calculation of optic flow 
%inputs:
%   vid - video from which velocity will be extracted dim[y,x,t,color]
%   %(config parameters?)
% OutFrames will be [y, x, t, color]
%outputs:
%   vf - vector field dim[y,x,t,vel]
    [height, width, frames, colors] = size(vid);
    xmin = coords(1);
    ymin = coords(2);
    W = coords(3);
    H = coords(4);
    
    rowN = grid_MN(1);
    colN = grid_MN(2);

    %coords variable is [xmin ymin width height];
    
    %grid_MN = [30, 40] % Number of rows and cols in the grid
    
    orig_imsetting = iptgetpref('ImshowBorder');
    iptsetpref('ImshowBorder', 'tight');
    temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));
    outFrames = zeros(height,width,frames,colors,'single');
    outFrames(:,:,1,:) = vid(:,:,1,:);

    %Sample at a different rate
    step = 10;
    U = zeros([rowN, colN, frames]);
    V = zeros([rowN, colN, frames]);
    ind = 1;
    
    for i = 1:step-1:frames-step
        %Result = binary mask of quiver plot
        [x, y, U(:,:,i), V(:,:,i)] = computeFlow(vid(ymin:ymin+H,xmin:xmin+W,i,:), vid(ymin:ymin+H,xmin:xmin+W, i+(step-1), :), SW, TW, rowN, colN);
        ind = ind+1;
    end
    
    %Interpolate along the 3rd dimension (Manually, unfortunately)
    for i = 1:step-1:frames-step
        diffU = (U(:,:,i+(step-1)) - U(:,:,i))./(step-2) ;
        diffV = (V(:,:,i+(step-1)) - V(:,:,i))./(step-2) ;
        for j = 1:step-2
            U(:,:,i+j) = U(:,:, i+j-1) + diffU;
            V(:,:,i+j) = V(:,:, i+j-1) + diffV;
        end
    end

    %Loop through all frames-step, save as video
    for i=2:frames-step+2
        fh1 = figure('Visible','off'); 
        imshow(uint8(squeeze(vid(:,:, i, :))));
        hold on;
        %Seemed to need a median filter to cancel out noisy vectors that messed
        %up the scaling for the other points, in the ~flow images
        quiver(x+xmin, y+ymin , U(:,:,i-1), V(:,:,i-1), 'g');

        figure(fh1);
        set(fh1, 'WindowStyle', 'normal');
        image = getimage(fh1);
        truesize(fh1, [height, width]);
        frame = getframe(fh1);
        saveFrame = frame.cdata;
        outFrames(:,:,i,:) = saveFrame;
        close(fh1);
    
    end
    
    function [x, y, U, V] = computeFlow(colImg1, colImg2, rS, rT, rowN, colN)
        img1 = colImg1(:,:,1);
        img2 = colImg2(:,:,1);
        
        [rows, cols] = size(img1);

        %Taking care of boundary cases
        rowrange = floor(linspace(1+rS, rows-rS, rowN)); %yvals
        colrange = floor(linspace(1+rS, cols-rS, colN)); %xvals

        %Using cutoff method for boundry cases, as long as the window
        %half-size is not larger than the 2*step width
        [x,y] = meshgrid(colrange, rowrange);

        u = zeros( size(x) );
        v = zeros( size(y) );

        for yi = 1:rowN
            for xj = 1:colN

                pi = rowrange(yi);
                pj = colrange(xj);

                %Grab Template matrix, based on center coordinates
                T = img1(pi-rT:pi+rT, pj-rT:pj+rT);

                %Get Window matrix
                S = img2(pi-rS:pi+rS, pj-rS:pj+rS);

                %Compute Correlation (template, window)
                if sum(abs(diff(T))) == 0 %If the template window contains all the same values...
                    v(yi, xj) = 0;
                    u(yi, xj) = 0;

                else
                    C = normxcorr2(T, S);
                    [ypeak, xpeak] = find(C==max(C(:))); %in row, col
                    ypeak = ypeak(1); xpeak = xpeak(1);

                    y2 = ypeak(1)- rT+ pi - rS;
                    x2 = xpeak(1)- rT+ pj - rS;

                    v(yi,xj) = y2 - pi;%row, yvals 
                    u(yi,xj) = x2 - pj; %col, xvals

                end

            end
        end

        U = medfilt2(u, [5,5]);
        V = medfilt2(v, [5,5]);
        % Save img
%         orig_imsetting = iptgetpref('ImshowBorder');
%         iptsetpref('ImshowBorder', 'tight');
%         temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));
%         
%         fh1 = figure();
%         imshow(uint8(squeeze(colImg2)));
%         hold on;
%         %Seemed to need a median filter to cancel out noisy vectors that messed
%         %up the scaling for the other points, in the ~flow images
%         quiver(x, y, U, V, 'g');
% 
%         figure(fh1);
%         set(fh1, 'WindowStyle', 'normal');
%         image = getimage(fh1);
%         truesize(fh1, [rows, cols]);
%         frame = getframe(fh1);
%         pause(0.1);
%         outImg = frame.cdata;
        %size(result);
        
    end

%% reduce video to gray scale

%% explicitly calculate velocity ....


end

