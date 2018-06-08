    % This software was developed by Wasatch Photonics for Standford University
% and intent for the internal use only. All right reserved by Wasatch
% Photonics. For any further questions please call 919-544-7785, or e-mail
% to: info@wasatchphotonics.com.
%% clean up command window and erase variables
clc
clearvars -except I2 fourier_image2 avgLogBscan data0
%% Variable information about data
number_of_bscans=1; %number of B-scans to average over
bscan_pixel_height=4096; %height of 1 bscan
bscan_pixel_length=1024; %length of 1 bscan


z_cut_up=230; % number of pixels from top in the selected A-scans not to 
                 % use for the optimization of dispersion coefficients    
z_cut_down=260; % last pixel from top in the selected A-scans to 
                 % use for the optimization of dispersion coefficients  
                 
pmin=270;  % pmin - pmax is the range of A-scans to be used for 
pmax=290;  % optimization of dispersion coefficients


fourier_image=zeros(bscan_pixel_height,bscan_pixel_length);
%phase_image=zeros(bscan_pixel_height,bscan_pixel_length);

[filename, foldername] = ...
     uigetfile({'*.tif'},'Select Raw Data');
fullfilename = fullfile(foldername,filename);

[filename_bg, foldername_bg] = ...
     uigetfile({'*.tif'},'Select Raw Background Data');
fullfilename_bg = fullfile(foldername_bg,filename_bg);

for ind=1:number_of_bscans
    ind
    fullfilename=[foldername sprintf('raw_%05d',ind) '.tif'];
    %Calculate Legendre polynomials for given range
    find_legendre
    %% OCT Raw Data
    data1=imread(fullfilename,'tif');
    %cast changes the format of data to 'double' which matlab needs for functions like movavg().
    data1=cast(data1,'double');
    data=data1';
    %background subtraction
    background_calc
    % k space resample, this file contains spectrometer calibration
    % coefficients 
    k_space_resample

    %Calculate dispersion coeficients
    %findc_wp_complexFFT
    %findd_wp_complexFFT
    coef_2dg=-20%-17.08; %-10
    coef_3dg=-6.779;

    %% Script to build B-scan from raw spectrum data
    build_b_scan % windowing of A-scans here: w=window(@hann,bscan_pixel_height);
                 % ascan1=w.*corrected_data_k'. To avoid windowing use: 
                 % ascan1=corrected_data_k'; instead. We usually use hanning
                 % window as determined by @hann parameter.
    figure; imagesc(diff./comp);            
    figure; imagesc(log(comp)); colormap(gray)
    
    %original bands (unbalanced)
    oband1(:,:,ind)=band1;
    oband2(:,:,ind)=band2;
    compBuff(:,:,ind)=comp;
    diffBuff(:,:,ind)=diff;
    
    %balanced bands
    band1Buff(:,:,ind)=band1spatial;
    band2Buff(:,:,ind)=band2spatial;
end
    
%% Additional display code
band1mean = mean(band1Buff,3);
band2mean = mean(band2Buff,3);


 



