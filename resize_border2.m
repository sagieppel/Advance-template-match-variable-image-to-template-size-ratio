function outim=resize_border2(boolim, sz, sx)% less good then first version
% resize binarry image of the vessel border boolim  to smaller (sz fraction) bolean border image 
% first refill the image then transfrom it to double shrink and take every
% pixel that is not zero to be one the take the border again
%clear all;
%boolim=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score power(1 dive ysize).tif');
%figure, imshow(boolim);
%boolim=imfill(boolim,4,'holes');% fill image 4 is the connectivity
boolim= double( boolim );

if (nargin==3)

    boolim=imresize(boolim,[sz sx]);
else
boolim=imresize(boolim,sz);%,'bilinear');
end;
    
outim=(boolim>0);% every pixel that is not zero is partially contain  at least part of the border
outim=openim(outim);
%outim= bwmorph(boolim,'remove');% remove blobe interior and leave edges;
%figure,imshow(outim,[])
end