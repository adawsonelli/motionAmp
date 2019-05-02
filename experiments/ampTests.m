%% test amplitude magnification process against synthesized input images



%% test 1 - horizontal, high spacial freq

%-----------test 1 original -----------
name = 'test1_orig';

%shape = [512, 512, 100];
shape = [256, 256, 100];
lambda = 100;       
lamp = 1;             
orientation = 0;

dt = 1/30;            
phaseAmp = .5;           
freq = 2; 

%make and save vid
vid = genSineWave(shape,lambda,lamp,orientation,dt,phaseAmp,freq);
utils.saveVid(vid,name);
clear vid

%%
%--------make confirmation image ----------
name = 'test1_conf';
phaseAmp = 5;

%make and save vid
vid = genSineWave(shape,lambda,lamp,orientation,dt,phaseAmp,freq);
utils.saveVid(vid,name);
clear vid


%%
%--------make amplified image ----------
name = 'test1_motionAmp';

%init and config motionAmpConfig structure
alpha = 10;
Fpass = [1 3];  %passBand
fs = 30;

%amplify video
vid = amplify('test1_orig',alpha,Fpass,fs); %return [y,x,t,color]

%make and save vid
utils.saveVid(vid,name);
clear vid

%% test 2 - horizontal, low spacial freq


%%  test 3 - 