function [ampVid] = amplify(vid,alpha,Fpass,fs)
%amplify the motion in a video using a phase-based, eulerian approach that 
%relys on steerable pyramids

%inputs:
%   vid - the video to be analyized dim[y,x,t,color]
%   alpha - the scale factor by which the phase information should be
%   amplified
%   Fpass - [lower upper] Hz
%   fs - sample frequency in Hz
%
%outputs:
%   ampVid - video containing amplified motion dim[y,x,t,color]


%% make it work

%set configuration parameters.
height = 3;                         %number of levels in the pyramid 
nBands = 4;                         %number of orientations in the pyramid
order = nBands - 1;                 %order of the steerable filter
if ~exist('fs'); fs = 30; end       %default sampling frequency
ampVid = zeros(size(vid));          %preallocate ampVid

%for each color channel
for ch = 1:3
    
    %make a 3D matrix from just this color channel
    chVid = squeeze(vid(:,:,:,1));
    frames = size(chVid,3);
    
    %init pyramid data structure
    [pyr,pind] = buildSCFpyr(chVid(:,:,1),height,order);
    PYR = zeros(length(pyr),frames);
    
    %for each frame, construct a pyramid and populate PYR
    for f = 1:frames
        PYR(:,f) = buildSCFpyr(chVid(:,:,f),height,order);
    end
    
    %separate out the phase and magnitude into 2 channels
    phase = angle(PYR);
    magnitude = abs(PYR);
    
    %bandpass filter the phase along the time dimension
    order = 2;   %order of filter
    [b,a] = butter(order,Fpass/(fs/2),'bandpass');
    bpPhase = filtfilt(b,a,phase')';           
     
    %amplify the phase
    bpPhase = alpha * bpPhase; 
    
    %combine with original phase
    ampPhase = phase + bpPhase;
    
    %convert into cartesian coordinates (complex numbers)
    ampPYR = magnitude.*exp(1i*phase);
    
    %convert pyramids back to frames
    ampChvid = zeros(size(chVid));
    for f = 1:frames
        ampChvid(:,:,f) = reconSCFpyr_Alex(ampPYR(:,f),pind);
    end
    
    %write amplifyed video into ampVid 
    ampVid(:,:,:,ch) = ampChvid;
    
end

