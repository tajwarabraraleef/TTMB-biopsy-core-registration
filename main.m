%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada

%This code is for registering TTMB biopsy cores to mpTRUS domain. 
%Screenshots of the transverse view were taken during the Volume study right 
%before the TTMB. These screenshots are registered with the mpTRUS volume in
%order to learn the transformation parameters for the template and hence the
%cores. Deflection of the needle trajectories are also taken into account.

close all; clear all

%Set the parameters here
core_length_cm = 2.2;

data_path = '.\data\';
screenshotPath = [data_path '\axial screenshots\'];


%% Pixel spacings
pix_spacing_target = [0.25, 0.25, 0.6 ]; %mm
pix_spacing_moving = [0.108, 0.108, 5 ]; %mm

%% Loading TTMB volume (moving)
screenshotFiles = dir([screenshotPath '/*.bmp']);
numberOfAxialSlices = length(screenshotFiles); %number of axial images
movingOrg = [];
for i = 1:numberOfAxialSlices
    img_rgb = imread([screenshotPath screenshotFiles(i).name]);  
    movingOrg = cat(3,movingOrg, img_rgb(:,:,1));
end
 
%% Loading mpTRUS Bmode volume (target)
targetOrg = niftiread([data_path 'Bmode_axial.nii']);
targetOrg = flip(imrotate3(targetOrg,270,[0 0 1],'nearest'),2); %Fixing nii file orientation

%% Cropping both volumes to remove some unnecessary information (rectum wall, fan shaped geometry)
roi = [211 119 206 0]; 
moving_cropped = double(movingOrg(roi(1):end-roi(2),roi(3):end-roi(4),:))/255;
img_rgb = img_rgb(roi(1):end-roi(2),roi(3):end-roi(4),:);

roi = [25 39 40  39];
target = (targetOrg(roi(1):end-roi(2),roi(3):end-roi(4),:))/255;

%further removing any information outside the fan shaped geometry
fan_shaped_mask = img_rgb(:,:,1)>0;   
moving_cropped = moving_cropped.*repmat(fan_shaped_mask(:,:,1),[1 1 size(moving_cropped,3)]);

%% Template detection
template_detection %calling template_detection script

%% Resizing  
%The moving image is high res as it is screen captured from the US; the
%target is low res as it it interpolated from raw I/Q data

aspectFix = -10; %Fix aspect ratio if needed
resizeScale = size(target,1)/size(moving_cropped,1);
axis1 = round(size(moving_cropped,1)*resizeScale); 
axis2 = round((size(moving_cropped,2)/size(moving_cropped,1))*axis1)+aspectFix; 
moving = imresize3(moving_cropped,[axis1 axis2 size(moving_cropped,3)*1]);

%Changing a1 coordinates based on resizinging
a1_moving = [(a1_moving(1)*axis2/size(moving_cropped,2)) (a1_moving(2)*resizeScale)];
template_grid_spacing_moving = [(template_grid_spacing_moving(1)*axis2/size(moving_cropped,2)) (template_grid_spacing_moving(2)*resizeScale)];

pix_spacing_moving = pix_spacing_moving .* [size(moving_cropped,1)/size(moving_cropped,1), size(moving,2)/size(moving,2), 1];

%Zero padding to have same image dimension for target and moving 
zeroPad = abs(size(moving,2)-size(target,2));
moving = padarray(moving,[0 round(zeroPad/2) 0],0,'pre');
moving = padarray(moving,[0 zeroPad-round(zeroPad/2) 0],0,'post');

a1_moving = a1_moving + [round(zeroPad/2),0];
x_grid_diff = template_grid_spacing_moving(1);
y_grid_diff = template_grid_spacing_moving(2);

figure('Name','Moving with a1'); 
imshow(moving(:,:,1)); 
hold on; 
scatter([a1_moving(1) a1_moving(1)+template_grid_spacing_moving(1)],[a1_moving(2) a1_moving(2)-template_grid_spacing_moving(2)], 'Linewidth',1.5);

%% Mid slice selection
mid_slice_select %calling mid_slice_select script

%% Registration part
registration %calling registration script

%% Create template 11x13
x = [a1_moving(1):x_grid_diff:a1_moving(1)+x_grid_diff*12];
y = [a1_moving(2):-y_grid_diff:a1_moving(2)-y_grid_diff*10];
[tempX_moving, tempY_moving] = meshgrid(x,y);

%% Finding template in target domain
%Applying transformation to template to align with the registered volume
tempX_target = tempX_moving;
tempY_target = tempY_moving;
for i = 1:size(tempX_moving,1)
    for j = 1:size(tempX_moving,2)
    
    [xdataT,ydataT]=transformPointsForward(avgTformEuclidean,tempX_moving(i,j),tempY_moving(i,j));
    Rfixed = imref2d(size(target(:,:,1)));
    [xdataI,ydataI]=worldToIntrinsic(Rfixed,xdataT,ydataT);
    
    [xdataT,ydataT]=transformPointsForward(avgTformSimilarity,xdataI,ydataI);
    [tempX_target(i,j),tempY_target(i,j)]=worldToIntrinsic(Rfixed,xdataT,ydataT);
    
    end
end

figure('Name','Red: Moving template, Green: Target template'); 
subplot(1,3,1);imshow(moving(:,:,moving_mid_plane),[]); title('Moving');hold on;
scatter(tempX_moving(:),tempY_moving(:),'red')
subplot(1,3,2);imshow(registered(:,:,moving_mid_plane),[]); title('Registered');hold on;
scatter(tempX_moving(:),tempY_moving(:),'red')
scatter(tempX_target(:),tempY_target(:),'green')
subplot(1,3,3);imshow(target(:,:,moving_mid_plane),[]); title('Target');hold on;
scatter(tempX_target(:),tempY_target(:),'green')
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
sgtitle('Red: Moving template, Green: Target template')


%% Needle trajectory estimation and core mapping
needle_trajectory_estimation %calling needle_trajectory_estimation script

%% 3D plot to visualize the mapped cores respective to the core
plot_gen_3D %calling plot_gen_3D script

%% Generating image for cores 
%Positive cores
core_pos = zeros(size(taget_full_volume));
for i = 1:size(core,1)    
    if core(i,5)==2 %if positive core
        core_pos(round(core(i,2)),round(core(i,1)),round(core(i,3))) = 1; 
    end
end
se = strel('diamond',6);
core_pos = (imdilate(core_pos,se));

%Malignant cores
core_mal = zeros(size(taget_full_volume));
for i = 1:size(core,1)     
    if core(i,4)==2 %If malignant in that part of the core
        core_mal(round(core(i,2)),round(core(i,1)),round(core(i,3))) = 1; 
    end
end
se = strel('square',20);
core_mal = (imdilate(core_mal,se));
core_mal = core_pos + core_mal;

%Benign cores
core_ben = zeros(size(taget_full_volume));
for i = 1:size(core,1)
    if core(i,5) ~= 2
        core_ben(round(core(i,2)),round(core(i,1)),round(core(i,3))) = 0.7; %Benign cores
    end
end
se = strel('disk',4,0);
core_ben = (imdilate(core_ben,se));

% Adding template to the image
core_template = zeros(size(taget_full_volume));
for i = 1:size(tempX_moving,1)
    for j = 1:size(tempX_moving,2)
        if tempY_moving(i,j)>1
            core_template(round(tempY_moving(i,j)),round(tempX_moving(i,j)),:) = 0.3; %Template points
        end
    end
end
core_template = core_template(1:size(taget_full_volume,1), 1:size(taget_full_volume,2), 1:size(taget_full_volume,3));

%Adding together
core_img = (core_template + core_ben + core_mal);
core_img = core_img/max(core_img(:));


%Press left button of mouse to toggle between using scroll wheel to change
%volume planes or changing opacity of the blend. Here the first volume are
%the cores where the circles are benign, square are mal, and diamond are
%benign part of pos cores.
figure('Name', 'Cores mapped with Bmode'); reg_visualize(core_img, taget_full_volume); colormap gray;set(gcf, 'units','normalized','outerposition',[0 0.1 1 0.9]);

%% Mapped cores on anatomical planes
siz = size(target);

figure('Name', 'Axial');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
imagesc(target(:,:,moving_mid_plane)); colormap gray; axis off; axis equal; 
title('Axial');
hold on; 
scatter(tempX_target(:),tempY_target(:),'filled','MarkerEdgeColor','#EDB120','MarkerFaceColor','#EDB120','LineWidth',3)
scatter(core_entry(:,1),core_entry(:,2),40,'filled','MarkerEdgeColor','#00ff00','MarkerFaceColor','#00ff00','LineWidth',5)
scatter(benign_part_of_mal_core_entry(:,1),benign_part_of_mal_core_entry(:,2),'filled','MarkerEdgeColor', 'blue','MarkerFaceColor', 'blue','LineWidth',5)
scatter(only_mal_core_entry(:,1),only_mal_core_entry(:,2),'filled','MarkerEdgeColor', 'red','MarkerFaceColor', 'red','LineWidth',5)
% print('axial.png','-dpng','-r600')

figure('Name', 'Sagittal');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
imagesc(squeeze(taget_full_volume(:,round(siz(2)/2),:)));colormap gray, axis off; axis equal;
title('Sagittal');
hold on;
for i = 1:size([core_ind.label],2)
 plot(core(1+(i-1)*length(temp_core):(1+(i-1)*length(temp_core))+length(temp_core)-1,3),core(1+(i-1)*length(temp_core):(1+(i-1)*length(temp_core))+length(temp_core)-1,2),'Color','#00ff00','LineWidth',2.5)
end
scatter(benign_part_of_mal_core(:,3),benign_part_of_mal_core(:,2),'MarkerEdgeColor', 'blue','LineWidth',5)
scatter(only_mal_core(:,3),only_mal_core(:,2),'MarkerEdgeColor', 'red','LineWidth',5) 
% print('sagittal.png','-dpng','-r600')
 
figure('Name', 'Coronal');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
imagesc(squeeze(taget_full_volume(97,:,:)));colormap gray; axis off;axis equal; 
title('Coronal');
hold on;
for i = 1:size([core_ind.label],2)
 plot(core(1+(i-1)*length(temp_core):(1+(i-1)*length(temp_core))+length(temp_core)-1,3),core(1+(i-1)*length(temp_core):(1+(i-1)*length(temp_core))+length(temp_core)-1,1),'Color','#00ff00','LineWidth',1.5)
end
scatter(benign_part_of_mal_core(:,3),benign_part_of_mal_core(:,1),'filled','MarkerEdgeColor', 'blue','MarkerFaceColor', 'blue','LineWidth',1)
scatter(only_mal_core(:,3),only_mal_core(:,1),'filled','MarkerEdgeColor', 'red','MarkerFaceColor', 'red','LineWidth',1)
% print('coronal.png','-dpng','-r600')

figure('Name', '2D visualization of needle deflection');imshow(target(:,:,moving_mid_plane),[]); 
title('2D visualization of needle deflection');hold on;
scatter(tempX_target(:),tempY_target(:),'yellow')
scatter(core(:,1),core(:,2), 'filled','green')
scatter(benign_part_of_mal_core(:,1),benign_part_of_mal_core(:,2), 'blue')
scatter(only_mal_core(:,1),only_mal_core(:,2), 'red', 'filled')
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

