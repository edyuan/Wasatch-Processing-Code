
bscanavg = 1;     %always =1 for files processed by Wasatch
bscan_pixel_height=4096; %height of 1 bscan
bscan_pixel_length=1000; %length of 1 bscan
numofbscan = 1000;

%Calculate Legendre polynomials for given range
find_legendre
% k space resample, this file contains spectrometer calibration
% coefficients 
k_space_resample=1

ext='.bin';

folder = 'X:\Itamar\06132018\2018_06_13_14-59-16\';
mkdir(strcat(folder,'tiffs\'))
Bscansum=0;
down = (568-427)/numofbscan;   %a-b, a is bottom of j=1, b is bottom of j=end
down =0;
for j = 1:((numofbscan*bscanavg)-1)
    j
    fname=strcat(sprintf('%05d',j),strcat('_int_f_2048_',num2str(bscan_pixel_length),'_1'));
    
    f = fopen(strcat(folder,fname,ext));
    in = fread(f,'float');
    fclose(f);
    
    try
        in_1 = reshape(in,2048,bscan_pixel_length);
    catch
        warning('Problem interf is wrong size');
    end

    Bscan = in_1;
    rotangle =-7.5; %crop = [485:532];%542-576 negative to turn image clockwise
    crop = [520:583];
    gradcrop = [420:583];
    
    Brot=imrotate(Bscan,rotangle);
    signalcrop=imtranslate(Brot,[0 down*(j-1)]);
    grad = gradient(mean(Brot,2));
    [thing ind]=max(grad(gradcrop));
    maxind(j)=gradcrop(1)-1+ind;
    %signalcrop = Brot;
    Bcrop=signalcrop(crop,:);
    Bcrop = Bscan;
    
    Bscansum=Bscansum+Bcrop;
    %% write tiff
    
    if (rem(j,bscanavg)==0)
        outputPath=strcat(folder,'tiffs\');
        filename = 'stitchavg'; 
        fileType = 'tif';
        if (j==bscanavg)
                    WriteMode = 'overwrite';
                else
                    WriteMode = 'append';
        end
        imwrite(scale0To255_ext(Bscansum/bscanavg),[outputPath filename '.' fileType],fileType, 'WriteMode', WriteMode);
        
        Bscansum=0;
    end
end

 






