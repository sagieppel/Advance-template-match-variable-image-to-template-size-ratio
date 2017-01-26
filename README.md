# Advance-template-match-variable-image-to-template-size-ratio
Find template (Itm) in the canny edge image of image (Is). Matlab code
Advance template match with variable template to image size ratio. Find template (Itm) n the canny edge image of image greyscale image (Is). 
The template size don’t need to be the same to the target object on the image. Scan in various of size ratios of the image and the template to find best match. 
The template Itm must be line of closed contour. 
Use the difference between the edge density on the template and around the template to get the match score. Work better than regular template match for images with dense features and noise. 
Input: Is colour image where the template should be found. Itm: The template Binary image, must be closed contour line. 
Output: The location of the best match the score of the match. And the image with best match marked on it. Also return the resize image Is and resize template, in the size ratio that gave the best match. 
Main function: MAIN_find_template_in_image 
See ReadMe in source code dir file for instruction/documentation
