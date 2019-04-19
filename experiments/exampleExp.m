%% an example experimental script that performs a full analysis 

%% import and configure video

%inital config vars
videoName = 'drawStringTest';
rsName = strcat(videoName,'_resampled');

%import video into a 4d matrix [y,x,t,color]
vid = utils.importVid(videoName);

%% downsample video to the appropriate y,x size
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

%import video
vid = utils.importVid(rsName);

%init and config motionAmpConfig structure

%amplify video
ampVid = amplify(vid,motionAmpConfig); %[y,x,t,color], full color

%write to disk

%% develop a vector field from the amplified video

%develop vector field
vf = VectorField(ampVid); % return [y,x,t,vel(2)]?

%% segment the video into meaningful segments

segVid = segment(ampVid,vf); %return [y,x,t,color]