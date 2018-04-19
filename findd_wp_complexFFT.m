n_D=400;
D=linspace(-100,100,n_D);
sum_of_vard=zeros(1,n_D);

for k=1:n_D
    sum_of_vard1=0;
for p=pmin:pmax
%% moving avg
%moving_average=smooth(data_avg,50,'lowess');
%corrected_data_nodivide=(data_avg-moving_average);
data_avg1=data(:,p);
data_avg=data_avg1;

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
new=unwrap(angle(hil))+(coef_2dg*q2+D(k)*q3)';
ang=new;

%% corrected fourier
unwrapped=real(abs(hil).*exp(1j*ang));
fourier_unwrapped=abs(fft(unwrapped));
sum_of_vard1=var(fourier_unwrapped(z_cut_up:z_cut_down))+sum_of_vard1;
end
%find variance
sum_of_vard(k)=sum_of_vard1;
k
end
filtered_vard=smooth(sum_of_vard,60,'lowess');
%filtered_var_shift=[filtered_var(20:length(D));filtered_var(1:19)];
[~,y]=max(filtered_vard);
coef_3dg=D(y);
