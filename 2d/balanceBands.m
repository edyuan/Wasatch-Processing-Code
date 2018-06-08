%function [band1spatial,band2spatial,balanceFunc, h] = balanceBands(band1,band2,coef_2dg,coef_3dg,ind)

%%--Initialize------------------------------------------------------------------
balanceFunc.balanceEnable = 1;
balanceAsFirst = 0;
balanceFunc.power = 5;
balanceFunc.autoROI = 0;%1;
balanceFunc.exclude_vessels = 0;%1;
balanceFunc.exclude_vessels_thr = 0.4;
balanceFunc.normThr = 0.2;
balanceFunc.stdSize = 1; %5;
balanceFunc.figVisEnable = 'on';

band1spatial=zeros(size(band1,1),size(band1,2),1);
band2spatial=zeros(size(band2,1),size(band2,2),1);
band1spatial(:,:,1)=band1;
band2spatial(:,:,1)=band2;

balanceEnable =1;
nFrames = 1;
nAscans = size(band1spatial,2);%band1saptial has been A-scan avg-ed
%---------------------------------------------------------------------------------
h = [];
if balanceEnable
         if (balanceFunc.exclude_vessels) && (size(band1spatial,3) >= balanceFunc.stdSize) %std size=5, exclude vessels=1 and enough Frames to do std
            speckVar = speckleVariance(band1spatial+band1spatial,balanceFunc.normThr,balanceFunc.stdSize); %band1spatia+band1spatial
            %specVar is 2048x51
        else
            speckVar = [];               
        end
        if (ind ==1)
            balanceFunc.func = []; %[];
            balanceFunc.ROI = []; % top, bottom, left, right, leave empty to mark the region
            balanceFunc.noise = [0 0];
            balanceFunc.meanNoiseLevel = [0 0];
        end
        [balanceFunc, h] = calcBalanceFunc_nonoiseremoval(medfilt2(mean(band1spatial,3),[4 4],'symmetric'),...
                                           medfilt2(mean(band2spatial,3),[4 4],'symmetric'),speckVar,balanceFunc,coef_2dg,coef_3dg); %specVar=0
   
    ROI = balanceFunc.ROI; %starts out empty
    
%     band1spatial = band1spatial - balanceFunc.meanNoiseLevel(1);
%     band1spatial(band1spatial<0) = min(band1spatial(band1spatial(:)>0));
%     band2spatial = band2spatial - balanceFunc.meanNoiseLevel(2);    
%     band2spatial(band2spatial < 0) = min(band2spatial(band2spatial(:)>0));
    
    band1spatial = band1spatial - balanceFunc.meanNoiseLevel(1); %meannoiselevel [0,0]by default but set to average noise in noise ROI after
    band1spatial(band1spatial<0) = 0; %everything less than 0 goes to 0
    band2spatial = band2spatial - balanceFunc.meanNoiseLevel(2);    %noise ROI everything below mean
    band2spatial(band2spatial < 0) = 0;
    
    band1spatialCrop = band1spatial(ROI(1):ROI(2),:,:);
    band1spatialCrop = band1spatialCrop./repmat(balanceFunc.func(:,1),[1 nAscans nFrames]);
    band2spatialCrop = band2spatial(ROI(1):ROI(2),:,:);
    band2spatialCrop = band2spatialCrop./repmat(balanceFunc.func(:,2),[1 nAscans nFrames]);
    
    band1spatial(ROI(1):ROI(2),:,:) = band1spatialCrop;
    band2spatial(ROI(1):ROI(2),:,:) = band2spatialCrop;
    
    %band1spatial = band1spatial + mean(balanceFunc.meanNoiseLevel);  %add mean noise level back?
    %band2spatial = band2spatial + mean(balanceFunc.meanNoiseLevel);
    
else
    band1spatial = band1spatial - balanceFunc.meanNoiseLevel(1);
    band1spatial(band1spatial<0) = 0;%min(band1spatial(band1spatial(:)>0));
    band2spatial = band2spatial - balanceFunc.meanNoiseLevel(2);
    band2spatial(band2spatial<0) = 0;%min(band2spatial(band2spatial(:)>0));
    band1spatial = band1spatial + mean(balanceFunc.meanNoiseLevel);
    band2spatial = band2spatial + mean(balanceFunc.meanNoiseLevel);
end