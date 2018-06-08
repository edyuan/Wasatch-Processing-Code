

for coef_3dg=[0:1:10]
    coef_3dg
    coef_2dg=-20;

        %% Script to build B-scan from raw spectrum data
    build_b_scan_volume % windowing of A-scans here: w=window(@hann,bscan_pixel_height);
                     % ascan1=w.*corrected_data_k'. To avoid windowing use: 
                     % ascan1=corrected_data_k'; instead. We usually use hanning
                     % window as determined by @hann parameter.
    a = fourier_unwrapped (1:end/2,:);
    rotangle =24.8; crop = [1370:1530];
    Brot=imrotate(a,rotangle);
    Bcrop=Brot(crop,:);
    
    figure; imagesc(log(Bcrop),[6 10]); colormap(gray); title(strcat('dispersion c: ',num2str(coef_2dg), '   dispersion d: ', num2str(coef_3dg)))
   
end






