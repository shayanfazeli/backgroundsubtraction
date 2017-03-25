%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BACKGROUND SUBTRACTION     %%
%% Shayan Fazeli              %%
%% 	                          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%preparing the script:
run('..pathtoyourvlfeat..\VLFEAT\toolbox\vl_setup.m');
clear all;
close all;
clc;

%moving to the folder of the images:
cd frames;

%reading the frames into a huge cell array:
frames = cell(900,1);

%perform the reading:
for i = 1:900
    frames{i,1} = imread(['f', sprintf('%.4d',i), '.jpg']);
end

%head back
cd ..;

%reference frames are 90, 270, 450, 630, 810

%finding some important homographies...:
[F90, D90] = vl_sift(im2single(rgb2gray(frames{90,1})), 'PeakThresh',0.00001);
[F270, D270] = vl_sift(im2single(rgb2gray(frames{270,1})), 'PeakThresh',0.00001);
[F450, D450] = vl_sift(im2single(rgb2gray(frames{450,1})), 'PeakThresh',0.00001);
[F630, D630] = vl_sift(im2single(rgb2gray(frames{630,1})), 'PeakThresh',0.00001);
[F810, D810] = vl_sift(im2single(rgb2gray(frames{810,1})), 'PeakThresh',0.00001);
matches_90to270 = vl_ubcmatch(D90, D270);
matches_270to450 = vl_ubcmatch(D270, D450);
matches_630to450 = vl_ubcmatch(D630,D450);
matches_810to630 = vl_ubcmatch(D810,D630);
[H_90to270, inliers_90to270] = ransacfithomography(F90(1:2,matches_90to270(1,:)),...
    F270(1:2,matches_90to270(2,:)), 0.001);
[H_270to450, inliers_270to450] = ransacfithomography(F270(1:2,matches_270to450(1,:)),...
    F450(1:2,matches_270to450(2,:)), 0.001);
[H_810to630, inliers_810to630] = ransacfithomography(F810(1:2,matches_810to630(1,:)),...
    F630(1:2,matches_810to630(2,:)), 0.001);
[H_630to450, inliers_630to450] = ransacfithomography(F630(1:2,matches_630to450(1,:)),...
    F450(1:2,matches_630to450(2,:)), 0.001);

%now main Hs computed, the way we use these Hs are as following:
% newimage = imtransform(firstimage, maketform('projective', H'));
H_810to450 = H_630to450 * H_810to630;
H_90to450 = H_270to450 * H_90to270;



%%%%%%%%%% COMBINING ALGORITHM %%%%%%%%%%
%obtaining the original frame size, just in case:
org_size = size(frames{1,1});

%We construct a reference plane:
plane = zeros(711,2081,3);

%%Beginning projections..
%first, the reference frame:
plane = myplotter(plane, frames{450,1}, eye(3));
%now, everything from those famous ones:
plane = myplotter(plane, frames{90,1}, H_90to450);
plane = myplotter(plane, frames{270,1}, H_270to450);
plane = myplotter(plane, frames{630,1}, H_630to450);
plane = myplotter(plane, frames{810,1}, H_810to450);

imwrite(plane, '01.jpg');
disp('The first panorama, is saved as 01.jpg, script is paused.');
pause;


clc;
disp('Now, all the homographies are to be found...');
Homographies = cell(1,900);

prcnt = 0;
h=waitbar(prcnt, 'initializing...');



%for each frame, the homography will be found and saved:
%(for the sake of speed, this part is commented and the script just loads
%the homographies..., if it is wanted to be tested, uncomment the for loop
%and run it.)
% for i = 1:900
%     prcnt = i/900;
%     waitbar(prcnt, h, sprintf('please wait, homographies are being generated... \n%d%%',floor(100*prcnt) ));
%     %firt region:
%     if i < 90
%         [F, D] = vl_sift(im2single(rgb2gray(frames{i,1})), 'PeakThresh',0.00001);
%         matches = vl_ubcmatch(D, D90);
%         [H, inliers] = ransacfithomography(F(1:2,matches(1,:)),...
%             F90(1:2,matches(2,:)), 0.001);
%         Homographies{1,i} = H_270to450 * H_90to270 * H;
%     elseif i == 90
%         Homographies{1,i} = H_90to450;
%     elseif (i>90) && (i<270)
%         [F, D] = vl_sift(im2single(rgb2gray(frames{i,1})), 'PeakThresh',0.00001);
%         matches = vl_ubcmatch(D, D270);
%         [H, inliers] = ransacfithomography(F(1:2,matches(1,:)),...
%             F270(1:2,matches(2,:)), 0.001);
%         Homographies{1,i} = H_270to450 * H;
%         
%     elseif i == 270
%         Homographies{1,i} = H_270to450;
%     elseif (i>270) && (i<450)
%         [F, D] = vl_sift(im2single(rgb2gray(frames{i,1})), 'PeakThresh',0.00001);
%         matches = vl_ubcmatch(D, D450);
%         [H, inliers] = ransacfithomography(F(1:2,matches(1,:)),...
%             F450(1:2,matches(2,:)), 0.001);
%         Homographies{1,i} = H;
%         
%     elseif i == 450
%         Homographies{1,i} = eye(3,3);
%     elseif (i>450) && (i<630)
%         [F, D] = vl_sift(im2single(rgb2gray(frames{i,1})), 'PeakThresh',0.00001);
%         matches = vl_ubcmatch(D, D450);
%         [H, inliers] = ransacfithomography(F(1:2,matches(1,:)),...
%             F450(1:2,matches(2,:)), 0.001);
%         Homographies{1,i} = H;
%     elseif i == 630
%         Homographies{1,i} = H_630to450;
%     elseif (i>630) && (i<810)
%         [F, D] = vl_sift(im2single(rgb2gray(frames{i,1})), 'PeakThresh',0.00001);
%         matches = vl_ubcmatch(D, D630);
%         [H, inliers] = ransacfithomography(F(1:2,matches(1,:)),...
%             F630(1:2,matches(2,:)), 0.001);
%         Homographies{1,i} = H_630to450 * H;
%     elseif i == 810
%         Homographies{1,i} = H_810to450;
%     else
%         [F, D] = vl_sift(im2single(rgb2gray(frames{i,1})), 'PeakThresh',0.00001);
%         matches = vl_ubcmatch(D, D810);
%         [H, inliers] = ransacfithomography(F(1:2,matches(1,:)),...
%             F810(1:2,matches(2,:)), 0.001);
%         Homographies{1,i} = H_630to450 * H_810to630 * H;
%     end
% end
% waitbar(1, h, sprintf('All done. \n%d%%',floor(100) ));
% close(h);

load('my_homographies.mat');

disp('homographies are found, script is paused. continue to move to disp_corres.m');
pause;
disp_corres;
disp('script is paused');
pause;

%Now, making that video...
mkdir video1
%We construct a reference plane:
plane = zeros(711,2081,3);
prcnt = 0;
h=waitbar(prcnt, 'initializing...'); 
Projected_Video = cell(1,900);
for i = 1:900
    prcnt = i/900;
    waitbar(prcnt, h, sprintf('please wait, frames are being generated... \n%d%%',floor(100*prcnt) ));
    I = myplotter(plane, frames{i,1}, Homographies{1,i});
    cd video1;
    imwrite(I, ['f', sprintf('%.4d',i), '.jpg']);
    cd ..;  
    Projected_Video{1,i} = I;
end
waitbar(1, h, sprintf('All done. \n%d%%',floor(100) ));
close(h);


system('ffmpeg -r 30 -i video1/f%04d.jpg -vf "scale=trunc(1861/2)*2:trunc(721/2)*2" -pix_fmt yuv420p 01.mp4 ');                            
               
%%FINDING BACKGROUND PANORAMA:
I = zeros(size(plane));
histsR = cell(size(I,1),size(I,2));
histsG = cell(size(I,1),size(I,2));
histsB = cell(size(I,1),size(I,2));
for i = 1:size(I,1)
    for j = 1:size(I,2)
        histsR{i,j} = [];
        histsG{i,j} = [];
        histsB{i,j} = [];
    end
end

for i = 1:900
    i
    frame=Projected_Video{1,i};
    mask = or((logical(frame(:,:,1))), or((logical(frame(:,:,2))),(logical(frame(:,:,3)))));
    [r,c] = find(mask);
    for k = 1:size(r,1)
       histsR{r(k,1), c(k,1)} =  [histsR{r(k,1), c(k,1)}, frame(r(k,1), c(k,1),1)];
       histsG{r(k,1), c(k,1)} =  [histsG{r(k,1), c(k,1)}, frame(r(k,1), c(k,1),2)];
       histsB{r(k,1), c(k,1)} =  [histsB{r(k,1), c(k,1)}, frame(r(k,1), c(k,1),3)];
    end
end


back_panorama = zeros(size(I));
for i=1:size(I,1)
    i
    for j = 1:size(I,2)
        R = histsR{i,j};
        G = histsG{i,j};
        B = histsB{i,j};
        if size(R,1) ~= 0
            back_panorama(i,j,1) = median(R);
        end
        if size(G,1) ~= 0
            back_panorama(i,j,2) = median(G);
        end
        if size(B,1) ~= 0
            back_panorama(i,j,3) = median(B);
        end
        
    end
end
back_panorama = normalizer(back_panorama);
imwrite(back_panorama, '02.jpg');
disp('script is paused');
disp('continue to make 02_back_pan.mp4');
pause;
%now saving the videos....:
back_builder2;
disp('script is paused');
disp('continue to make 03_fore_pan.mp4');
pause;
fore_builder2;
disp('script is paused');
disp('continue to make 04_background.mp4');
pause;
back_builder;
disp('script is paused');
disp('continue to make 05_foreground.mp4');
pause;
fore_builder;



%THE END
