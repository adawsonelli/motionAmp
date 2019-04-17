function [vid] = genSineWave(size,wl,amp)
%generate a Sine wave that can be used as a synthetic test image to
%evaluate the quality of the motion amplification and vector field
%inputs:
%   size - dim[y,x,t] of desired video
%   wl   - number of wave lengths across the y dimension
%   amp  - amplitude as a fraction of the x dimnsion (0-1]
%outputs:
%   vid  - video with a moving sinewave in it

%% generate the sinewave

"""
make a test video for evaluating motion amplification of a pure sign wave
"""

def genTestVideo():
    """
    adjust function signature in future...
    return: 3d np.array [x,y,t]
    """
    # define properties of the wave functions

    # wavelengths
    lambda_x = 20  #wavelength is [pixels / cycle]
    lambda_y = 100  #wavelength in [pixels / cycle]
    f_t = 2         #spacial frequency in [Hz]

    #amplitudes
    Ax = 127.5      #[gray levels]
    Ay = 0          #[pixels]
    At = 100        #[pixels]

    # initialize array of the appropriate size
    x = 800; y = 600 ;  t = 10 ; dt = .01
    tVec = np.arange(0,t,dt)
    xVec = np.arange(0,x)
    yVec = np.arange(0,y)

    video = np.zeros((x,y,len(tVec)), dtype = np.uint8)

    # populate array according to specified resolution and frequency
    for t in range(len(tVec)- 1):
        phi = np.sin(t/100)

        #populate video frame
        for row in range(y):
            video[:,row,t] = Ax * np.sin(xVec/lambda_x + .2*phi) + Ax


    return video

tst = genTestVideo()
print(tst.shape)



%duplicate it into 3 channels.

end
