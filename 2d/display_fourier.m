%% display greyscale figure
I=brightness*log10(1+fourier_image(top_bound:lower_bound,:));
img=fourier_image(top_bound:lower_bound,:);
figure
imshow(I,[lower_greyscale_range,upper_greyscale_range])

%Normalizing and contrasting OCT image to 8-bit

        mn_norm=1.5;
        sm_pixels=70;
        img=log(fourier_image(top_bound:lower_bound,:));
        img1=img(z_cut_up:z_cut_down,:);
        mx1=max(img1);
        mx1_1=smooth(mx1,sm_pixels)';
        mx2=max(mx1_1);
        mn1=min(img1);
        mn2=mn_norm*max(mn1);
        norm_I1=img-mn2;
        norm_I2=norm_I1*255/(mx2-mn2);
        norm_I=cast(norm_I2,'uint8');

    %Writing 8-bit OCT image        
        s=filename;
        s=s(5:end);
        imwrite(norm_I,s,'tiff')