%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% My Plotter               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function's purpose is to get the projected image, and project it
%onto the super plane which is constructed in the main script and
%is meant to contain all those images.

function out = myplotter(plane, image, H)
transformedimage = imtransform(image, maketform('projective', H'),...
                               'VData',[1 size(image,1)],'UData',[1 size(image,2)],...
                               'XData',[-1000 size(image,2)+600],'YData',[-100 size(image,1)+250]);size(transformedimage);
temp = H./H(3,3);
t_x = round(temp(2,3));
t_y = round(temp(1,3));

%finding the indices...
ind1 = (plane == 0);
ind2 = (transformedimage == 0);

out = zeros(size(plane));
mask1 = double(and(~ind1, ~ind2));
mask2 = double(and(ind1, ~ind2));
mask3 = double(and(~ind1, ind2));

dplane = double(plane);
dtransformedimage = double(transformedimage);
%% Seamless cloning

%taking a copy from those two (region of interest of course)...
if sum(mask1(:))~=0
    [i1, i2] = find(mask1(:,:,1));
    i1 = sort(i1);
    i2 = sort(i2);
    dplane_part = dplane(i1(1,1):i1(end,1), i2(1,1):i2(end,1),:);
    dtransformedimage_part = dtransformedimage(i1(1,1):i1(end,1), i2(1,1):i2(end,1),:);
    %now we have to split the mask into two regions...
    dplane_part(dplane_part==0) = Inf;
    difference = mean(abs(dtransformedimage_part - dplane_part),3);
    label = ones(size(difference));
    mid = floor(size(difference,2)/2);
    [useless, min_of_row] = min(difference(:, mid-5:mid+5), [], 2);
    min_of_row = min_of_row + (mid - 6);
    if t_y < 0
        %that means dtransformed is at the left of the plane
        for k = 1:size(difference,1)
            label(k, 1:min_of_row(k,1)) = 2;
        end
    else
        for k = 1:size(difference,1)
            label(k, min_of_row(k,1):end) = 2;
        end
    end
    label = cat(3,label, label, label);
    mask1(i1(1,1):i1(end,1), i2(1,1):i2(end,1),:) = mask1(i1(1,1):i1(end,1), i2(1,1):i2(end,1),:).*label;
    mask4 = double(mask1==2);
    mask5 = double(mask1==1);
else
    mask4 = mask1;
    mask5 = mask1;
end

out = out + (mask4+mask2).*dtransformedimage;
out = out + (mask5+mask3).*dplane;

out = normalizer(out);
end