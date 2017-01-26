function [ vessel_cont, symmetry_score ,brxy , imborder , YaxisSize]=Find_Vessel_Contour(figurefilename, Symmetry_Mode, Npix, threshold, SegmentationMode)
%Identify object by sperating it from background
%  identify the vessel in color image readed from figurefilename, 
%resize the image y size to into npix pixels without changing proportions, and use threshold  for the canny sobel operator operator
% SegmentationMode define wether objects/blobs will be recognize by 'BORDER_CANNY' mode wich mean searching areas with close border contours found by canny+sobel operators or by "THRESHOLD" mode finding areas with different  intenstiy using threshold for the grey image of the system   'BORDER_CANNY'  give  much better  results the 'THRESHOLD' method for most cases and used as difult
% Symmetry_Mode symmetry mode tell wether to use symmetry consideration (0 if not) and which mode (1-2) [see symmetrized function]


%general operation: use canny and soble to transform image into border image
% use blob labeling and image segementation to  to identifty the blob of
% the backgroud. Create negative of the background blob image so every that blob is
% not the background is white. choose the largest blob/region as representing the
% vessel. Use symmetry and thikness consideration and remove parallel regions to improve the vessel
% boundary
%Resize
%brxy are list of xy points of the borders point location on the image
%imborder is the original image (resize with the image borders marked on
%the final image
close all;
symmetry_score=0;

if (nargin<2 ) Symmetry_Mode=2; end;
if (nargin<3) Npix=16000; end;
 if (nargin<4)   threshold=0.12; end;
 if (nargin<5)   SegmentationMode='BORDER_CANNY'; end;

%i=imread('C:\Users\mithycow\Desktop\trial pictures glassware\edited\IMG_1582.jpg');%img_1574.jpg');%img_1574 to 1585.jpg
i=imread(figurefilename);%'C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg');%DSC_0016.jpg
%-----------------------resize and adopt histogram------------------------
dm=size(i);% y*y/(nx/ny)=npix y= sqrt(npix*ny/nx)  ny=dm1 nx=dm2
YaxisSize=round(sqrt(Npix*dm(1)/dm(2)));
i2 = imresize(i, [YaxisSize NaN]);% 135 /NaN change the image so it will contain npix pixels
%figure, imshow(i2);
i3=rgb2gray(i2);
%figure, imshow(i3);
%i3=histeq(i3);% equalize intensity  histogram for complete image to create wider better intensiy range spectrum of intesinity and increase 
i3=adapthisteq(i3);% equalize histogram image intesnity region by region to prevent borders with low illumination  from being missed and leave open in the contour 
%figure, imshow(i3);
%------------------------Segment image to close conours using canny sobel or threshold and return binary image----------------------------------------------------

if strcmp(SegmentationMode,'BORDER_CANNY')%find borders using combine canny and sobel threshhold were the sobel threshholf is between the canny high and low threshold
bw=canysobel(i3,threshold);% find border using combine canny sobel
elseif strcmp(SegmentationMode,'THRESHOLD')% segment by intensity threshold (work horribly)
bw=binary_threshold(i3);% create binary image using threshold of greyscale i  much less efficient then canny sobel use one of the two to create binary sgemented image;
else
    disp('unrecogenize image segmentation mode in find vessel contour');
    exit();
end;
%----------------create binary image in which all regions which are not background are white blobs (background are segments in the image that touch the image outer edges------
%dilate;% dilute borders to seal punctore envelops optional)
bw=closeim(bw);% use to close morphological operation to seal the border nevelope % optional not  always good
bw=substract_background(bw);
%----------------improve and resuce noise image by closing and openning operation------
 bw=openim(bw);% smoth  openning morpholigical operation that remove unnsseary point 
bw=closeim(bw);% smoth image by closing morphological operation
%---------------------------------------
blobs = Getimregions( bw ); % divide binary image bw to its region assuming and return the region founde in in array blob that conain stuructures with information of each blob
% blobs is already shorted from big to small
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for f=1:1:1%size(blobs)% show largest       
     if ~isempty(blobs) && blobs(f).Area>900% if there blobs that there size bigger then 1000 use them else no object as been found
        
  %   imshow(blobs(f).Image);% show the specific blob image

     %------------show blob  edges--------------------------
        %  BW2 = bwmorph(blobs(f).Image,'remove');% remove blobe interior and live edges
%imshow(BW2)


     %----mark blob on full image---FOR PRSENTATION  ONLY---------------------------------------
     j=i3/3;
     j(blobs(f).PixelList(:,2),blobs(f).PixelList(:,1))=i3(blobs(f).PixelList(:,2),blobs(f).PixelList(:,1));
  %   imshow(j);% mark blob image in figure
%pause;
 %----cut the image area from i3 and pot it on kk. THIS PART OFTEN GOT STUCK and is needed only for symmetrized with sobel hence symmetrized3,4-----------------------------------------

           miny=min(blobs(f).PixelList(:,2));% find the location of the blob square on the total image important and being use later dont delete
           minx=min(blobs(f).PixelList(:,1));% find the location of the blob square on the total image important and being use later dont delete
      %{
      kk=zeros(miny,minx);
           kk(blobs(f).PixelList(:,2)+1-miny,blobs(f).PixelList(:,1)+1-minx)=i3(blobs(f).PixelList(:,2),blobs(f).PixelList(:,1));
           imshow(kk/255);% mark blob image in figure
 }%

 
    % isob=kk;% create image of the region that will be used for sobel operator in symmetrized 3,4
%}
           
  %----------------------Remove Parallel area in the blob-------------------------------------------------------------------------------------------------
         BW3=Remove_Parallel_Region( blobs(f).Image);% if the blob contain  lines with more then one region  (more then two edges) remove all but the broadest image
        
         
         blobs2 = Getimregions(BW3 );%  the vessel blob size might have breaked to few blobs take the first (hence the largest blob).
         miny=miny-1+min(blobs2(1).PixelList(:,2));% Update the location of the blob frame in the image of the system
         minx=minx-1+min(blobs2(1).PixelList(:,1));
         
 %--------------use symmetry and varius of rules to improve borders also remove thin area parrallel to thick area that correspond to the stand poll-----------------------------------------------------------------------------------------------
      %    imshow(blobs2(1).Image);
    
         
         [BW3,symmetry_score]=symmetrized(blobs2(1).Image, Symmetry_Mode);% Remove parrallel regions and symmetrized; adjust object border using symmetry configuration
%imshow(BW3);

%----------------------------------------------the symmetrized operation might split the blobs in this case peak the largest blob and use it ----------------------------------------------------------------------------------------------
 blobs2 = Getimregions( BW3 );%  the vessel blob size might have changes take the first (hence the largest blob).
 
 %---------------erode blob by one pixel and get is binary edge image (the erosion is needed because for some reason the blob is one pixel larger the it shouuld be
 vessel_cont= bwmorph(blobs2(1).Image,'remove');% remove blobe interior and leave edges;
 vessel_cont=blobs2(1).Image- vessel_cont; % for some unclear reason the contour received here is one pixel larger then it should be it need to b eroded
 vessel_cont=openim(vessel_cont);
 vessel_cont= bwmorph( vessel_cont,'remove');% remove blobe interior and leave edges;
 minx=minx-1; % Again not clear why but this is needed
 %imshow( vessel_cont);
 if ~exist('vessel_cont','var') vessel_cont=0;symmetry_score=-1000; end; % in case the previous function will fail to give output and get the entire program stuck
  %-----------------------------find the edge points of the vessel  on the total image and mark them--------------------------------------------------------------------------------------------------------------- 
  miny2=min(blobs2(f).PixelList(:,2));% find the location of the blob square on the total image important and being use later dont delete
 minx2=min(blobs2(f).PixelList(:,1));% find the location of the blob square on the total image important and being use later dont delete
 
 brxy=find2(vessel_cont,0.5); % find the border point of the the blob image

 
brxy(:,1)=brxy(:,1)+miny+miny2-2;% translate the border points according to the blob location realtive to the figure 
brxy(:,2)=brxy(:,2)+minx+minx2-2;
%------------------for presentation only draw border on image----------------------------------------- 
imborder=set2(i3, brxy,255,0, 0);% draw the edge points on the new image in white or black
%imborder(vessel_cont>0)=255;? why not this
%imshow(imborder);
%pause;
 
 %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

%imshow(BW3);
%-----------------------------------------------------------------------------------------------------------

%---------------------------show the edge over the real image
      %kk(BW3>0)=0;
    %figure, imshow(kk/256);% show the figure the blob refer to
  % pause;
     %----------------------------------------------------------------

    
   %---------------------------------------------------------------------------------------------------------------------------------------------------
  else % if no blob found that stand in minimimal demands 
       vessel_cont=zeros(2,2);% assign arbitary values to output to  prevent program from getting stuck as result of not assign paramters
       brxy=[1 1];
       symmetry_score=-100;
    
       imborder=zeros(size(bw));
       disp('NO CONTOUR FOUND or contour is to small in find contour');
  end;
  %-----------------------------------------------------------------------------------------------------------------------------------------------------------------

end
     