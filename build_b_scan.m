fourier_image=zeros(bscan_pixel_height,bscan_pixel_length);

fourier_unwrapped=zeros(bscan_pixel_height,bscan_pixel_length);
unwrapped=zeros(bscan_pixel_height,bscan_pixel_length);
unwrapped1=zeros(bscan_pixel_height,bscan_pixel_length);
corrected_data_k=zeros(bscan_pixel_height,bscan_pixel_length);
ascan1=zeros(bscan_pixel_height,bscan_pixel_length);

for p=1:bscan_pixel_length
p
data_avg1=data(:,p);
%g = 1./apodsmooth.*(apodsmooth.^2./(apodsmooth.^2+0.0225));
thrsh=200;
backgrnd_t=mean(data,2);
backgrnd_t(backgrnd_t<200)=200;
%background subtraction, divide by thresholded background
data_avg(:,p)=(data_avg1-mean(data,2))./backgrnd_t;

%% moving avg
%moving_average=smooth(data_avg,50,'lowess');
corrected_data_nodivide=data_avg(:,p);
%%Resampling to linear k-space;
corrected_data_k(:,p)=interp1(kx,corrected_data_nodivide,kx_linear,'pchip'); 


%% Hanning- decrease noise
%set hanning for N number of points = bscan pixel height
w=window(@hann,bscan_pixel_height);
%use hanning
%ascan1=w.*corrected_data_k';
ascan1(:,p)=corrected_data_k(:,p)';

%% Hilbert- create analytical function
%hilbert returns real+imag*i
hil=hilbert(ascan1(:,p));

%% dispersion compensation
%%new=unwrap(angle(hil))+(A*q0+B*q1+coef_2dg*q2+coef_3dg*q3+coef_4dg*q4)';
%  new1=smooth(unwrap(angle(hil)),10,'lowess');
%new1=unwrap(angle(hil));
% new=new1+(-215*q2-10*q3+0.005*q4)';
new=unwrap(angle(hil))+(coef_2dg*q2+coef_3dg*q3)';
ang=new;


%% dispersion corrected fourier
unwrapped(:,p)=real(abs(hil).*exp(1j*ang));

fourier_unwrapped(:,p)=abs(fft(unwrapped(:,p).*w))  ;

%% black and white image
%this will be used by "display_fourier.m" to generate layers image
fourier_image(:,p)=abs(fft(unwrapped(:,p)));
end

k_n=0:4095;
N = length(k_n);
m = 0:N-1;
[K, M] = meshgrid(k_n,m(1:end/2));
TempFFTM = exp(2*pi*1i.*M.*K/N);

%create bands
band1indices=1:2048;
band2indices=2049:4096;
w1=window(@hann,length(band1indices));
w2=window(@hann,length(band2indices));

band1=abs(TempFFTM(:,band1indices)*(unwrapped(band1indices,:).*repmat(w1,[1 length(unwrapped(1,:))])));
band2=abs(TempFFTM(:,band2indices)*(unwrapped(band2indices,:).*repmat(w2,[1 length(unwrapped(1,:))])));

balanceBands;

diff=(band1spatial-band2spatial)/2;
comp=(band1spatial+band2spatial)/2;
%logdiff=(log(band1spatial)-log(band2spatial))/2;
%logcomp=(log(band1spatial)+log(band2spatial))/2;
