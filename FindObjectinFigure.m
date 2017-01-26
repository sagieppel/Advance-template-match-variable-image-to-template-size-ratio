Itmname='C:\Users\mithycow\Documents\MATLAB\symmetry_score x sqrt(ysize).tif';
Isname='C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg';

Itm=imread(Itmname);
Is=imread(Isname);
[Isresize,Itmresize,Imarked,Iborders, Ysizesys,Ysizeitm,ybest,xbest,Borders_XY]= MAIN_find_object_in_image(Is,Itm,'hough');%'hough');
outname = Isname(1:length(Isname)-4);%Get basic file name and path with no extension
imwrite(Itmresize,[outname '_TEMPLATE.tif']);% template image resize to optimal size in which the match was performed
imwrite(Isresize,[outname '_SYSTEM.tif']);% system image resize to optimal size in wihch the best match was found
imwrite(Imarked,[outname '_MARKED.tif']);% the resize system image with objects template borders marked in the matching point
imwrite(Iborders,[outname '_BORDERS.tif']);%same size system image all pixels are zero except on the point where the object borders were found
Itmname= strrep(Itmname,' ','');
template_type=Itmname(max(find(Itmname=='\'))+1:length(Itmname)-4);% presumably the template type (hence the type of vessel) is given by the file name
save([outname '_TEMPLATE_PARAMETERS'],'template_type', 'Ysizesys','Ysizeitm','ybest','xbest','Itmname'); %save all relevant parameters
save([outname '_BORDERS_COORDINATES_ARRAY'],'Borders_XY');