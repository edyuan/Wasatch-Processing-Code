%% k space resample
%variables->lmbd(nm)=cl0+cl1*pixel+cl2*pixel^2+cl3*pixel^3
cl0=6.57328E+02;
cl1=8.28908E-02;
cl2=-1.10175E-06;
cl3=-7.04714E-11;
%cl0=6.53449E+02;
%cl1=8.35656E-02;
%cl2=-1.31796E-06;
%cl3=-4.31007E-11;

N=bscan_pixel_height;
wavelength_1=cl0;
wavelength_N=cl0+cl1*N+cl2*N^2+cl3*N^3;

k_delta=(2*pi*(wavelength_N-wavelength_1))/(wavelength_N*wavelength_1*N);
kx=zeros(1,N);
wave_x=zeros(1,N);
kx_linear=zeros(1,N);


for i=1:N
    wave_x(i)=cl0+cl1*i+cl2*i^2+cl3*i^3;
    kx(i)=(2*pi)/wave_x(i);
    kx_linear(i)=kx(1)-k_delta*(i-1);
end