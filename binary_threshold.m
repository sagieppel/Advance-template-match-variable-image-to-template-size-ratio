function bw=binary_threshold(i3,thresh)
%  transform gray to image i3 to binary using otsu threshold or  using inputed threshold thresh

if (nargin==1)thresh=graythresh(i3);% automatic find threshold otsu mehod if threshold was not inputes
end
bw=im2bw(i3,thresh);
bw=~bw;% create uposite image since in the first image the vessel is black and the background white
%imshow(bw);
%0-----------------------------------------------------------
end
