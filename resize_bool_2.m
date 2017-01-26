% resize binarry image of the vessel border  to smaller  bollean border image 
% first refill the image then transfrom it to double shrink and take every
% pixel that is not zero to be one the take the border again
clear all;
boolim=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score power(1 dive ysize).tif');
figure, imshow(boolim);
boolim=imfill(boolim,4,'holes');% fill image 4 is the connectivity
boolim= double( boolim );

boolim=imresize(boolim,0.2);%,'bilinear');
boolim=(boolim>0);% every pixel that is not zero is partially contain  at least part of the border
boolim=openim(boolim);
outim= bwmorph(boolim,'remove');% remove blobe interior and leave edges;
figure,imshow(outim,[])
