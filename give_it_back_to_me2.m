%%%%%%%%%%%%%%%%%%%%%%%%%
%% give_it_back_to_me2 %%
%%%%%%%%%%%%%%%%%%%%%%%%%
% This function works as follows:
% - It takes the background panorama, along with one frame of the
%   video and it's homography as it's inputs, 
%   then projects the frame on the mosaic, and finds
%   the corresponding box on the mosaic.

function out = give_it_back_to_me2(panorama, frame, H)
tform = maketform('projective', H');
transformedimage = imtransform(frame, maketform('projective', H'),...
                               'VData',[1 size(frame,1)],'UData',[1 size(frame,2)],...
                               'XData',[-1000 size(frame,2)+600],'YData',[-100 size(frame,1)+250]);

mask = double(logical(transformedimage));
mask = double(logical(mean(mask,3)));
mask = cat(3, mask, mask, mask);
out = uint8(mask .* double(panorama));



end