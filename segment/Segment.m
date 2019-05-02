function [segVid] = Segment(featureMat,featureWeights)
%use k means clustering to develop a segmented video
%inputs: 
%   - feature mat - [x,y,t,feature] feature = [R G B vx vy ..] 
%output:
%   - segVid - segmented video [x,y,t,color]


%hyperparameters
elbowMethod = false;
if ~elbowMethod; k = 8; end
[y,x,frames,features] = size(featureMat);
segVid = zeros([y,x,frames,3]);

%define imsegkmeans
    function [L , C] = imsegkmeans(fm, k,Cprev,fws)
        %performs k means clustering on an image
        %inputs:
        %   fm - feature matrix dim[y,x,feature]
        %   k - number of groups
        %outputs:
        %   L - [y,x] - labeled pixels
        %   C - centroid locations from prev frame
        
        
        %flatten feature matrix into 2d feature matrix
        [yy,xx,fn] = size(fm);
        fm = reshape(fm,[yy*xx,fn]); %this should reshape the right way...maybe
        
        %normalize each col of feature matrix
        for ff = 1:fn
            fm(:,ff) = fm(:,ff) ./ max(fm(:,ff));
        end
        
        %adjust column magnitude according to feature weights:
        if length(fws) ~= fn
            error(strcat('feature weights must be ', num2str(fn) ,' numbers long'))
        end
        fm = fm*diag(fws); 
        
        %perform kmeans
        [idx,C] = kmeans(fm,k);  % C dim[k,features]
        
        %fix index switching problem between frames by finding the best
        %matching labels, relative to the previous frame
        
        %find best matching labels
        minSum = 10^9; perm = 1:k;
        for shuffle = 1:1000
            ptest = randperm(k);
            s = norm(Cprev(:,4:5) - C(ptest,4:5));
            if s < minSum
                perm = ptest;
                minSum = s;
            end
        end
        
        %try random sample consensus instead of inverse??
        
        %form permInv (maps from new -> old)
        [~,permInv] = sort(perm);
        
        %swap said labels, sort C
        for id=1:length(idx)
            idx(id) = permInv(idx(id)); %swap labels!!
        end
        C = C(permInv,:);
        
        %re-assemble image map
        L = reshape(idx,[yy,xx]);
        
        
    end


%find the best number of groups over all frames w/ elbow method.
% from future import....


%for each frame, perform k-means
C = zeros(k,features + 2); % matrix of centroid locations 
for f = 1:frames
    
    %print updates so we know it's not Frozen (although I'm trying to let
    %it goooooo!)
    disp(strcat('frame ',num2str(f),'of ',num2str(frames)))
    
    %create a feature matrix[x,y,features]
    fv = squeeze(featureMat(:,:,f,:));
    [X,Y] = meshgrid(1:x,1:y);
    fv = cat(3,fv,X,Y);               %tack on x and y as features
    
    %perform segmentation
    [L,C] = imsegkmeans(fv,k,C,featureWeights);
    
    %segmentation -> color overlayed image
    img = squeeze(featureMat(:,:,f,1:3));  %RGB are first 3 values
    segImg = imoverlay(img,L); %'FaceAlpha',.995);
    
    %store in segVid
    segVid(:,:,f,:) = segImg;
    
end

end

