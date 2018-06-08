%%Initialization

fourier_image=zeros(bscan_pixel_height,bscan_pixel_length);
%phase_image1=zeros(bscan_pixel_height,bscan_pixel_length);

fourier_unwrapped=zeros(bscan_pixel_height,bscan_pixel_length);
%real_unwrapped=zeros(bscan_pixel_height,bscan_pixel_length);
%bscan_avg=zeros(bscan_pixel_height,bscan_pixel_length);
unwrapped=zeros(bscan_pixel_height,bscan_pixel_length);
 


%%Background
backgrnd = mean(data_avg1,2);

%load('secondorderfit.mat')
%A=P(3);
%B=P(2);
%% for scan=1:number_of_bscans
%data_avg1=data_avg1.*backgrnd;
%apodsmooth = backgrnd./max(backgrnd);
%g = 1./apodsmooth.*(apodsmooth.^2./(apodsmooth.^2+0.0225));
% g=1;
% data_avg=(data_avg1-backgrnd).*g;
% %data_avg=data_avg1;

thrsh=200;
backgrnd_t=backgrnd;
backgrnd_t(backgrnd_t<200)=200;
%data_avg=(data_avg1-repmat(backgrnd, [1 size(data_avg1, 2)]))./repmat(backgrnd_t, [1 size(data_avg1,2)]);
data_backsub = (data_avg1-repmat(backgrnd, [1 size(data_avg1, 2)]));
%data_avg=(data_avg1-backgrnd)./backgrnd_t;

%% moving avg
%moving_average=smooth(data_avg,50,'lowess');
%corrected_data_nodivide=(data_avg-moving_average);
corrected_data_nodivide=data_backsub;
%%Resampling to linear k-space;
corrected_data_k=interp1(kx,corrected_data_nodivide,kx_linear,'pchip'); 


%% Hanning- decrease noise
%set hanning for N number of points = bscan pixel height
%data_avg1 - double version of raw data
 w=repmat(window(@hann,bscan_pixel_height), [1 size(data_avg1, 2)]);
%w=1;
%use hanning
%ascan1=w.*corrected_data_k';
ascan1=w.*corrected_data_k;
%ascan1=w.*rcos(1:end-1)';
%ascan1=corrected_data_k'; 

%% Hilbert- create analytical function
%hilbert returns real+imag*i
hil=hilbert(ascan1);

%% Dispersion correction
%%new=unwrap(angle(hil))+(A*q0+B*q1+coef_2dg*q2+coef_3dg*q3+coef_4dg*q4)';
%  new1=smooth(unwrap(angle(hil)),10,'lowess');
%new1=unwrap(angle(hil));
% new=new1+(-215*q2-10*q3+0.005*q4)';
new=unwrap(angle(hil))+repmat((coef_2dg*q2+coef_3dg*q3)', [1 size(data_avg1,2)]);
ang=new;


%% corrected fourier
unwrapped =real(abs(hil).*exp(1j*ang));
% unwrapped(:,p)=smooth(unwrapped1(:,p),5,'lowess');

fourier_unwrapped=abs(fft(unwrapped.*w));

%% black and white image
%this will be used by "display_fourier.m" to generate layers image
for p=1:size(unwrapped,2)
    fourier_image(:,p)=abs(fft(unwrapped(:,p)));
end
% phase_image1(:,p)=angle(fft(unwrapped(:,p)));
