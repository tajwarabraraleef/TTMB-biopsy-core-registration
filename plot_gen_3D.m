%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada

%% 3D plot to visualize the mapped cores respective to template

only_mal_core = core(core(:,4) == 2,:);
benign_part_of_mal_core = core(core(:,5) == 2,:);
benign_core = core(core(:,5) ~= 2,:);

only_mal_core_entry = core_entry(core_entry(:,4) == 2,:);
benign_part_of_mal_core_entry  = core_entry(core_entry(:,5) == 2,:);
benign_core_entry  = core_entry(core_entry(:,5) ~= 2,:);


figure; 
subplot(2,2,1)
scatter3(benign_part_of_mal_core(:,2), benign_part_of_mal_core(:,1), benign_part_of_mal_core(:,3),'blue')
hold on;
scatter3(only_mal_core(:,2), only_mal_core(:,1), only_mal_core(:,3),'red','filled')
scatter3(benign_core(:,2), benign_core(:,1), benign_core(:,3),'green','.')
scatter3(tempY_moving(:), tempX_moving(:), ones(size(tempX_moving(:)))*apex_slice,'yellow')
view(90, 90)
title("Axial view")
xticks([min(tempY_moving(:)):(max(tempY_moving(:))-min(tempY_moving(:)))/10:max(tempY_moving(:))])
yticks([min(tempX_moving(:)):(max(tempX_moving(:))-min(tempX_moving(:)))/12:max(tempX_moving(:))])
yticklabels({'A','a','B','b','C','c','D','d','E','e','F','f','G'})
xticklabels([6:-0.5:1])
zticks(round([base_slice:z_diff:apex_slice]))
ylabel("Temp Col: A-G");xlabel("Temp Rows: (1-11)");zlabel("Base to Apex: (1-101)");zlim([1 size(taget_full_volume,3)])

subplot(2,2,2)
scatter3(benign_part_of_mal_core(:,2), benign_part_of_mal_core(:,1), benign_part_of_mal_core(:,3),'blue')
hold on;
scatter3(tempY_moving(:), tempX_moving(:), ones(size(tempX_moving(:)))*apex_slice,'.','yellow')
scatter3(only_mal_core(:,2), only_mal_core(:,1), only_mal_core(:,3),'red','filled')
scatter3(benign_core(:,2), benign_core(:,1), benign_core(:,3),'green','.')
view(0, 0)
camroll(-90)
yticks([min(tempX_moving(:)):(max(tempX_moving(:))-min(tempX_moving(:)))/12:max(tempX_moving(:))])
yticklabels({'A','a','B','b','C','c','D','d','E','e','F','f','G'})
xticks([min(tempY_moving(:)):(max(tempY_moving(:))-min(tempY_moving(:)))/10:max(tempY_moving(:))])
xticklabels([6:-0.5:1])
zticks(round([base_slice:z_diff:apex_slice]))
ylabel("Temp Col: A-G");xlabel("Temp Rows: (1-11)");zlabel(["\bf {Sagittal View}",newline,"Base to Apex: (1-101)"]);zlim([1 size(taget_full_volume,3)])

subplot(2,2,3)
scatter3(benign_part_of_mal_core(:,2), benign_part_of_mal_core(:,1), benign_part_of_mal_core(:,3),'blue')
hold on;
scatter3(only_mal_core(:,2), only_mal_core(:,1), only_mal_core(:,3),'red','filled')
scatter3(benign_core(:,2), benign_core(:,1), benign_core(:,3),'green','.')
scatter3(tempY_moving(:), tempX_moving(:), ones(size(tempX_moving(:)))*apex_slice,'.','yellow')
view(90, 0)
title("Coronal view")
xticks([min(tempY_moving(:)):(max(tempY_moving(:))-min(tempY_moving(:)))/10:max(tempY_moving(:))])
yticks([min(tempX_moving(:)):(max(tempX_moving(:))-min(tempX_moving(:)))/12:max(tempX_moving(:))])
yticklabels({'A','a','B','b','C','c','D','d','E','e','F','f','G'})
xticklabels([6:-0.5:1])
zticks(round([base_slice:z_diff:apex_slice]))
ylabel("Temp Col: A-G");xlabel("Temp Rows: (1-11)");zlabel("Base to Apex: (1-101)");zlim([1 size(taget_full_volume,3)])

subplot(2,2,4)
scatter3(benign_part_of_mal_core(:,2), benign_part_of_mal_core(:,1), benign_part_of_mal_core(:,3),'blue')
hold on;
scatter3(only_mal_core(:,2), only_mal_core(:,1), only_mal_core(:,3),'red','filled')
scatter3(benign_core(:,2), benign_core(:,1), benign_core(:,3),'green','.')
scatter3(tempY_moving(:), tempX_moving(:), ones(size(tempX_moving(:)))*apex_slice,'.','yellow')
view(120, 45)
title("3D view")
xticks([min(tempY_moving(:)):(max(tempY_moving(:))-min(tempY_moving(:)))/10:max(tempY_moving(:))])
yticks([min(tempX_moving(:)):(max(tempX_moving(:))-min(tempX_moving(:)))/12:max(tempX_moving(:))])
yticklabels({'A','a','B','b','C','c','D','d','E','e','F','f','G'})
xticklabels([6:-0.5:1])
zticks(round([base_slice:z_diff:apex_slice]))
ylabel("Temp Col: A-G");xlabel("Temp Rows: (1-11)");zlabel("Base to Apex: (1-101)");zlim([1 size(taget_full_volume,3)])
