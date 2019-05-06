function [ampVid] = Amplify(vidName,alpha,Fpass,fs)
%amplify the motion in a video using a phase-based, eulerian approach that 
%relys on steerable pyramids

%inputs:
%   vidName name of the video to be analyized -> dim[y,x,t,color]
%   alpha - the scale factor by which the phase information should be
%   amplified
%   Fpass - [lower upper] Hz
%   fs - sample frequency in Hz
%
%outputs:
%   ampVid - video containing amplified motion dim[y,x,t,color]


%% make it work

%import full video
vid = utils.importVid(vidName);

%set configuration parameters.
height = 3;                         %number of levels in the pyramid 
nBands = 4;                         %number of orientations in the pyramid
order = nBands - 1;                 %order of the steerable filter
if ~exist('fs'); fs = 30; end       %default sampling frequency

%import the video
ampVid = zeros(size(vid),'single'); %preallocate ampVid

%for each color channel
for ch = 1:3
    
    %extract frames
    frames = size(vid,3);
    
    %init pyramid data structure
    [pyr,pind] = buildSCFpyr(squeeze(vid(:,:,1,ch)),height,order);
    PYR = zeros(length(pyr),frames,'single');
    
    %for each frame, construct a pyramid and populate PYR
    for f = 1:frames
        PYR(:,f) = buildSCFpyr(squeeze(vid(:,:,f,ch)),height,order);
    end
   
    %separate out the phase and magnitude into 2 channels
    phase = angle(PYR);
    magnitude = abs(PYR);
    clear PYR
    
    %bandpass filter the phase along the time dimension
    order = 2;   %order of filter
    [b,a] = butter(order,Fpass/(fs/2),'bandpass');
    phase = double(phase); %input arguments must be of type double
    bpPhase = single(filtfilt(b,a,phase')');           
     
    %amplify the phase
    ampPhase = phase + (alpha * bpPhase); 
    clear bpPhase phase

    %convert into cartesian coordinates (complex numbers)
    ampPYR = magnitude.*exp(1i*ampPhase);
    clear ampPhase magnitude
    
    %convert pyramids back to frames
    for f = 1:frames
        ampVid(:,:,f,ch) = reconSCFpyr_Alex(ampPYR(:,f),pind);
    end
    clear ampPYR 
    
    
end

