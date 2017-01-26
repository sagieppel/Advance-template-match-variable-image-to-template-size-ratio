%Use template matching or general hough transform to find template Itm in
%the image Is
% change the image size and vessel countor size to various of ratios the
% image size changed from 100% to 10% of the structure in pixel jump
% scan by two methods 
%c1))shrinking the system image pixel by pixel until (line by line)
% it reach the size of the template (the template remain in it's original size'
% 2) resize the image of the template and for every size scan 
clear all;
close all;
imtool close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%open imAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%images%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Itm=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score x sqrt(ysize).tif');
%Is=imread('C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg');
%Itm=imread('C:\Users\mithycow\Documents\MATLAB\vessel_outline2.tif');
%Is=imread('C:\Users\mithycow\Desktop\trial pictures glassware\edited\IMG_1401.jpg');
Is=imread('C:\Users\mithycow\Desktop\trial pictures glassware\IMG_1398.jpg');
%%{
%Itm=imread('C:\pictures\border large_sqr.bmp');
%Itm=imread('C:\pictures\border_sqr.bmp');
%Itm= im2bw(Itm, 0.5);
%imshow(Itm);
%pause;
%Is=imread('C:\pictures\sqr.bmp');
%}
%-----------------------------------------------resize system image------------------------------------
Rst=2;% the maximal initial ration between the system image size and the vessel template
maxsysYsize=600; % maximal number of pixels in the Y axis of the system image if the system image larger then this resize it to maxsysYsize; 
St=size(Itm);
Ss=size(Is);
if (Ss(1)/St(1)>Rst && Ss(1)/St(1)>Rst); % if the system image is to big (more then Rst time compare to the vessel image resize it down to x time of vessel image x 
    Is=imresize(Is,[St(1)*Rst NaN]); 
end;
Ss=size(Is);% system image size
if (Ss(1)>maxsysYsize); % if the system image is to big (more then Rst time compare to the vessel image resize it down to x time of vessel image x 
    Is=imresize(Is,[maxsysYsize NaN]); 
end;
Is=rgb2gray(Is);
%figure,
imshow(Is);
% pause;
%-----------------------------------------------change system image-----------------------------------

%-----------------------shrink system image until it reaches vessel size--------------------------------------------------------------------
St=size(Itm);% object image size
Ss=size(Is);% system image size
%best_matchxy=struct('score',0,'size',0,'y',0,'x',0);% the first value is the score the second value is the fractional template/system size the third and for values are the x and y fractional  cordinates as fraction of maxx and maxy
nmatch=0; 
scale=100;
bestscore=0;
ysize_sys=1;% when the match found mark the itm template image y size here, if zero vessel template itm image remain in original size
ysize_itm=1;% when the match found mark the system image y size here, if zero system image remain in original size

while (St(1)<=Ss(1)*1 && St(2)<=Ss(2)*1)% as long as the vessel image smaller then system image
     
  
     %Isr=imresize(Is,[(Ss(1)-1) NaN]);  % resize to by one less Y line and proportinal x
     Isr=imresize(Is,scale/100);  % resize to in one percent less
      Ss=size(Isr);% find new system image size
       Szrat=St(1)/Ss(1); % size ratio between system  and template  size
     %[score,  y,x ]=Template_match_vessel_extraction(Isr,Itm,'out','canny',1, 1);% apply template matching here and return list of good points (x,y)and their scoring
     % [score,  y,x ]=Template_match_gradient_direction(Isr,Itm);
     [score,  y,x ]=Generalized_hough_transform(Isr,Itm);
      Ss(1);
      
       scale=scale-0.5;
     %--------------------------if the correct mark is better then previous mark use it template on image------------------------------------------------------
  if (score(1)>bestscore) % if item  result scored higher then the previous result
     close all;
      bestscore=score(1);% remember best score
       ysize_sys=Ss(1); %remmeber syste image size when the object is found
       ysize_itm=0;% this mean that the template item image size is not changed.
       ybest=y(1);
       xbest=x(1);
       %..................................................................................................................................................................
  Ismarked=imresize(Is,[ysize_sys, NaN]);
 
  
    k =find2(Itm,1);

  %Ismarked=set2(Ismarked,k,0,ybest,xbest);
  %  figure, imshow(Ismarked);
%  pause();
  end;
 %-----------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------shrink vessel edge image until it reach some minimal fraction of system image or minimal number of pixels-----------------------------------------------------------------------------------------------------------------------
 minrt=8;% minimal ratio of system to vessel
  minsize=100;% minimal number of pixel in vessel image
scale=100;
St=size(Itm);
Ss=size(Is);

while (Ss(1)/St(1)<minrt && Ss(2)/St(2)<minrt && St(1)*St(2)>minsize)
    
     scale=scale-0.5;
     %Isr=resize_border(Itm,St(1)-1, NaN);% scale one line less
     %Itr=resize_border3(Itm,St(1)-1, NaN);
     %Isr=resize_border(Itm,scale/100);% scale one perecent less
     Itr=resize_border3(Itm,scale/100);
     St=size(Itr);

     %Isr=imresize(Is,[(Ss(1)-1) NaN]);  % resize to by one less Y line and proportinal x
     if (St(1)>Ss(1) || St(2)>Ss(2)) continue; end;
     %[k1, k2] =find(Itm==1);
     %Isr(k1, k2)=1;
     %[score,  y,x ]=Template_match_vessel_extraction(Is,Itr,'out','canny',2, 1); %apply template matching here and return list of good points (x,y) and their scoring
     %[score,  y,x ]=Template_match_gradient_direction(Is,Itr);
     [score,  y,x ]=Generalized_hough_transform(Is,Itr);
     St=size(Itr);% find new image size
     %--------------------------if the correct mark is better then previous mark use it template on image------------------------------------------------------
     if (score(1)>bestscore) % if item  result scored higher then the previous result
        close all;
           bestscore=score(1);% remember best score
           ysize_sys=0; %remmeber syste image size when the object is found
           ysize_itm=St(1);% this mean that the template item image size is not changed.
           ybest=y(1);% mark best location y
           xbest=x(1);% mark best location x
       %....................................................mark item on image.............................................................................................................................................................................
  
 
            Itr=resize_border3(Itm,ysize_itm, NaN);
           % k =find2(Itr,1);
           % Ismarked=set2(Is,k,0,ybest,xbest);
          %  figure, imshow(Ismarked);
        %    pause();
     end;
%-------------------------------mark best found location on image---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
        
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%show best choice %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ysize_sys==0
    Itr=resize_border3(Itm,ysize_itm, NaN);
            k =find2(Itr,1);
            Ismarked=set2(Is,k,0,ybest,xbest);
            figure, imshow(Ismarked);
            pause();
elseif ysize_itm==0
        Ismarked=imresize(Is,[ysize_sys, NaN]);
 
  
       k =find2(Itm,1);

       Ismarked=set2(Ismarked,k,0,ybest,xbest);
       figure, imshow(Ismarked);
       pause()
    
    
else
    xxx='no match founded'
end;
    