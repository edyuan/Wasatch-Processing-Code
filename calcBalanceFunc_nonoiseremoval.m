function [balanceParams, h] = calcBalanceFunc(band1spatial,band2spatial,speckVar,balanceParams,coef_2dg,coef_3dg)

noise = balanceParams.noise;                   % noise=[0,0]
meanNoiseLevel = balanceParams.meanNoiseLevel; %[0,0]
funcPower = balanceParams.power;                %5
figVisEnable = balanceParams.figVisEnable;      %'on'

if balanceParams.autoROI
    %balance mask (largest connected component), noiseMask both 2048x51
    [balanceMask, noiseMask, ~] = detectTissue(band1spatial+band2spatial); %band1spatial band2spatial, frame averaged, 2048x51      
    ROI(1) = find(sum(balanceMask,2) > 10,1,'first');  %find position with width more than 10 pixels across
    ROI(2) = find(sum(balanceMask,2) > 10,1,'last');   %ROI 1,2 bounding z positions
    ROI(3) = 1;
    ROI(4) = size(band1spatial,2);     %ROI 3,4 entire reduced width

    balanceParams.ROI = ROI;
else
    if isempty(balanceParams.ROI)
        figh = figure('name','Mark a region according which to balance');
        set(figh, 'Visible', figVisEnable)
        imagesc(log((band1spatial+band2spatial)/2));
        title(['B=',num2str(coef_2dg),'  C=',num2str(coef_3dg)]);
        colormap gray;
        rect = round(getrect);
        balanceParams.ROI(1) = rect(2); % top
        balanceParams.ROI(2) = rect(2)+rect(4)-1; % bottom
        balanceParams.ROI(3) = rect(1); % left
        balanceParams.ROI(4) = rect(1)+rect(3)-1; % right
        
    end
    
    ROI = balanceParams.ROI;    
    balanceMask = zeros(size(band1spatial));
    balanceMask(ROI(1):ROI(2),ROI(3):ROI(4)) = 1;
    
    if isempty(noise) || isempty(meanNoiseLevel) || any(noise == 0) || any(meanNoiseLevel == 0),
        figh = figure('name','Mark a region of noise');
        set(figh, 'Visible', figVisEnable)
        imagesc(log(abs(band1spatial+band2spatial)));
        colormap gray;
        rect = round(getrect);
        c = rect(1); r = rect(2); w = rect(3); h = rect(4);
        noiseMask = zeros(size(band1spatial));
        noiseMask(r:r+h,c:c+w) = 1;
    end
end

if balanceParams.exclude_vessels && ~isempty(speckVar)  %specVar not empty and want to exclude vessels
    speckVar = speckVar - min(speckVar(:));  %subtract out minimum specVar value
    speckVar = speckVar/max(speckVar(:));    %normalize by maximum specVar value
    vesselMask = speckVar > balanceParams.exclude_vessels_thr; %exclude thr=0.4
    balanceMask(vesselMask == 1) = 0;   %in the balance mask exclude everywhere there is a vessel
end

bandSpatial(:,:,1) = band1spatial;
bandSpatial(:,:,2) = band2spatial;
nRows = ROI(2)-ROI(1)+1;
nCols = ROI(4)-ROI(3)+1;

if isempty(noise) || isempty(meanNoiseLevel) || any(noise == 0) || any(meanNoiseLevel == 0),%noise=[0 0]
    for ind = 1:2
        band = bandSpatial(:,:,ind);        %band is 2048x51
        noiseROI = band;                    %2048*51=104448
        noiseROI = noiseROI(noiseMask == 1); %isolates part of image below mean, %noiseROI: 81313
        meanNoiseLevel(ind) = mean(noiseROI(:)); 
        noise(ind) = std(noiseROI(:));
    end
end
for ind = 1:2
    band = bandSpatial(:,:,ind);    %band is 2048x51
    band = band - meanNoiseLevel(ind);     %meanNoiseLevel computed above
    band(band<0) = min(band(band(:)>0));   %band(band(:)>0) same as band(band>0), 582561x1, set all elemnt of band <0 to min value
    band = wiener2(band,[5 5]);   
    band = band.*balanceMask;  %balance mask determined by ROI if ROI is selected
    bandSpatial(:,:,ind) = band;
end

meanSig = zeros(nRows,2);  %376x2
gain = zeros(nRows,2);
x = [1:nRows]';
for rowInd = 1:nRows
    b1 =  bandSpatial(ROI(1)+rowInd-1,:,1);  %rows within the ROI
    b2 =  bandSpatial(ROI(1)+rowInd-1,:,2);  %image is largest connected component, wiener filtered
  

    meanSig(rowInd,1) = mean(b1);
    meanSig(rowInd,2) = mean(b2);
    meanb1b2 = (mean(b1) + mean(b2))/2;
    gain(rowInd,1) = meanSig(rowInd,1)/meanb1b2; %gain is normalized by average in both bands mean sig
    gain(rowInd,2) = meanSig(rowInd,2)/meanb1b2;
end


h(1) = figure;
set(h(1), 'Visible', figVisEnable);     
plot(x,meanSig(:,1),'.-r'); hold on; plot(x,meanSig(:,2),'.-b');

% h(2) = figure;
% set(h(2), 'Visible', figVisEnable)
% hold on;
% plot(x,gain(:,1),'b:');
% plot(x,gain(:,2),'r:');

P1 = polyfit(x,gain(:,1),funcPower);
P2 = polyfit(x,gain(:,2),funcPower); %funcPower=5

x = [1:nRows]';
fitGainFunc = zeros(length(x),2);  %x returned to full ROI length
for ind = 0:funcPower
    fitGainFunc(:,1) =  fitGainFunc(:,1) + P1(funcPower-ind+1)*x.^ind;
    fitGainFunc(:,2) =  fitGainFunc(:,2) + P2(funcPower-ind+1)*x.^ind;
end
plot(fitGainFunc(:,1),'b')
plot(fitGainFunc(:,2),'r')

% h(3) = figure;
% set(h(3), 'Visible', figVisEnable)
% diff_image = bandSpatial(:,:,1) - bandSpatial(:,:,2); %balancemasked bandSpatial
% subplot(2,1,1); imagesc(diff_image); caxis([-1 1]); title('Before balance')
% 
% diff_image_temp = bandSpatial(ROI(1):ROI(2),:,1)./repmat(fitGainFunc(:,1),[1 size(bandSpatial,2)]) - bandSpatial(ROI(1):ROI(2),:,2)./repmat(fitGainFunc(:,2),[1 size(bandSpatial,2)]);
% 
% diff_image(ROI(1):ROI(2),:) = diff_image_temp;
% subplot(2,1,2); imagesc(diff_image); caxis([-1 1]); title('After balance'); 
% 
%----------------------------------------------------------------------------------------------------
% h(4) = figure;
% set(h(4), 'Visible', figVisEnable)
% diff_image_orig = band1spatial - band2spatial; %balancemasked bandSpatial
% diff_image_orig = diff_image_orig(100:end,:);
% h=surf(diff_image_orig); set(h,'LineStyle','none'); title('Before balance')
% colorbar;
% 
% close;
% 
% h(5) = figure;
% diff_image_temp_orig = band1spatial(ROI(1):ROI(2),:)./repmat(fitGainFunc(:,1),[1 size(bandSpatial,2)]) - band2spatial(ROI(1):ROI(2),:)./repmat(fitGainFunc(:,2),[1 size(bandSpatial,2)]);
% diff_image_orig = band1spatial - band2spatial;
% diff_image_orig(ROI(1):ROI(2),:) = diff_image_temp_orig;
% diff_image_orig = diff_image_orig(100:end,:);
% h=surf(diff_image_orig); set(h,'LineStyle','none'); title('After balance'); 
% colorbar;
% 
% close;
%--------------------------------------------------------------------------------------------------------------------------

balanceParams.noise = noise;
balanceParams.meanNoiseLevel = meanNoiseLevel;
balanceParams.func = fitGainFunc;
% 
% h(4) = figure;
% set(h(4), 'Visible', figVisEnable)
% imagesc(balanceMask)
