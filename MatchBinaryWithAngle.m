function [ score ] = MatchBinaryWithAngle(Is, Iel, mode )  
%given two bnary Is Ir images of the same dimension give the score of the cross
%correlation  including angles cross correlation  return matching score
% Is can be binary (mode='none') in this case it is used as it is for the crosscorrelation or Is can be grey scale if greysale it can be transform into
% binary by canny (mode='canny') or to sobel gradient size map  (mode='soble') with wich the cross correlation will done
%mode='none' cross crrelation with Is of Is use angle and gradient size
%mode='canny' cross crrelation with canny of Is use angle and gradient size
%mode='sobel_angel' cross crrelation with sobel of Is use angle and gradient size
%mode='sobel_size'  cross crrelation with sobel of Is use only gradient size
%mode='sobel_angel_only' cross crrelation with of Is sobel use angle only
%It  must be binary preferably It sold contain less points then Is for speed porpuse
dIs=gradient_direction(Is);% gradient dirction map in each point halfcrcle between 1 and pie 
dIt=gradient_direction(Iel);% gradient dirction map in each pointhalf circle  between 1 and pie    
    if (nargin==2) 
        mode='none';
      
    end
    if strcmp(mode,'canny')%Is is greyscale and need to be used as canny binary image
        highthresh=0.12;
        Is=edge(Is,'canny',[highthresh/3,highthresh],1);
      
    elseif strcmp(mode,'sobel_angel') || strcmp(mode,'sobel_angel_only') || strcmp(mode,'sobel_size')%Is is greyscale and need to be used as sobel (absolute gadient value form) 
         
      
        Is= gradient_size( Is );
 
     
         Is=Is/max(max(Is));% normalize accorrding to the values in the picture so the value cnt be more then one
      
    end;
        


p=find(Iel~=0);% find all point on p
score=0;
   for f=1:1:length(p)%
      % imshow(Is);
     % pause();

    %if  Is(p(f))~=0  
        %{
          pause;
       disp('----------------------------------');
       dIt(p(f))
       dIs(p(f))
       1-4*abs(dIs(p(f))-dIt(p(f)))/pi()
   
   
 %}
   if strcmp(mode,'sobel_angel_only')
        score=score+(1-4*abs(mod((dIs(p(f))-dIt(p(f)))/pi(),0.5)));% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and pi/2 in which the value decrease by one

   elseif strcmp(mode,'sobel_size')
        score=score+Iel(p(f))*Is(p(f));% the score value of x,y point  is increase accordint to value of the sobel gradient size map in this point irregadless of angle
   else %for Is in canny mode
            score=score+Iel(p(f))*Is(p(f))*(1-2*abs(mod((dIs(p(f))-dIt(p(f)))/pi(),0.5)));% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and 2pi in which the value decrease by one
  % score=score+abs(cos((dIs(p(f))-dIt(p(f)))));% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and 2pi in which the value decrease by one
   
   end;
            % Is(p(f))=1;
         
    %end;
     
   
   end
end
