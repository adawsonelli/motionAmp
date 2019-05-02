function [vid] = genSineWave2(shape,lambda,lamp,orientation,dt,phaseAmp,freq)
%GENSINEWAVE2 make a sine wave video with the specified parameters
% inputs:
%%spacial vars
%   shape       - [pixels,pixels,frames] [y x t] matrix 
%   lambda      - [pixels/cycle] period of the sinusoid 
%   lamp        - [0-1] luminance amplitude
%   orientation - [rad] orientation of the sine wave
%%temporal vars    
%   dt          - [sec] time between frames               
%   phaseAmp    - [pixels] amplitude of the changing phase 
%   freq        - [1/sec] frequency of oscillation 
% output:
%   


%define default arguments
if ~exist('size')        ; shape   = [512,512,100] ; end
if ~exist('lambda')      ; lambda = 100            ; end
if ~exist('lamp')        ; lamp = 1                ; end
if ~exist('orientation') ; orientation = 0         ; end
if ~exist('dt')          ; dt = 1/30               ; end
if ~exist('phaseAmp')    ; phaseAmp = 3            ; end
if ~exist('freq')        ; freq = 2                ; end


%make 4D array from parameters
sz = shape(1:2); frames = shape(3);
vid = zeros([shape,3],'single');
for f=1:frames
    phasePixels = phaseAmp * sin(2*pi*freq*(f*dt));     %[pixels]
    phase = (1/lambda) * phasePixels * 2*pi;            %[rad]
    swv = mkSine(sz, lambda, orientation, lamp, phase); %[-1 1]
    for ch=1:3
        vid(:,:,f,ch) = uint8(((swv + 1)/2)*255);            %[0-255]
    end
   
end

% something is possibly off by a scale factor?? - look into if required.


end

