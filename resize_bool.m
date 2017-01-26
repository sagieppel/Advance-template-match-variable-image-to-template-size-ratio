% resize image of border image to smaller border image if the border fall
% between  pixels even to odd and vice versa then there two border ipixesl
% instead of one
clear all;
boolim=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score power(1 dive ysize).tif');
figure, imshow(boolim);
boolim= double( boolim );

boolim=imresize(boolim,0.2,'bilinear');
boolim=(boolim>0);
figure,imshow(boolim,[])