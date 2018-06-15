
bscanavg = 10;
bscan_pixel_height=4096; %height of 1 bscan
bscan_pixel_length=1000; %length of 1 bscan
numofbscan = 1403;

%Calculate Legendre polynomials for given range
find_legendre
% k space resample, this file contains spectrometer calibration
% coefficients 
k_space_resample

ext='.bin';

%folder = 'X:\SparkOCT Data\sample A slide 19\2018_04_03_19-45-48\';
folder = 'X:\Itamar\06_04_2018\2018_06_05_13-20-28\'
outfolder = strcat(folder,'tiffs\');
Bscansum=0;
for j = 1:(numofbscan*bscanavg)
    j
    fname=strcat(sprintf('%05d',j),strcat('_raw_us_4096_',num2str(bscan_pixel_length),'_',num2str(bscanavg)));
    
    f = fopen(strcat(folder,fname,ext));
    in = fread(f,'*uint16');
    fclose(f);
    in_1 = reshape(in,4096,bscan_pixel_length);

    fourier_image=zeros(bscan_pixel_height,bscan_pixel_length);
    %phase_image=zeros(bscan_pixel_height,bscan_pixel_length);

    fname=sprintf('raw_%05d',1);
    %% OCT Raw Data
    %cast changes the format of data to 'double' which matlab needs for functions like movavg().
    data_avg1=cast(in_1','double')';
    
    %Calculate dispersion coeficients
    %findc_wp_complexFFT
    %findd_wp_complexFFT
    coef_2dg=-20; %-10
    coef_3dg=0;

    %% Script to build B-scan from raw spectrum data
    build_b_scan_volume % windowing of A-scans here: w=window(@hann,bscan_pixel_height);
                 % ascan1=w.*corrected_data_k'. To avoid windowing use: 
                 % ascan1=corrected_data_k'; instead. We usually use hanning
                 % window as determined by @hann parameter.
    Bscan = fourier_unwrapped (1:end/2,:);
    %rotangle =24.8; crop = [1370:1530];
    %Brot=imrotate(Bscan,rotangle);
    Bcrop = Bscan;
    %Bcrop=Brot(crop,:);
    
    Bscansum=Bscansum+Bcrop;
    %% write tiff
    
    if (rem(j,bscanavg)==0)
        outputPath=outfolder;
        filename = 'stitch2'; 
        fileType = 'tif';
        if (j==4)
                    WriteMode = 'overwrite';
                else
                    WriteMode = 'append';
        end
        imwrite(scale0To255_ext(log(Bscansum/bscanavg)),[outputPath filename '.' fileType],fileType, 'WriteMode', WriteMode);
        
        Bscansum=0;
    end
end

 



 



