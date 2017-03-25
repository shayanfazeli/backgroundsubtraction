%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Foreground video builder %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The purpose of this script is to prepare a folder with frames of
% the foreground video, which has been extracted using one of the
% conventional approaches (in this scenario I have used mainly
% temporal median approach as the method. Gaussian approach resulted in
% a little noisier panorama.

%building a directory:
mkdir fgpandir
panorama = back_panorama;
prcnt = 0;
h=waitbar(prcnt, 'initializing...');
for i = 1:900
    prcnt = i/900;
    waitbar(prcnt, h, sprintf('please wait, foreground-pan frames are being generated... \n%d%%',floor(100*prcnt) ));
    
    frame = frames{i,1};
    H = Homographies{1,i};
    fgimage = give_its_for_to_me2(panorama, frame, H);
    cd fgpandir;
    imwrite(fgimage, ['f', sprintf('%.4d',i), '.jpg']);
    cd ..;
end
waitbar(1, h, sprintf('All done. \n%d%%',floor(100) ));
close(h);
system('ffmpeg -r 30 -i fgpandir/f%04d.jpg -vf "scale=trunc(1861/2)*2:trunc(721/2)*2" -pix_fmt yuv420p 03_fore_pan.mp4 ');                            

