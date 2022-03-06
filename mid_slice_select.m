%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada


%% Selecting Slices from mpTRUS that corresponds to the TTMB images from Base to Apex

moving_mid_plane = round(size(moving,3)/2); 

%Press left button of mouse to toggle between using scroll wheel to change
%target volume planes or changing opacity of the blend. The moving plane
%can also be changed, but find the matching slice indicated
figure('Name', ['Select Slice number: ' num2str(moving_mid_plane)]); pre_reg_visualize(moving, target, moving_mid_plane), colormap gray; set(gcf, 'units','normalized','outerposition',[0 0.1 1 0.9]);

prompt = {'Manually enter mid slice number:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {''};
opts.WindowStyle = 'normal';
opts.Resize = 'on';
answer = inputdlg(prompt,dlgtitle,dims,definput, opts);
slice = str2num(answer{1}); 

%Finding the rest of the matching slices based on the 5mm differences
%between the planes
slice_difference_pixels = round(pix_spacing_moving(3)/pix_spacing_target(3)); 

slice = [slice - slice_difference_pixels*(moving_mid_plane-1):slice_difference_pixels:slice-slice_difference_pixels...
    slice:slice_difference_pixels:slice + slice_difference_pixels*(size(moving,3)-moving_mid_plane)];

%Sampling the target domain based on the matched slices
taget_full_volume = target;
target = target(:,:,slice);

%Press left button of mouse to toggle between using scroll wheel to change
%volume planes or changing opacity of the blend.
figure('Name', 'Before Reg'); reg_visualize(moving, target), colormap gray; set(gcf, 'units','normalized','outerposition',[0 0.1 1 0.9]);

