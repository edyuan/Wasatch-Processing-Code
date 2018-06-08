n_C=600;
C=linspace(-400,-100,n_C);
sum_of_varc=zeros(1,n_C);
data = data1_avg;
z_cut_up=1000; z_cut_down = 1400;


for k=1:n_C
    sum_of_varc1=0;
for p=pmin:pmax
data_avg1=data(:,p);
data_avg=data_avg1;

%% moving avg
%moving_average=smooth(data_avg,50,'lowess');
%p=
corrected_data_nodivide=data_avg-backgrnd;


%% k space resample
corrected_data_k=interp1(kx,corrected_data_nodivide,kx_linear,'pchip'); 


%% Hanning- decrease noise
%set hanning for N number of points = bscan pixel height
w=window(@hann,bscan_pixel_height);
%use hanning
ascan1=w.*corrected_data_k';  

%% Hilbert- create analytical function
%hilbert returns real+imag*i
hil=hilbert(ascan1);

% dans part
new=unwrap(angle(hil))+(C(k)*q2)';
ang=new;

%% corrected fourier
unwrapped=real(abs(hil).*exp(1j*ang));
fourier_unwrapped=abs(fft(unwrapped));
sum_of_varc1=var(fourier_unwrapped(z_cut_up:z_cut_down))+sum_of_varc1;
end
%find variance
sum_of_varc(k)=sum_of_varc1;
k
end
%moving average using 35 points before and 35 points after
filtered_varc=smooth(sum_of_varc,60,'lowess');
%filtered_var_shift=[filtered_var(20:length(C));filtered_var(1:19)];
[~,y]=max(filtered_varc);
coef_2dg=C(y);
