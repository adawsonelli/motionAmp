%% an example experimental script that performs a full analysis 

%% import and configure video

%inital config vars
videoName = 'drawStringTest';

%import video into a 4d matrix [y,x,t,color]

%downsample video to the appropriate y,x size

%save the downsized video to disk
% strcat(videoName,'_resampled')

%% amplify motion within the video

%init and config motionAmpConfig structure

%amplify video
ampVid = amplify(vid,motionAmpConfig); %[y,x,t,color], full color

%write to disk

%% develop a vector field from the amplified video

%develop vector field
vf = VectorField(ampVid); % return [y,x,t,vel(2)]?

%% segment the video into meaningful segments

segVid = segment(ampVid,vf); %return [y,x,t,color]