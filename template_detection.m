%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada


%% Binarizing Template from TTMB volume  
% For bk US machine, the template is in yellow,
% Here one of the plane from TTMB volume is converted to HSV and then
% thresholded based on hue value for yellow. This can be done for any other
% color as well
threshold_hue = 1/6;
template_moving = zeros(size(img_rgb(:,:,1)));
img_hsv = rgb2hsv(img_rgb);
template_moving(img_hsv(:,:,1)==threshold_hue) = 1;

figure('Name', 'Detected Template from TTMB volume'); 
subplot(1,2,1)
imshow(img_rgb); colormap gray; title('Moving image in RGB')
subplot(1,2,2)
imshow(template_moving); title('Template separated')


%% Template matching to find A1 automatically
refTemplate = imread('template.jpg'); %reference template
refTemplate = refTemplate(500:end-100,250:450)/255;
refTemplate = refTemplate > 0.5;

% Known from the reference template image
a1_ref = [37,181]; %A1 from template in refTemplate
template_grid_spacing_ref = [55,54]; %5 mm in [x,y] 

xdelta = size(refTemplate,2)-a1_ref(1);
ydelta = size(refTemplate,1)-a1_ref(2);

%Doing normalized cross correlation to match position of the ref template
%to moving template and finding a1_moving
c = normxcorr2(refTemplate, template_moving);
[ypeak,xpeak] = find(c==max(c(:))); %find the lower right corner of the matched template
a1_moving = [xpeak, ypeak] - [xdelta, ydelta];


%Find all the x and y coordinates for a cropped region in the moving template
[xx_all, yy_all] = find(template_moving(1:200,200:end)==1);

%Computing the grid spacing of template for x and y
uni_xx_all =  mink(unique(xx_all),4);
x_diff_moving = (uni_xx_all(4)) - (min(xx_all)); 
uni_yy_all = maxk(unique(yy_all),4);
y_diff_moving = (max(yy_all)) - (uni_yy_all(4)); 
template_grid_spacing_moving = [x_diff_moving, y_diff_moving];

figure('Name', 'Template detection'); 
subplot(1,2,1); 
imshow(refTemplate, []); title('Ref template'); 
hold on; 
scatter([a1_ref(1) a1_ref(1)+template_grid_spacing_ref(1)],[a1_ref(2) a1_ref(2)-template_grid_spacing_ref(2)],'LineWidth',1.5);
subplot(1,2,2); 
imshow(template_moving, []); title('Moving template'); 
hold on; 
scatter([a1_moving(1) a1_moving(1)+template_grid_spacing_moving(1)],[a1_moving(2) a1_moving(2)-template_grid_spacing_moving(2)], 'LineWidth',1.5);
