
function [score,  y, x ]=Template_match_gradient_direction(Is,Itm,thresh, edgetype)
% Find  vessel edge image Itm (binary) in   system image Is (Grey) by matching the angle of the gradient .
% determine determine wether to use all points of the image or only point
% with threshhold edge that could be canny or sobel
% with canny larger then some minimal value
% thresh old determine what kind of scores will be used the score as fraction of the the maximum score obtained
% return the score and location of the maximum and score and location of
% every point is score is equal or above thresh*maximum

if (nargin<3)
thresh=0.99;% 
end;
if (nargin<4)
edgetype='canny';% determine the type of edge use in the system image canny(black and white) sobel (absolute gradient value from 1-2000) , or 'none' if the system image is already edge image
end;

 %   imtool(Im,[]);
%----------------------------------------find edges or sobel of the system image--------------------------------------------------------------------------------------------------------
%in this case the edge map determine wich point in the image will be used and which will be ignored
Iedge=ones(size(Is));% if no edge method is used then check all points
highthresh=0.12;
if (strcmp(edgetype,'canny'))   
    Iedg=edge(Is,'canny',[highthresh/3,highthresh],1.1);
elseif (strcmp(edgetype,'sobel'))
    Iedg=edge(i3,'sobel',highthresh*2/3,'nothinning'); %preform soble with given threshold that should be between the canny high and low threshhold no maximum supression applied specify by 'nothinning

end
%imtool(Iedg);
 %pause;
%-------------------------------------------------------------------------find gradient direction image for vessel image and system image--------------------------------------------=-------
dIs=gradient_direction(Is);
dIt=gradient_direction(Itm);
%------------------------------------------------------------------------------template match match the template to the image point by point scan all x y value of the image and score them according to how good are the match between the image direction and item direction-----------------------------------------------------------------------------------------------------
Ss=size(Is);
St=size(Itm);
Itr=double(zeros(Ss));% this is the score matrix that will give the score of the template in each pixel
for y=1:1:Ss(1)% 
    for x=1:1:Ss(2)
        for my=1:1:St(1)
            for mx=1:1:St(2)
                if (y+my-1)<=Ss(1) && (x+mx-1)<=Ss(2)% check that you dont exceed limit
                     if Itm(my,mx)>0 && Iedg(y+my-1,x+mx-1)>0  % if the gradient/edge in this point stron enough to be take seriously
                         Itr(y,x)=Itr(y,x)+1-abs(dIs(y+my-1,x+mx-1)-dIt(my,mx))/pi();% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and 2pi in which the value decrease by one
                     end  
                end
            end;
        end;
    end;
end;
%imtool(Itr);
%---------------------------------------------------------------------------normalized according to template size (fraction of the template points that was found)------------------------------------------------------------------------------------------------
Itr=Itr./sqrt(sum(sum(Itm)));
%---------------------------------------------------------------------------find  the location best score all scores which are close enough to the best score
%imtool(Itr,[]);
mx=max(max(Itr));
%best_loc=find(Itr==mx);

%[ xy(1),xy(2)]
[y,x]=find(Itr>=thresh*mx,  10, 'first'); % find the location first 10 best matches which their score is at least thresh percents of the maximal score and pot them in the x,y array
%xy= [y x];
%score=Itr(y,x); % find score for all cordinates might fail if so use the loop below
score=zeros(size(y));
ss=size(Itm);
 
for i=1:1:size(y)% find the score of the best matches found (parallel to  y,x array
   %score(i)=Itr(xy(i,1),xy(i,2));
   score(i)=Itr(y(i),x(i));
  
end;
%-------------------------------------mark the best result on the system image---------------------------------------------------------------------------
 k =find2(Itm,1);
 
  %mrk=set2(Is,k,0,round(y(1)-ss(1)/2),round(x(1)-ss(2)/2));
mrk=set2(Is,k,0,y(1),x(1));
    %figure, 
  % imtool(mrk);
%pause();

end