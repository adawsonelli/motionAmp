classdef utils
    %UTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function vid = importVid(fileName)
            %import a video from the data directory into the workspace as a
            %4D - array
            
            %init VideoReader object
            vidPath = strcat('../data/',fileName,'.mp4');
            vr = VideoReader(vidPath);
            nColorChannels = 3;
            vid = zeros(vr.Height,vr.Width,vr.NumberOfFrames,nColorChannels,'single');
            
            %have to recreate vr after reading numberofframes....wierd
            vr = VideoReader(vidPath);
            
            %read frames into vid
            fr = 1;
            while hasFrame(vr)
                vid(:,:,fr,:) = readFrame(vr);
                fr = fr + 1;
            end
           
        end
        
        function saveVid(vid,fileName)
            %saves a 4D array of the form [y,x,t,color] into a .mp4 file in
            %the data directory
            
            
            %setup video writer
            fn = strcat('../data/',fileName,'.mp4');
            v = VideoWriter(fn,'MPEG-4');
            frames = size(vid,3);
            
            %write each frame
            open(v)
            for f = 1:frames
                frame = uint8(squeeze(vid(:,:,f,:)));
                writeVideo(v,frame)
            end
            close(v)
                    
        end
        
        function rect = chooseTarget(vidImg)
            % chooseTarget displays an image and asks the user to drag a rectangle
            % around a tracking target
            % 
            % arguments:
            % data_params: a structure contains data parameters
            % rect: [xmin ymin width height]

            % Reading the first frame from the video stack
            img = vidImg(:,:,1);

            % Pick an initial tracking location
            fig = figure;
            imshow(uint8(img));
            %disp('===========');
            %disp('Drag a rectangle around the tracking target: ');
            h = imrect;
            rect = round(h.getPosition);

            % To make things easier, let's make the height and width all odd
            if mod(rect(3), 2) == 0, rect(3) = rect(3) + 1; end
            if mod(rect(4), 2) == 0, rect(4) = rect(4) + 1; end
            %str = mat2str(rect);
            %disp(['[xmin ymin width height]  = ' str]);
            %disp('===========');
            close(fig);
        end
            
    end
    
end

