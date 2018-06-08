
%Noise ROI

noise1 = mean(mean(band1(648:1096,11:80)));
noise2 = mean(mean(band2(648:1096,11:80)));


band1mean = mean(mean(band1(660:1096,505:945)));

%TiO2
figure; plot(mean(band1(:,505:945),2));
hold on; plot(mean(band2(:,505:945),2));
ylim([0 10]); title('TiO2')

%IL
figure; plot(mean(band1(:,302:425),2));
hold on; plot(mean(band2(:,302:425),2));
ylim([0 10]); title('IL')


%beads
figure; plot(mean(band1(:,102:231),2));
hold on; plot(mean(band2(:,102:231),2));
ylim([0 10]); title('beads')


%noise
figure; plot(mean(band1(:,4:67),2));
hold on; plot(mean(band2(:,4:67),2));
ylim([0 10]); title('noise')

ratio = smooth(mean(band2(:,4:67),2)./mean(band1(:,4:67),2),0.03,'lowess');


%----------------------------------------------------------------------------



%TiO2
figure; plot(ratio.*mean(band1(:,505:945),2));
hold on; plot(mean(band2(:,505:945),2));
ylim([0 10]); title('TiO2-noise balanced')

%IL
figure; plot(ratio.*mean(band1(:,302:425),2));
hold on; plot(mean(band2(:,302:425),2));
ylim([0 10]); title('IL-noise balanced')


%beads
figure; plot(ratio.*mean(band1(:,102:231),2));
hold on; plot(mean(band2(:,102:231),2));
ylim([0 10]); title('beads-noise balanced')


