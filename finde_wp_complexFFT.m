E=linspace(-1000,1000,1000);
sum_of_var=zeros(1,1000);
for k=1:550
    sum_of_vare1=0;
for p=1:1
%% moving avg
%moving_average=smooth(data_avg,50,'lowess');
%corrected_data_nodivide=(data_avg-moving_average);
data_avg1=data(:,range(p));
data_avg=data_avg1;

corrected_data_nodivide=data_avg-backgrnd;
%% k space resample
corrected_data_k=interp1(kx,corrected_data_nodivide,kx_linear,'pchip'); 

%% Hanning- decrease noise
%set hanning for N number of points = bscan pixel height
w=window(@gausswin,bscan_pixel_height);
%use hanning
% ascan1=w.*w.*corrected_data_k';  
 ascan1=corrected_data_k';

%% Hilbert- create analytical function
%hilbert returns real+imag*i
hil=hilbert(ascan1);

% dans part
new=unwrap(angle(hil))+(coef_2dg*q2+coef_3dg*q3+E(k)*q4)';
ang=new;

%% corrected fourier
unwrapped=real(abs(hil).*exp(1j*ang));
fourier_unwrapped=abs(fft(unwrapped));
sum_of_vare1=var(fourier_unwrapped)+sum_of_vare1;
end
%find variance
sum_of_vare(k)=sum_of_vare1;
end
filtered_vare=smooth(sum_of_vare,60,'lowess');
%filtered_var_shift=[filtered_var(20:length(D));filtered_var(1:19)];
[~,y]=max(filtered_vare);
coef_4dg=E(y);
