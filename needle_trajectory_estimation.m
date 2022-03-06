%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada


%% Mapping cores and estimating needle trajectory
base_slice = min(slice);
apex_slice = max(slice);

z_diff = slice_difference_pixels;
z_pixelspacing = pix_spacing_target(3)/10; %per pixel in z axis in cm

total_z_cm = size(taget_full_volume,3)*z_pixelspacing;
zstart2base = total_z_cm - base_slice*z_pixelspacing;

T = readtable([data_path '\path_report_sample.xlsx']);
number_of_cores = size(T,1);

z_base2tip = T.CoreStart_depthfromBase_FromPathologyReport; 
x_entry = T.GridRow_fromReport_;
y_entry = T.GridCol_fromReport_;

%Translation of needle in cm
x_delta = T.deltaX;
y_delta = T.deltaY; 

%Labels
labels = T.SimplidiedLabels; 
cancerCoreLength = T.CoreLength;
cancerLocation = T.CancerLocationInCore_fromBaseToApex_;

%Removing NAN values
x_delta(isnan(x_delta)) = 0;
y_delta(isnan(y_delta)) = 0;
z_temp = 1;
z_0 = (repmat(zstart2base ,number_of_cores,1) - z_base2tip + z_temp);

%Calculating theta that creporresponds to deflection of the needles if any
theta_x = atan(x_delta./z_0);
theta_y = atan((y_delta.*cos(theta_x))./z_0);

theta_y(isnan(theta_y)) = 0;
theta_y = -theta_y; %Because y axis starts from top for images. 
y_entry = y_entry - 1; %y starts with 1

%Convert x_start to coordinates
lookup = 'AaBbCcDdEeFfG';
value = 0:0.5:6;
x_start_char = char(x_entry);
x_entry = zeros(size(y_entry));
for i = 1:number_of_cores
    x_entry(i) = value(lookup == x_start_char(i));
end

%converting to pixels in the image coordinate
z_0 = z_0/z_pixelspacing;
x_entry = (x_entry*2*x_grid_diff)+ a1_moving(1);
y_entry = a1_moving(2) - (y_entry*2*y_grid_diff);

core_length = core_length_cm/z_pixelspacing; 

%For every core, find the pixels in the volume where it belongs
core = []; core_entry = [];
for i = 1:number_of_cores
    
    temp_label = labels(i);
    
    %generate core size in terms of pixels
    temp_core = repmat(temp_label,round(core_length)+1,1);
    temp_total_core = repmat(temp_label,round(core_length)+1,1);
    
    %if malignant, find in which location the core is malignant 
    if temp_label == 2
        
        temp_cancerCoreLength = cancerCoreLength(i,:); 
        temp_cancerCoreLoc = cancerLocation{i};
        hyphen_indx = find(temp_cancerCoreLoc == '-');
        mal_start = str2num(temp_cancerCoreLoc(1:hyphen_indx-1));
        mal_end = str2num(temp_cancerCoreLoc(hyphen_indx+1:end));
        
        %converting to 2.2 length core and then to pixels spacing
        mal_start = (mal_start*(core_length_cm/temp_cancerCoreLength))/z_pixelspacing;      
        if mal_start <= 0 %Because indx cant start from zero
            mal_start = 1;
        end
        
        mal_end = (mal_end*(core_length_cm/temp_cancerCoreLength))/z_pixelspacing;       
        if mal_end >= length(temp_core) %Because indx cant be more than the core length
            mal_end = length(temp_core);
        end
        
        %setting core to benign first
        temp_core(:) = 0;
        temp_core(round(mal_start):round(mal_end)) = 2; %and malignant part to 2
              
    end
    
    %flipping cores because the next part starts from apex
    temp_total_core_label = flip(temp_total_core); %These are the labels for positive core and negative core. This is used to identify the entire core if its pos or neg
    temp_core_label = flip(temp_core);
   
    core_temp = [];
    for j = 0:round(core_length)
   
        del_x = tan(theta_x(i))*(z_0(i)+ j);
        del_y = tan(theta_y(i))*((z_0(i)+ j)/cos(theta_x(i)));
               
        del_x = (del_x*z_pixelspacing)*(x_grid_diff/0.5);
        del_y = (del_y*z_pixelspacing)*(y_grid_diff/0.5);
        core_temp = [core_temp; [x_entry(i)+del_x y_entry(i)+del_y ((total_z_cm+z_temp)/z_pixelspacing)-z_0(i)-j temp_core_label(j+1) temp_total_core_label(j+1)]];
        
    end
    
    %remove all core that go outside the bounds
    core_temp = core_temp(core_temp(:,3)>=0.5,:); %anything below 0.5 can be rounded to 0, and 0 indx is out of the image
    core_temp = core_temp(core_temp(:,3)<=size(taget_full_volume,3),:); 
    
    core_temp = core_temp(core_temp(:,2)>=0.5,:);
    core_temp = core_temp(core_temp(:,2)<=size(taget_full_volume,1),:);
    
    core_temp = core_temp(core_temp(:,1)>=0.5,:);
    core_temp = core_temp(core_temp(:,1)<=size(taget_full_volume,2),:);    
 
    %Transform the core locations relative to the moving images to fixed
    %image domain
    [xdataT,ydataT]=transformPointsForward(allTformEuclidean{moving_mid_plane},core_temp(:,1),core_temp(:,2));
    Rfixed = imref2d(size(target(:,:,1)));
    [xdataI,ydataI]=worldToIntrinsic(Rfixed,xdataT,ydataT);

    [xdataT,ydataT]=transformPointsForward(allTformSimilarity{moving_mid_plane},xdataI,ydataI);
    [core_temp(:,1),core_temp(:,2)]=worldToIntrinsic(Rfixed,xdataT,ydataT);
        
    %remove all core that go outside the bounds
    core_temp = core_temp(core_temp(:,2)>=0.5,:);
    core_temp = core_temp(core_temp(:,2)<=size(taget_full_volume,1),:);
    
    core_temp = core_temp(core_temp(:,1)>=0.5,:);
    core_temp = core_temp(core_temp(:,1)<=size(taget_full_volume,2),:);  
    
    if ~isempty(core_temp)
        core = [core; core_temp];
        core_entry = [core_entry; core_temp(1,:)];
        core_ind(i).label = core_temp(:,4);
        core_ind(i).x = core_temp(:,1);
        core_ind(i).y = core_temp(:,2);
        core_ind(i).z = core_temp(:,3);
    end            
end

