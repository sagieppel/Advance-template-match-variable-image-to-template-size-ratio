TemplateDir='EXAMPLE TEMPLATES';
SystemDir='EXAMPLE IMAGES';
%Match all templates in  directory TemplateDir on all images in directory SystemDir for each
%image write the  single best match
Tlist = ls(TemplateDir)%Read list of files in Template directory. Any image that will be added after this part (like image made by the programs will not be read to prevent endless loop
Slist = ls(SystemDir)%%Read list of files in System directory.Any image that will be added after this part (like image made by the programs will not be read to prevent endless loop
%cuments\MATLAB\symmetry_score x sqrt(ysize).tif';
%Isname='C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg';
Ss=size(Slist);
for fs=1:Ss(1)% scan all system images
    if  ~isempty(strfind(Slist(fs,:),'.JPG')) || ~isempty(strfind(Slist(fs,:),'.jpg')) % if file is jpg image read this image and scan all template on this image
        Is=imread([SystemDir '\' Slist(fs,:)]);
          disp(['image  ' Slist(fs,:)]);% write file name
        %imshow(Is);pause();
%---------------------------------------------------------------------------------------------------------------------------------------        
           Ts=size(Tlist);
           BestScore=-10000;
              for ft=1:Ts(1)% scan all templates in template library and match them to image
                    if  ~isempty(strfind(Tlist(ft,:),'.tif')) || ~isempty(strfind(Tlist(ft,:),'.tif')) % if file is jpg image read this image and scan all template on this image
                            Itm=imread([TemplateDir '\' Tlist(ft,:)]);
                            disp(['template  ' Tlist(ft,:)]);% write file name
                        %    imshow(Itm);pause();
                            %scan for tmplate in image
                           [TIsresize,TItmresize,TImarked,TIborders, TYsizesys,TYsizeitm,Tybest,Txbest,TBorders_XY, score]= MAIN_find_object_in_image(Is,Itm,'template');%'hough');'template'
                            if score>BestScore % if the match of this template is better then previous templates write it as best match
                                BestScore=score;
                                Itmname=Tlist(ft,:);% remeber the temolate file
                                Isresize=TIsresize; Itmresize=TItmresize; Imarked=TImarked; Iborders=TIborders; Ysizesys=TYsizesys; Ysizeitm=TYsizeitm; ybest=Tybest; xbest=Txbest; Borders_XY=TBorders_XY; 
                            end
                    end;
              end
%------------------------------------------------Get basic file name and path with no extension----------------------------------------------------------------------------------------
          %  outname= strrep(filename,' ','');
          %Get basic file name and path with no extension
             filename= [SystemDir '\' Slist(fs,1:length(Slist(fs,:)))];%Get basic file name and path with no extension
            
               for ff=length(filename):-1:1 % remove spaces from upper part of file
                   if filename(ff)~=' ' 
                       break;
                   end;
               end;
            outname = filename(1:ff-4);%Get basic file name and path with no extension
 %------------------------------------write best match for current image-------------------------------------------------------------------------------------------------           
            imwrite(Itmresize,[outname '_TEMPLATE.tif']);% template image resize to optimal size in which the match was performed
            imwrite(Isresize,[outname '_SYSTEM.tif']);% system image resize to optimal size in wihch the best match was found
            imwrite(Imarked,[outname '_MARKED.tif']);% the resize system image with objects template borders marked in the matching point
            imshow(Imarked);
            imwrite(Iborders,[outname '_BORDERS.tif']);%same size system image all pixels are zero except on the point where the object borders were found
            template_type=Itmname(max(find(Itmname=='\'))+1:length(Itmname)-4);% presumably the template type (hence the type of vessel) is given by the file name
            save([outname '_TEMPLATE_PARAMETERS'],'template_type', 'Ysizesys','Ysizeitm','ybest','xbest','Itmname'); %save all relevant parameters
            save([outname '_BORDERS_COORDINATES_ARRAY'],'Borders_XY');
    end
end
%{
ScanMultipleTemplateOnMultipleImages.m (script)
Scan group of templates on group of images and finding the single best match to each image
The script receives two directories. One directory (SystemDir given in line 2 of the script) contains images in which the template should be found  in jpg format.  Second directory (TemplateDir line 1 of the script) contain template images of the vessel in binary tif format. These template files must be binary tif  file that contain template of close contour. The script find the location of size of the vessel corresponding to the template in the image. If the templates directory contains more than one template it will scan all templates on each image and will pick the one that give the best match. Template of object could be made by extracting the object contour from background using the script at: http://www.mathworks.com/matlabcentral/fileexchange/46887-find-boundary-of-symmetric-object-in-image
Output:
All output  of the scripts will appear as files in the directory of the input image, if the input image named x.jpg all output refer to this image will appear in file names x_description.tif. 
The script writes the boundaries of the object found in the image “x.jpg” in in binary image “x_BORDERS.tif” in the same directory as the original image.  
The script also write the image x.jpg (resized and greyscale) with the boundary of the object marked white in file  “x_MARKED.tif”. 
The template resized to the size were the best match where made is written as “x_TEMPLATE.tif” in the directory of x.
 The input image x.jpg  resized to the size in which the best match where made is written as x_SYSTEM.tif. 
Note that the borders written in x_BORDERS.tif and the template written in x_TEMPLATE.tif both fit in size and location to the object in the image x_SYSTEM.tif (which is a resize version of the input image x.jpg).
Instructions: 
1)	Open file ScanMultipleTemplateOnMultipleImages.m.
2)	Enter the directory in which the images are stored (in jpg color format) in SystemDir In line 2 of the script.
3)	Enter the directory in which the templates images are stored (in  tif binary  format) in TemplateDir In line 1 of the script.
4)	Run script 
5)	After the script finished running the output should appear in the same directory of the original images (SystemDir). 
Examples
See directory “EXAMPLE IMAGES”  for example input images. 
See directory “EXAMPLE TEMPLATES” for example templates image directory.
These two directories are  located in the source code directory.

?
%}
