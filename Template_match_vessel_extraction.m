
function [score,  y, x ]=Template_match_vessel_extraction(Is,Itm,neg_corl,border,tm_dilation)%, thresh)
% Find  vessel edge image Itm (binary) in canny or sobel of  system image Is (Grey).
% border neg_corl determine the negative correlation betweem the vessel template and the system edge to avoid the condition in which the vessel will have high false positive in dnse border areas 'full' mean create negative on the inside and out side border of the vessel, 'out' mean create negative correlation only on the out side of the vessel 'none' mean create no negative correlation
% tm_dilation determine the type of edge use in the system image canny(black and white) sobel (absolute gradient value from 1-2000) , or 'none' if the system image is already edge image
% -> in order to avoid the edge from missing correct point by dilation
% thresh old determine what kind of scores will be used the score is as
% fraction of the the maximum
% return the score and location of the maximum and score and location of
% every point is score is equal or above thresh*maximum
%clear all;
%Itm=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score x sqrt(ysize).tif');
%Is=imread('C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg');
%Is=rgb2gray(Is);
%==========================================intialize optional paramters=================================================================================================================
if (nargin<3)
neg_corl='out';% determine the negative correlation betweem the vessel template and the system edge to avoid the condition in which the vessel will have high false positive in dnse border areas 'full' mean create negative on the inside and out side border of the vessel, 'out' mean create negative correlation only on the out side of the vessel 'none' mean create no negative correlation
end;
if (nargin<4)
border='canny';% determine the type of edge use in the system image canny(black and white) sobel (absolute gradient value from 1-2000) , or 'none' if the system image is already edge image
end;
if (nargin<5)
    Sitm=size(Itm);
tm_dilation=floor(sqrt(Sitm(1)*Sitm(2))/80);% in order to avoid the edge from missing correct point by dilation the size of dilation is proportinal to the size of the item template dimension.
%tm_dilation=2
end;
    
if (nargin<6)
thresh=1;%this paramter is not been used in corrent version
end;
%===================================================Prepare template=======================================================================================================================

%Is=imread('C:\Users\mithycow\Documents\MATLAB\vessel from back ground\s2.bmp');
%---------------------DILATE Template-------------------------------------------------------------------------------------------------------------------------------------------------
%%it might be that the border will be to too disperse to be idenified by single  edge
%dilution of the edge will prevent it from being miss
It=double(Itm);
for f=1:1:tm_dilation 
    It=dilate(It);%DILATE Template
end
%==============================prepare areas of negative crosscorrelation in the template (areas were the template value is negative)
%------------------------------we want both side of the edge to be empty so we can  avoid  getting false positive in noisy areas -------------------------------

if (strcmp(neg_corl,'full'))
   Id=dilate(It);
    for f=1:1:tm_dilation*2-1
        Id=dilate(Id);
    end
   NegWeight=0.5;
   Im=It*(1+NegWeight)-Id*NegWeight;

%-----------------------------alternative to wanting both side of the edge to be empty we can want only the out side of the edge to be empty-----------------------------------------------------------------------
elseif (strcmp(neg_corl,'out'))   
    If=imfill(It,4,'holes');
    Ifd=dilate(If);
    for f=1:1:tm_dilation*2-1
        Ifd=dilate(Ifd);
    end
    If=Ifd-If;
    Im=double(It-If);
else
%--------------------------no action use the vessel template as it is---------------------------------------------------------------------------------------------
    Im=double(It);
end;
 %   imtool(Im,[]);
%==================================================Prepare image======================================================================================== 
%----------------------------------------Transform image to canny edge map or sobel gradient map (absolute)--------------------------------------------------------------------------------------------------------

if (strcmp(border,'canny'))
    highthresh=0.12;
    Iedg=edge(Is,'canny');%,[highthresh/3,highthresh],1.1);
    Iedg=double(Iedg);
elseif (strcmp(border,'sobel'))
    Iedg=gradient_size(Is);
    Iedg=double(Iedg);
end
%imtool(Iedg);

%==============================================Search for template in the image===============================================================================================
%------------------------------------------------------------------------------filter-----------------------------------------------------------------------------------------------------

Itr=imfilter(Iedg,Im,'same');%use filter/kernal to scan the cross correlation of the image Iedg to the template and give match of the cross corelation scoe for each pixel in the image
%'same',0 % same mean the same size as Iedge zero mean the same size  as Is with the edges out side the picture counted as zero
%imtool(Itr,[]);
%---------------------------------------------------------------------------normalized according to template size (fraction of the template points that was found)------------------------------------------------------------------------------------------------
Itr=Itr./sqrt(sum(sum(Itm)));% normalize score match by the number of pixels in the template to avoid biase toward large template
%---------------------------------------------------------------------------find the location best match
%imtool(Itr,[]);
mx=max(max(Itr));
%best_loc=find(Itr==mx);

%[ xy(1),xy(2)]
[y,x]=find(Itr==mx,  1, 'first'); % find the location first 10 best matches which their score is at least thresh percents of the maximal score and put them in the x,y array
%xy= [y x];
score=zeros(size(y));
ss=size(Itm);
 

   score=Itr(y(1),x(1));
   y(1)=round(y(1)-ss(1)/2);% normalize the location of the cordinate to so it will point on the edge of the image and not its center
   x(1)=round(x(1)-ss(2)/2);

%{
for finding all results that pass the thresh score
[y,x]=find(Itr>=thresh*mx,  10, 'first'); % find the location first 10 best matches which their score is at least thresh percents of the maximal score and put them in the x,y array
%xy= [y x];
score=zeros(size(y));
ss=size(Itm);
 
for i=1:1:size(y)% find the score of the best match
   %score(i)=Itr(xy(i,1),xy(i,2));
   score(i)=Itr(y(i),x(i));
   y(i)=round(y(i)-ss(1)/2);% normalize the location of the cordinate to so it will point on the edge of the image and not its center
   x(i)=round(x(i)-ss(2)/2);
end;
%}
%====================================For display only mark the ves result on the image=======================================================================
%-------------------------------------mark the best result on the image---------------------------------------------------------------------------
 %k =find2(Itm,1);
 

%mrk=set2(Is,k,0,y(1),x(1));
    %figure, 
  %  imshow(mrk);
 % pause();

end