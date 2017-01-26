function boolim=resize_border(boolim, sy, sz2) 
% resize binarry image of the vessel border boolim  to smaller (sz fraction) bolean border image 
% first refill the image then transfrom it to double shrink and take every
% pixel that is not zero to be one the take the border again
%this function have 3 variation but this one is the best
%boolim=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score power(1 dive ysize).tif');
%figure, imshow(boolim);
boolim=imfill(boolim,4,'holes');% fill image 4 is the connectivity
boolim= double( boolim );
if (nargin==3)

    boolim=imresize(boolim,[sy sz2]);
else
boolim=imresize(boolim,[sy NaN]);%,'bilinear');
end;
imshow(boolim);
pause;
boolim=(boolim>0);% every pixel that is not zero is partially contain  at least part of the border
imshow(boolim);
pause;
boolim=openim(boolim);
imshow(boolim);
pause;
boolim= bwmorph(boolim,'remove');% remove blobe interior and leave edges;
%figure,imshow(boolim,[])
end