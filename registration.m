%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada


[optimizer,metric] = imregconfig('multimodal');
disp(optimizer) %OnePlusOneEvolutionary
disp(metric) %MattesMutualInformation

%Tune parameters
optimizer.GrowthFactor = 1.05; 
optimizer.Epsilon = 1.5e-6;  
optimizer.InitialRadius = 6.25e-03;
optimizer.MaximumIterations = 100;
metric.UseAllPixels = 1;


%Initializing to same size
registered = zeros(size(moving));
finalRegistration = zeros(size(moving));

disp('Starting Registration...')

for i = 1:numberOfAxialSlices

    disp(['Registering Plane: ' num2str(i) '/' num2str(numberOfAxialSlices)])

    %Euclidean Transofrm    
    tformEuclidean = imregtform(moving(:,:,i),target(:,:,i),'rigid',optimizer,metric,'DisplayOptimization',false);
    Rfixed = imref2d(size(target(:,:,i)));
    euclideanRegistration = imwarp(moving(:,:,i),tformEuclidean,'OutputView',Rfixed);
    allTformEuclidean{i} = tformEuclidean;

    %Similarity Transform 
    tformSimilarity = imregtform(euclideanRegistration,target(:,:,i),'similarity',optimizer,metric,'DisplayOptimization',false);
    allTformSimilarity{i} = tformSimilarity;
    finalRegistration(:,:,i) = imwarp(euclideanRegistration,tformSimilarity,'OutputView',Rfixed);

end

%Press left button of mouse to toggle between using scroll wheel to change
%volume planes or changing opacity of the blend.
figure('Name', 'Registered Planes'); reg_visualize(finalRegistration, target); colormap gray;set(gcf, 'units','normalized','outerposition',[0 0.1 1 0.9]);

%Taking average transformation
avgTformEuclidean = allTformEuclidean{1,moving_mid_plane}; 
avgTformSimilarity = allTformSimilarity{1,moving_mid_plane}; 

tempTeuclidean = allTformEuclidean{1,1}.T; 
tempTsimilarity = allTformSimilarity{1,1}.T; 
for i = 2:length(allTformEuclidean)    
    tempTeuclidean = tempTeuclidean + allTformEuclidean{1,i}.T;
    tempTsimilarity = tempTsimilarity + allTformSimilarity{1,i}.T;
end

avgTformEuclidean.T = tempTeuclidean/length(allTformEuclidean);
avgTformSimilarity.T = tempTsimilarity/length(allTformEuclidean);

% Applying average transformation to all planes
disp('Final Registration')
for i = 1:numberOfAxialSlices

    disp(['Registering Plane: ' num2str(i) '/' num2str(numberOfAxialSlices)])

    tformEuclidean = avgTformEuclidean; 
    Rfixed = imref2d(size(target(:,:,i)));
    euclideanRegistration = imwarp(moving(:,:,i),tformEuclidean,'OutputView',Rfixed);

    tformSimilarity = avgTformSimilarity;
    registered(:,:,i) = imwarp(euclideanRegistration,tformSimilarity,'OutputView',Rfixed);

end

%Press left button of mouse to toggle between using scroll wheel to change
%volume planes or changing opacity of the blend.
figure('Name', 'After Reg with average T'); reg_visualize(registered, target); colormap gray;set(gcf, 'units','normalized','outerposition',[0 0.1 1 0.9]);