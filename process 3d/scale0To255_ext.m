function scaledImg = scale0To255_ext(Img)
minthresh=0.005;
maxthresh=0.13;

minthresh=96;
maxthresh=6000;
% 
% minthresh=4;
% maxthresh=9;
% 
minthresh=6;
maxthresh=10;

% 
 minthresh=0;
 maxthresh=6.6e4;

Img2=Img;
Img2(Img2<minthresh)=minthresh;
Img2(Img2>maxthresh)=maxthresh;
Img2=Img2-minthresh;

maxthresh = maxthresh - minthresh;
Img2=Img2/maxthresh;

scaledImg = Img2;