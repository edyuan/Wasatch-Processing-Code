number_of_bscans=1; %number of B-scans to average over
range=1:bscan_pixel_length;

%% Background Raw Data
data2=imread(fullfilename_bg,'tif');
data2=cast(data2,'double');
backgrnd1=mean(data2);
backgrnd=backgrnd1';

