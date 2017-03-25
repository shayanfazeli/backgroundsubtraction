%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISPLAYING THE CORRESPONDENCES  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%run this script to do the requested task...

clc;
disp('- DISPLAYING THE CORRESPONDENCES -');


H =  [-0.6152   -0.0199  125.9182
   -0.0102   -0.5746    9.9834
   -0.0003    0.0000   -0.4882];


cd frames;
frame270 = imread(['f', sprintf('%.4d',270), '.jpg']);
frame450 = imread(['f', sprintf('%.4d',450), '.jpg']);
cd ..;

disp('the 270th frame is shown:');
imshow(frame270); title('select your points');
hold on;
[X Y] = getpts;

disp('now the reference frame, with the points...');
newX = X;
newY = Y;

for i = 1:size(newX,1)
    a = newX(i,1);
    b = newY(i,1);
    matrix = H * [a;b;1];
    matrix = matrix./matrix(3,1);
    newX(i,1) = round(matrix(1,1));
    newY(i,1) = round(matrix(2,1));
end

close all;
imshow(frame450); title('reference frame with correspondences');
hold on;
for l = 1:size(newX,1)
	plot(newX(l,1), newY(l,1), 'rx');
end







