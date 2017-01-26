function [Isresize,Itmresize,Ismarked,Iborders,Ysizesys,Ysizeitm,ybest,xbest,Borders_XY, BestScore]= MAIN_find_object_in_image(Is,Itm,search_mode,border,tm_dilation,neg_corl)
%{
Find object that fit Template Itm in image Is.
The  template does not have to fit the size of the object in the image. 
The program scan various of size ratios of template to image to find the location and size ratios of the best match. 
The function can use various of methods to find the template in the image including: generalized hough transform, normalize crosscorrelation and other form of template match. 
This option are described in the Input(optional) section below.
Input (Essential):
Is: Color image with the object to be found.
Itm: Template of the object to be found. The template is written as binary image with the boundary of the template marked 1(white) and all the rest of the pixels marked 0. 
The template must be line of close contour.
Template of object could be created by extracting the object boundary in image with uniform background, 
this could be done (for symmetric objects) using the code at: http://www.mathworks.com/matlabcentral/fileexchange/46887-find-boundary-of-symmetric-object-in-image

Input (Optional):
search_mode: The method by which template Itm will be searched in image Is: search_mode='hough': use generalized hough transform to scan for template. search_mode='template': use cross-correlation to scan for template in the image (default). 
border: Only in case of  search_mode='template', the border parameter determine the type of image to which the template will be matched (edge, gradient, greyscale). 
border='sobel': Template Itm will be matched (cross-correlated) to the  to  'sobel'  gradient map of the image Is.
border='canny':  Template Itm will be matched (cross-correlated) to the  to  'canny'  binary edge map  of the image Is (default).
Else Template Itm will be matched (crosscorrelated) to the  greyscale version of the image Is.
tm_dilation: The amount of dilation for of the template. How much the template line will be thickened  (in pixels) for each side before crosscorelated with the image. 
 The thicker the template the better its chance to overlap with edge of object in the image and more rigid the recognition process, however thick template can also reduce recognition accuracy. 
The default value for this parameter is 1/40 of the average dimension size of the template Itm.
neg_corl: Only in case of  search_mode='template'. Matching the template to the edge image is likely to give high score in any place in the image with high edge density which  can give high false positive, to avoid this few possible template match option are available: 
neg_corl='out': Use negative template (negative correlation) surrounding the template contour (in small radious around the template line) but only in the outside of the template. Crosscorrelation of this areas with edges in the canny image will reduce the match score of the template in this location (default).
neg_corl='full': Use negative template (negative correlation) around the template contour line (in small radious around the template line) for both the inside and outside of the template. Crosscorrelation of this areas with edges in the canny image will reduce the match score of the template in this location (default).
neg_corl='none': Use the template as it is.

Output
Isresize: The image (Is) resized to size where the best match where found
Itmresize: The template (Itm) resized to size where the best match where found. Note that the Itmresize  template match exactly the size of the object in the image Isresize.
Ismarked: The image (Isresize) with the template marked upon it in the location of and size of the best match.
Iborders: Binary image of the borders of the template/object in Isresiz for the best match (Edges of the found object in the image Isresize ). 
Ysizesys,Ysizeitm the size of the y axes of Isresize and  Itmresize respectively.
 ybest xbest: location on the image (in pixels) were the template were found (for the resize template/image in Isresize,Itmresize).
Borders_XY: array of x,y coordination of the border point in Iborder.
BestScore: Score of the best match found in the scan (the score of the output).

Algorithm:
The function scan the various of ratios of image to template and for each ratio search for the template in the image. The size ratio and location in the image that gave the best match for the template are chosen.
Scanning of size ratios of image to template is done by two loops:
First loop: shrink the image Is by 0.5%  in each cycle until it reach the size of the original template Itm. For each cycle in the loop scan the original template Itm in the resize version of Is.
If the best match have higher score then previously best match write it.
Second loop: shrink the template by 0.5%  in each cycle until it reach minimal dimension of 100 pixels. For each cycle in the loop scan for  the resize template Itm in the original image Is.
If the best match have higher score then previously best match write its location and the size ration.
Use size ratio and location that gave best match as output.

%}
%================================initialize optiona paramters==========================================================================================
if nargin<3
    search_mode='template'; %method by which the template will be searche in the image (altrnative 'hough');
end;
if nargin<4
    border='canny';%'sobel';% type of image in which the template will be searche
end;
if nargin<5
    Sitm=size(Itm);
tm_dilation=floor(sqrt(Sitm(1)*Sitm(2))/80);% dilation level of the template in order to avoid the edge from missing correct point by dilation the size of dilation is proportinal to the size of the item template dimension.

   % tm_dilation=1;
end;
if nargin<6
    neg_corl='out'; %'full';%type areas of crosscorrelation and negative crosscorrelation (negative template) around the original template
end;
Itm=logical(Itm);% make sure Itm is boolean image

close all;
imtool close all;
%==========================================================================================================================
%-----------------------------------------------resize system image-----------------------------------------------------------------------------------------------
Rst=6;% The maximal initial ration between the system image size and the vessel template if the  ration is bigger the image will ve shrinked
maxsysYsize=600; % maximal number of pixels in the Y axis of the  image Is if the image Is larger then this resize it to maxsysYsize; 
St=size(Itm);% size of template
Ss=size(Is);% size of image
if (Ss(1)/St(1)>Rst && Ss(1)/St(1)>Rst); % if the system image is too big (more then Rst time the template) shrink down  the image to rst time the template size 
    Is=imresize(Is,[St(1)*Rst NaN]); 
end;
Ss=size(Is);% system image size
if (Ss(1)>maxsysYsize); % if the system larger then maxsysYsize shrink it to maxsysYsize
    Is=imresize(Is,[maxsysYsize NaN]); 
end;
Is=rgb2gray(Is); % turn the image into greyscale
%figure,
%imshow(Is);
% pause;
%-----------------------------------------------Adapt system image intensity histogram (optional)---------------------------------------------------------------------------
%Is=histeq(Is);% equalize intensity  histogram for complete image to create wider better intensiy range spectrum of intesinity and increase 
%Is=adapthisteq(Is);% equalize histogram image intesnity region by region
%-----------------------shrink system image until it reaches vessel size and match each size to the unchanged vessel template--------------------------------------------------------------------
St=size(Itm);% Itm template image size
Ss=size(Is);% Is image size
%best_matchxy=struct('score',0,'size',0,'y',0,'x',0);% the first value is the score the second value is the fractional template/system size the third and for values are the x and y fractional  cordinates as fraction of maxx and maxy
scale=100;% Size of the image in the current cycle inpercentage (100% orginal image)
BestScore=-1000; % best score found so far
ysize_sys=1;% when the best match found mark the I tm template image y axis size here, if zero vessel template itm image remain in original size
ysize_itm=1;% when the best match found mark the Is image y axis size here, if zero system image remain in original size
Itmresize=Itm; Ysizeitm=St(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======First loop shrink the image Is in every cycle and search for the template Itm ( in original size) in the shrinked image=============================================
while (St(1)<=Ss(1)*1 && St(2)<=Ss(2)*1)% as long as the vessel image smaller then system image
     
  
     %Isr=imresize(Is,[(Ss(1)-1) NaN]);  % resize to by one less Y line and proportinal x
     Isr=imresize(Is,scale/100);  % shrink Is in one percent less
      Ss=size(Isr);% find new system image size
       Szrat=St(1)/Ss(1); % size ratio between system  and template  size
       
       
%----------------------------------------------------------------------------------------------------------------------------------------- 
 % the actuall recogniton step of the template Itm in the resize image Is and return location of best match and its score can occur in one of three modes given in search_mode

     if strcmp(search_mode,'template')  
         [score,  y,x ]=Template_match_vessel_extraction(Isr,Itm,neg_corl,border,tm_dilation);% apply template matching here and return list of good points (x,y)and their scoring
     elseif strcmp(search_mode,'template_angle')
         [score,  y,x ]=Template_match_gradient_direction(Isr,Itm);
     elseif strcmp(search_mode,'hough')
         [score,  y,x ]=Generalized_hough_transform(Isr,Itm);
     end;
      Ss(1);
      
       scale=scale-0.5;% shrink the image by 0.5% in each cycle
%--------------------------if the corrent matching score is better then previous best score write its papramters------------------------------------------------------
  if (score(1)>BestScore) % if item  result scored higher then the previous result
       close all;
       BestScore=score(1);% remember best score
       ysize_sys=Ss(1); %remmeber syste image size when the object is found
       ysize_itm=0;% this mean that the template item image size is not changed.
       Isresize=Isr;% current size
       ybest=y(1);% location of the match
       xbest=x(1);
       %..................................................................................................................................................................
  %Ismarked=imresize(Is,[ysize_sys, NaN]);
 
  
   % k =find2(Itm,1);

  %Ismarked=set2(Ismarked,k,0,ybest,xbest);
  %  figure, imshow(Ismarked);
%  pause();
  end;
 %-----------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Second loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------shrink template Itm in each cycle and search for the template in the original image Is-----------------------------------------------------------------------------------------------------------------------
 minrt=9;% minimal ratio of template Itm to image Is size
  minsize=100;% minimal number of pixel in template image for scan to be proceed
scale=100;% Determine the size of the template Itm in each step of the loop in percetage (100 is original size)
St=size(Itm);
Ss=size(Is);

while (sqrt(Ss(1)/St(1)*Ss(2)/St(2))<minrt && St(1)*St(2)>minsize)
    
     scale=scale-0.5; % shrink image bt 0.5%
     %Isr=resize_border(Itm,St(1)-1, NaN);% scale one line less
     %Itr=resize_border3(Itm,St(1)-1, NaN);
     %Isr=resize_border(Itm,scale/100);% scale one perecent less
     Itr=resize_border3(Itm,scale/100); % resize the template line while maintianing it is binary close countour line image with thinkness of 1 pixel 
     St=size(Itr);% write the new size of the pixel

     %Isr=imresize(Is,[(Ss(1)-1) NaN]);  % resize to by one less Y line and proportinal x
     if (St(1)>Ss(1) || St(2)>Ss(2)) continue; end;
     %[k1, k2] =find(Itm==1);
     %Isr(k1, k2)=1;
     %----------------------------------------------------------------------------------------------------------------------------------------- 
 % the actuall recogniton step of the resize template Itm in the orginal image Is and return location of best match and its score can occur in one of three modes given in search_mode

     if strcmp(search_mode,'template')% the actuall recogniton step of the template in the resize image and return location of best match and its score can occur in one of three mode
             [score,  y,x ]=Template_match_vessel_extraction(Is,Itr,neg_corl,border,tm_dilation); %apply template matching here and return list of good points (x,y) and their scoring
     elseif strcmp(search_mode,'template_angle')
             [score,  y,x ]=Template_match_gradient_direction(Is,Itr);
     elseif strcmp(search_mode,'hough')
            [score,  y,x ]=Generalized_hough_transform(Is,Itr);
     end;
     
     %--------------------------if the correct match score is better then previous best match write the paramter of the match as the new best match------------------------------------------------------
     if (score(1)>BestScore) % if item  result scored higher then the previous result
        close all;
           BestScore=score(1);% remember best score
           ysize_sys=0; %remmeber syste image size when the object is found
           ysize_itm=St(1);% this mean that the template item image size is not changed.
           ybest=y(1);% mark best location y
           xbest=x(1);% mark best location x
           %Isresize=Is; Itmresize=Itr; Ysizesys=Ss(1);,Ysizeitm=St(1); % write output paramters
       %....................................................mark item on image.............................................................................................................................................................................
  
 
          %Itr=resize_border3(Itm,ysize_itm, NaN);
          %k =find2(Itr,1);
          %Ismarked=set2(Is,k,0,ybest,xbest);
          %  figure, imshow(Ismarked);
        %    pause();
     end;
%-------------------------------mark best found location on image---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
        
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%show  and write best match optional part can be removed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ysize_sys==0% if system image size was not change only template size was changed
    Itr=resize_border3(Itm,ysize_itm, NaN);
            k =find2(Itr,1);
            Ismarked=set2(Is,k,255,ybest,xbest); 
            Iborders=logical(zeros(size(Is)));
       Iborders=set2(Iborders,k,1,ybest,xbest);
       Borders_XY=find2(Iborders,0.5);
           % figure, imshow(Ismarked);
          %  pause();
               Isresize=Is; Itmresize=Itr; Ysizesys=Ss(1);Ysizeitm=ysize_itm; % write output paramters note output paramters also writen when they are first found so this part done twice remove one

elseif ysize_itm==0% if match found by shrinking Is
        Isresize=imresize(Is,[ysize_sys, NaN]);
 
  
       k =find2(Itm,1);

       Ismarked=set2(Isresize,k,255,ybest,xbest);
       Iborders=logical(zeros(size(Isresize)));
       Iborders=set2(Iborders,k,1,ybest,xbest);
       Borders_XY=find2(Iborders,0.5);
       %figure, imshow(Ismarked);
       %pause;
        Itmresize=Itm; Ysizesys=ysize_sys;Ysizeitm=St(1); % write output paramters note output paramters also writen when they are first found so this part done twice remove one
    
    
else
    xxx='no match founded'
    Ismarked=0;% assign arbitary value to avoid 
       Iborders=0;
       Iborders=0;
       Borders_XY=0;
       Itmresize=0;
        Isresize=0;
end;
end