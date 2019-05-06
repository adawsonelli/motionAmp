%% an example experimental script that performs a full analysis 

%% import and configure video

%inital config vars
%videoName = 'drawStringTest';
videoName = 'forcedBreathing1';
%videoName = 'rolling';
rsName  = strcat(videoName,'_resampled');
ampName = strcat(videoName,'_amplified');
vfName  = strcat(videoName,'_vectorField');
segName = strcat(videoName,'_segmented');


%% downsample video to the appropriate y,x size

%import video into a 4d matrix [y,x,t,color]
vid = utils.importVid(videoName);

% select the downsampling method of your choosing
dsMethod = 0;
height = 600; width = 800; sf = .5;

switch dsMethod
    %downsample by scale factor
    case 0
        vid = imresize(vid, .5);
    %maintain aspect ratio, fix height  
    case 1
        vid = imresize(vid, [height NaN]);
    %maintain aspect ratio, fix width
    case 2
        vid = imresize(vid, [NaN width]);
    %change aspect ratio
    case 3
        vid = imresize(vid, [height width]);
        
end

%save the downsized video to disk
utils.saveVid(vid,rsName);

%% amplify motion within the video

%clear globally scoped instance of vid
clear vid

%init and config motionAmpConfig structure
alpha = 5;
Fpass = [.5 1.5];  %passBand
fs = 30;

%amplify video
ampVid = Amplify(rsName,alpha,Fpass,fs); %return [y,x,t,color]

%
%write to disk
utils.saveVid(ampVid,ampName);
disp("Done Amplifying");
%% develop a vector field from the amplified video

%Sample routine, starting with an already-loaded video file
%vid = utils.importVid('forcedBreathing1_amplified');

%Get coordinates for a bounding box so we don't calculate vector field in the whole video
coords = utils.chooseTarget(vid); %outputs [xmin ymin width height]
SW = 10;   % Half size of the search window
TW = 6; % Half size of the template window 
grid_MN = [40, 50]; %inputs are [rows, cols] resolution size
[outFrames, x, y, U, V] = vectorField(vid, coords, grid_MN, TW, SW); % return [y,x,t,vel(2)]?

%Note that U,V are inside the bounding box from variable 'coords'
%If you want these U,V coordinates in the 'reference frame' of the image
%dimensions, use (x+xmin, y+ymin) from a [x,y] = meshgrid of the bounding box

utils.saveVid(outFrames,'BreathingVectors');
disp("Done!");

%% Get airflow at different slice heights
SW = 10;   % Half size of the search window
grid_MN = [40, 50];
[rows, cols, frames, ~] = size(vid);
rowN = grid_MN(1);
colN = grid_MN(2);
rowrange = floor(linspace(1+SW, rows-SW, rowN)); %yvals
colrange = floor(linspace(1+SW, cols-SW, colN)); %xvals
[ex,ey] = meshgrid(colrange, rowrange);

imshow(uint8(vid(:,:,1)))
[height, width] = ginput(1);
% convert overall dimensions, numus ymin, consider smaller resolution...
ymin = coords(2);
wHeight = coords(4);
approxheight = ceil((height - ymin)/(wHeight/rowN));

magnitudes = (U.^2 + V.^2).^(1/2); %since U,V, are already in the form (x2-x1), (y2-y1)

%Plot things
[Nx,Ny] = meshgrid(1:frames, 1:grid_MN(2));
figure;
surf(Nx, Ny, squeeze(magnitudes(approxheight,:,:)))
ylabel("Horizontal Axis"); xlabel("Time"); zlabel("Vector Magnitudes");

%% Save surf plots
orig_imsetting = iptgetpref('ImshowBorder');
iptsetpref('ImshowBorder', 'tight');
temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));
[Mx,My] = meshgrid(1:grid_MN(2), 1:grid_MN(1));

for i=1:frames-1

    fh1 = figure('Visible','off'); 
    surf(Mx, My, squeeze(magnitudes(:,:,i)))
    set(gca, 'YDir','reverse')
    zlim([0 12]) 
    view([-35 66])
    figure(fh1);
    set(fh1, 'WindowStyle', 'normal');
    image = getimage(fh1);
    %truesize(fh1, [height, width]);
    frame = getframe(fh1);
    saveFrame = frame.cdata;
    outFrames(:,:,i,:) = saveFrame;
    close(fh1);
end
%
utils.saveVid(outFrames,'3DPlots');
disp("Done!");

%% segment the video into meaningful segments from RGB features

%read in video
featureMat = utils.importVid(videoName);

%segment
segVid = Segment(featureMat,ones(5,1)); %return [y,x,t,feature]

%save
utils.saveVid(segVid,segName)
