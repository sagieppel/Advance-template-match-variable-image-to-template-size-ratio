 
function bw=openim(bw)
% open binary image bw morphological operation of erosion and daltion that
% resuce noise and delete thin areas
CE=strel('square',3);% create square mask of 3X3 for oppening 
bw=imopen(bw,CE);
%figure, imshow(bw);

end